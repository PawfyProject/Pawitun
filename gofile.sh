#!/data/data/com.termux/files/usr/bin/bash

clear
echo "================================="
echo "      GOFILE FINAL INSTALLER PRO"
echo "        Update: 2026 Compatible"
echo "================================="

# ===== dependency check =====
deps=(curl wget jq aapt)
for pkg in "${deps[@]}"
do
    if ! command -v $pkg >/dev/null 2>&1
    then
        echo "Menginstall $pkg..."
        pkg install $pkg -y
    fi
done

# ===== input folder =====
echo ""
read -p "Masukkan Link Folder Gofile (public): " LINK

# Hapus trailing slash dan ambil Folder ID
FOLDER=$(echo "$LINK" | sed 's#/$##' | awk -F/ '{print $NF}')

if [ -z "$FOLDER" ]; then
    echo "Folder ID tidak valid!"
    exit 1
fi

echo ""
echo "Mengambil daftar APK dari folder: $FOLDER..."

# ===== Ambil konten folder dari API Gofile =====
API_URL="https://api.gofile.io/getFolderContent?folderId=$FOLDER"
RETRY_API=0

while [ $RETRY_API -lt 3 ]; do
    RESPONSE=$(curl -s -A "Mozilla/5.0" "$API_URL")
    
    # Cek valid JSON
    echo "$RESPONSE" | jq . >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Response API tidak valid, retrying..."
        RETRY_API=$((RETRY_API+1))
        sleep 2
        continue
    fi
    
    STATUS=$(echo "$RESPONSE" | jq -r '.status')
    if [ "$STATUS" == "ok" ]; then
        break
    elif [ "$STATUS" == "error" ]; then
        MSG=$(echo "$RESPONSE" | jq -r '.message')
        echo "API Error: $MSG"
        exit 1
    else
        echo "Unknown API response, retrying..."
        RETRY_API=$((RETRY_API+1))
        sleep 2
    fi
done

if [ $RETRY_API -ge 3 ]; then
    echo "Gagal mengambil folder setelah 3 percobaan."
    exit 1
fi

# ===== Ambil list APK =====
echo "$RESPONSE" | jq -r '.data.contents | to_entries[] | .value | select(.name|endswith(".apk")) | "\(.name)|\(.link)|\(.size)"' > list.txt

if [ ! -s list.txt ]; then
    echo "Tidak ada APK ditemukan di folder ini."
    exit 1
fi

echo ""
echo "===== DAFTAR APK FOUND ====="
i=1
while IFS="|" read name link size
do
    MB=$(($size/1024/1024))
    echo "$i) $name (${MB}MB)"
    i=$((i+1))
done < list.txt

echo ""
read -p "Pilih nomor APK untuk download/install (contoh: 1 2 3): " SELECT

# ===== User Agent List =====
UA[0]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
UA[1]="Mozilla/5.0 (Android 11; Mobile; rv:94.0) Gecko/94.0 Firefox/94.0"
UA[2]="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"

download_install () {
    LINE=$(sed -n "${1}p" list.txt)
    if [ -z "$LINE" ]; then return; fi

    NAME=$(echo $LINE | cut -d'|' -f1)
    URL=$(echo $LINE | cut -d'|' -f2)
    SIZE=$(echo $LINE | cut -d'|' -f3)

    R=$((RANDOM % 3))
    AGENT=${UA[$R]}

    echo ""
    echo "---------------------------------"
    echo "Downloading: $NAME"
    echo "---------------------------------"

    retry=0
    while true
    do
        wget -q --timeout=30 --user-agent="$AGENT" --show-progress -O "$NAME" "$URL"

        if [ ! -f "$NAME" ]; then
            retry=$((retry+1))
            sleep 2
        else
            DOWN_SIZE=$(wc -c < "$NAME")
            if [ "$DOWN_SIZE" -eq "$SIZE" ]; then
                echo "Download Verified ✔"
                break
            else
                echo "Size mismatch, retrying..."
                rm "$NAME"
                retry=$((retry+1))
                sleep 2
            fi
        fi

        if [ "$retry" -ge 3 ]; then
            echo "Gagal mendownload $NAME"
            return
        fi
    done

    # Proses Install
    PKG=$(aapt dump badging "$NAME" 2>/dev/null | grep package | awk -F"'" '{print $2}')
    if [ ! -z "$PKG" ]; then
        echo "Package: $PKG"
        echo "Cleaning old version..."
        pm uninstall "$PKG" >/dev/null 2>&1
        echo "Installing..."
        pm install -r "$NAME"
        echo "Done: $NAME ✔"
    fi
    rm -f "$NAME"
}

# ===== Execution =====
for num in $SELECT
do
    download_install $num &
    sleep $((RANDOM % 3 + 1))
done

wait
rm -f list.txt
echo -e "\n================================="
echo "        SEMUA PROSES SELESAI"
echo "================================="
