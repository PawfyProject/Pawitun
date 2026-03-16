#!/data/data/com.termux/files/usr/bin/bash

clear
echo "================================="
echo "        GOFILE FINAL INSTALLER"
echo "        Status: Pawfy Sys v3"
echo "================================="

# ===== dependency check =====
deps=(curl wget jq aapt)
for pkg in "${deps[@]}"
do
    if ! command -v $pkg >/dev/null 2>&1; then
        echo "Menginstall $pkg..."
        pkg install $pkg -y
    fi
done

# ===== Sesi & Token (Wajib di 2026) =====
echo -e "\n[*] Inisialisasi sesi Gofile..."
# Kita butuh cookie dan token akun guest agar tidak dianggap bot ilegal
COOKIE_FILE="gofile_cookie.txt"
RESPONSE_ACC=$(curl -s -A "Mozilla/5.0" -c "$COOKIE_FILE" https://api.gofile.io/createAccount)
TOKEN=$(echo "$RESPONSE_ACC" | jq -r '.data.token' 2>/dev/null)

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo "[!] Gagal membuat sesi API. Gofile mungkin sedang maintenance."
    exit 1
fi

# ===== input folder =====
echo ""
read -p "Masukkan Link atau ID Folder Gofile: " INPUT_LINK
FOLDER=$(echo $INPUT_LINK | awk -F/ '{print $NF}')

echo "[*] Mengambil konten folder: $FOLDER..."

# Menembak API dengan Token dan Cookie yang sudah didapat
# Endpoint: /getFolderContent
API_URL="https://api.gofile.io/getFolderContent?folderId=$FOLDER&token=$TOKEN"
RESPONSE_CONTENT=$(curl -s -A "Mozilla/5.0" -b "$COOKIE_FILE" "$API_URL")

STATUS=$(echo "$RESPONSE_CONTENT" | jq -r '.status' 2>/dev/null)

if [ "$STATUS" != "ok" ]; then
    echo "[!] Error: Gagal mengambil data folder."
    echo "[!] Status API: $STATUS"
    rm -f "$COOKIE_FILE"
    exit 1
fi

# Parsing daftar APK
# Gofile mengelompokkan file di dalam objek 'children' atau 'contents'
echo "$RESPONSE_CONTENT" | jq -r '.data.contents | to_entries[] | .value | select(.name|endswith(".apk")) | "\(.name)|\(.link)|\(.size)"' > list.txt 2>/dev/null

if [ ! -s list.txt ]; then
    echo "[!] Tidak ada file .apk ditemukan di folder tersebut."
    rm -f "$COOKIE_FILE"
    exit 1
fi

echo -e "\n===== DAFTAR APK DITEMUKAN ====="
i=1
while IFS="|" read name link size
do
    MB=$(($size/1024/1024))
    echo "$i) $name (${MB}MB)"
    i=$((i+1))
done < list.txt

echo -e "================================="
read -p "Pilih nomor (contoh: 1 2): " SELECT

# ===== Fungsi Download & Install =====
download_install () {
    LINE=$(sed -n "${1}p" list.txt)
    [ -z "$LINE" ] && return

    NAME=$(echo $LINE | cut -d'|' -f1)
    URL=$(echo $LINE | cut -d'|' -f2)
    SIZE=$(echo $LINE | cut -d'|' -f3)

    echo -e "\n[+] Processing: $NAME"

    # Download menggunakan wget dengan Cookie sesi agar link tidak expire/forbidden
    wget -q --user-agent="Mozilla/5.0" --load-cookies="$COOKIE_FILE" --show-progress -O "$NAME" "$URL"

    if [ -f "$NAME" ]; then
        # Cek integritas file
        ACTUAL_SIZE=$(stat -c%s "$NAME")
        if [ "$ACTUAL_SIZE" -eq "$SIZE" ]; then
            echo "[✔] Download Verified."
            
            # Ambil Package Name
            PKG=$(aapt dump badging "$NAME" 2>/dev/null | grep package | awk -F"'" '{print $2}')
            
            if [ ! -z "$PKG" ]; then
                echo "[*] Package: $PKG"
                echo "[*] Menghapus versi lama..."
                pm uninstall "$PKG" >/dev/null 2>&1
                echo "[*] Menginstall APK baru..."
                pm install -r "$NAME"
                echo "[✔] $NAME Berhasil Terpasang."
            else
                echo "[!] Gagal membaca manifest APK."
            fi
        else
            echo "[!] Ukuran file tidak cocok (Corrupt)."
        fi
        rm -f "$NAME"
    else
        echo "[!] Gagal mengunduh $NAME."
    fi
}

# ===== Jalankan Paralel =====
for num in $SELECT
do
    download_install $num &
    sleep 2 # Jeda singkat agar tidak overload
done

wait
rm -f list.txt "$COOKIE_FILE"
echo -e "\n================================="
echo "        PROSES SELESAI"
echo "================================="
