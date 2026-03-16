#!/data/data/com.termux/files/usr/bin/bash

clear
echo "================================="
echo "        GOFILE FINAL INSTALLER"
echo "        Fixed by Pawfy Sys"
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

# ===== generate token (FIXED SECTION) =====
echo ""
echo "Mengambil token Gofile..."

# Menambahkan -A (User-Agent) agar API Gofile merespon dengan JSON valid
RESPONSE=$(curl -s -A "Mozilla/5.0" https://api.gofile.io/createAccount)
TOKEN=$(echo "$RESPONSE" | jq -r '.data.token' 2>/dev/null)

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    echo "Gagal mendapatkan token. Response API: $RESPONSE"
    exit 1
fi

echo "Token OK"

# ===== input folder =====
echo ""
read -p "Masukkan Link Folder Gofile: " LINK

FOLDER=$(echo $LINK | awk -F/ '{print $NF}')
API="https://api.gofile.io/contents/$FOLDER?token=$TOKEN"

echo ""
echo "Mengambil daftar APK..."

# Menambahkan -A juga saat mengambil daftar konten
curl -s -A "Mozilla/5.0" "$API" | jq -r '.data.contents[]? | select(.name|endswith(".apk")) | "\(.name)|\(.link)|\(.size)"' > list.txt

if [ ! -s list.txt ]; then
    echo "Tidak ada APK ditemukan"
    exit 1
fi

echo ""
echo "===== DAFTAR APK ====="
i=1
while IFS="|" read name link size
do
    MB=$(($size/1024/1024))
    echo "$i) $name (${MB}MB)"
    i=$((i+1))
done < list.txt

echo ""
read -p "Pilih nomor (contoh: 1 2 3): " SELECT

# ===== User Agent List =====
UA[0]="Mozilla/5.0 (Linux; Android 10)"
UA[1]="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
UA[2]="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
UA[3]="Mozilla/5.0 (X11; Linux x86_64)"
UA[4]="Mozilla/5.0 (Linux; Android 11)"

download_install () {
    LINE=$(sed -n "${1}p" list.txt)
    if [ -z "$LINE" ]; then return; fi

    NAME=$(echo $LINE | cut -d'|' -f1)
    URL=$(echo $LINE | cut -d'|' -f2)
    SIZE=$(echo $LINE | cut -d'|' -f3)

    R=$((RANDOM % 5))
    AGENT=${UA[$R]}

    echo ""
    echo "================================="
    echo "Downloading $NAME"
    echo "================================="

    retry=0
    while true
    do
        # Download menggunakan wget dengan User Agent
        wget -q --user-agent="$AGENT" --show-progress -O "$NAME" "$URL"

        if [ ! -f "$NAME" ]; then
            retry=$((retry+1))
            echo "File tidak terunduh, mencoba lagi ($retry/3)..."
            sleep 3
        else
            DOWN_SIZE=$(stat -c%s "$NAME")
            if [ "$DOWN_SIZE" -eq "$SIZE" ]; then
                echo "Download verified ✔"
                break
            else
                echo "File corrupt/size mismatch, retry..."
                rm "$NAME"
                retry=$((retry+1))
                sleep 3
            fi
        fi

        if [ "$retry" -ge 3 ]; then
            echo "Gagal mendownload $NAME setelah 3 kali mencoba."
            return
        fi
    done

    # Identifikasi Package Name menggunakan aapt
    PKG=$(aapt dump badging "$NAME" 2>/dev/null | grep package | awk -F"'" '{print $2}')

    if [ ! -z "$PKG" ]; then
        echo "Package: $PKG"
        echo "Uninstall versi lama..."
        pm uninstall "$PKG" >/dev/null 2>&1
        echo "Install APK..."
        pm install -r "$NAME"
        echo "$NAME selesai ✔"
    else
        echo "Gagal membaca package name $NAME"
    fi

    rm -f "$NAME"
}

echo ""
echo "Memulai download..."

for num in $SELECT
do
    download_install $num &
    
    # Delay acak agar tidak terkena rate limit server
    DELAY=$((RANDOM % 4 + 5))
    echo "Menunggu $DELAY detik sebelum antrian berikutnya..."
    sleep $DELAY
done

wait
rm -f list.txt

echo ""
echo "================================="
echo "            SELESAI"
echo "================================="echo ""
read -p "Masukkan Link Folder Gofile: " LINK

FOLDER=$(echo $LINK | awk -F/ '{print $NF}')

API="https://api.gofile.io/contents/$FOLDER?token=$TOKEN"

echo ""
echo "Mengambil daftar APK..."

curl -s "$API" | jq -r '.data.contents[]? | select(.name|endswith(".apk")) | "\(.name)|\(.link)|\(.size)"' > list.txt

if [ ! -s list.txt ]; then
echo "Tidak ada APK ditemukan"
exit
fi

echo ""
echo "===== DAFTAR APK ====="

i=1
while IFS="|" read name link size
do
MB=$(($size/1024/1024))
echo "$i) $name (${MB}MB)"
i=$((i+1))
done < list.txt

echo ""
read -p "Pilih nomor (contoh: 1 2 3): " SELECT

# ===== user agent =====

UA[0]="Mozilla/5.0 (Linux; Android 10)"
UA[1]="Mozilla/5.0 (Windows NT 10.0)"
UA[2]="Mozilla/5.0 (Macintosh)"
UA[3]="Mozilla/5.0 (X11; Linux)"

download_install () {

LINE=$(sed -n "${1}p" list.txt)

NAME=$(echo $LINE | cut -d'|' -f1)
URL=$(echo $LINE | cut -d'|' -f2)
SIZE=$(echo $LINE | cut -d'|' -f3)

R=$((RANDOM % 4))
AGENT=${UA[$R]}

echo ""
echo "================================="
echo "Downloading $NAME"
echo "================================="

retry=0

while true
do

wget \
--user-agent="$AGENT" \
--progress=bar:force \
-O "$NAME" "$URL"

if [ ! -f "$NAME" ]; then
retry=$((retry+1))
sleep 3
continue
fi

DOWN=$(stat -c%s "$NAME")

if [ "$DOWN" -eq "$SIZE" ]; then
echo "Download verified ✔"
break
else
echo "File corrupt, retry..."
rm "$NAME"
retry=$((retry+1))
sleep 3
fi

if [ "$retry" -ge 5 ]; then
echo "Download gagal setelah 5x"
return
fi

done

PKG=$(aapt dump badging "$NAME" | grep package | awk -F"'" '{print $2}')

echo "Package: $PKG"

echo "Uninstall versi lama..."
pm uninstall "$PKG" >/dev/null 2>&1

echo "Install APK..."
pm install -r "$NAME"

rm "$NAME"

echo "$NAME selesai ✔"

}

echo ""
echo "Memulai download..."

for num in $SELECT
do

download_install $num &

DELAY=$((RANDOM % 4 + 5))
echo "Delay $DELAY detik..."
sleep $DELAY

done

wait

rm list.txt

echo ""
echo "================================="
echo "            SELESAI"
echo "================================="exit
fi

echo ""
echo "DAFTAR APK"
echo "---------------------------"

i=1
while IFS="|" read name link size
do
MB=$(($size/1024/1024))
echo "$i) $name (${MB}MB)"
i=$((i+1))
done < list.txt

echo "---------------------------"
read -p "Pilih nomor (contoh: 1 3 5): " SELECT

# ===== user agent list =====

UA[0]="Mozilla/5.0 (Linux; Android 10)"
UA[1]="Mozilla/5.0 (Windows NT 10.0)"
UA[2]="Mozilla/5.0 (Macintosh)"
UA[3]="Mozilla/5.0 (X11; Linux)"
UA[4]="Mozilla/5.0 (Linux; Android 11)"

download_install () {

LINE=$(sed -n "${1}p" list.txt)

NAME=$(echo $LINE | cut -d'|' -f1)
URL=$(echo $LINE | cut -d'|' -f2)
SIZE=$(echo $LINE | cut -d'|' -f3)

R=$((RANDOM % 5))
USER_AGENT=${UA[$R]}

echo ""
echo "================================="
echo "Downloading $NAME"
echo "================================="

RETRY=0

while true
do

wget \
--user-agent="$USER_AGENT" \
--progress=bar:force \
-O "$NAME" "$URL"

if [ ! -f "$NAME" ]; then
echo "Download gagal, retry..."
RETRY=$((RETRY+1))
sleep 3
continue
fi

DOWNLOADED=$(stat -c%s "$NAME")

if [ "$DOWNLOADED" -eq "$SIZE" ]; then
echo "Download verified ✔"
break
else
echo "File corrupt, retry..."
rm "$NAME"
RETRY=$((RETRY+1))
sleep 3
fi

if [ "$RETRY" -ge 5 ]; then
echo "Download gagal setelah 5x"
return
fi

done

PKG=$(aapt dump badging "$NAME" | grep package | awk -F"'" '{print $2}')

echo "Package: $PKG"

echo "Uninstall versi lama..."
pm uninstall "$PKG" > /dev/null 2>&1

echo "Install APK..."
pm install -r "$NAME"

rm "$NAME"

echo "$NAME selesai ✔"

}

echo ""
echo "Memulai download..."

for num in $SELECT
do

download_install $num &

DELAY=$((RANDOM % 4 + 5))
echo "Delay $DELAY detik..."
sleep $DELAY

done

wait

rm list.txt

echo ""
echo "================================="
echo "            SELESAI"
echo "================================="

UA[0]="Mozilla/5.0 (Linux; Android 10)"
UA[1]="Mozilla/5.0 (Windows NT 10.0; Win64)"
UA[2]="Mozilla/5.0 (Macintosh)"
UA[3]="Mozilla/5.0 (X11; Linux)"
UA[4]="Mozilla/5.0 (Linux; Android 11)"

download_install () {

LINE=$(sed -n "${1}p" list.txt)

NAME=$(echo $LINE | cut -d'|' -f1)
URL=$(echo $LINE | cut -d'|' -f2)
SIZE=$(echo $LINE | cut -d'|' -f3)

R=$((RANDOM % 5))
USER_AGENT=${UA[$R]}

echo ""
echo "================================="
echo "Downloading $NAME"
echo "================================="

RETRY=0

while true
do

wget \
--user-agent="$USER_AGENT" \
--progress=bar:force \
-O "$NAME" "$URL"

if [ ! -f "$NAME" ]; then
echo "File tidak ada, retry..."
RETRY=$((RETRY+1))
sleep 3
continue
fi

DOWNLOADED=$(stat -c%s "$NAME")

if [ "$DOWNLOADED" -eq "$SIZE" ]; then
echo "Download verified ✔"
break
else
echo "Ukuran tidak cocok, retry..."
rm "$NAME"
RETRY=$((RETRY+1))
sleep 3
fi

if [ "$RETRY" -ge 3 ]; then
echo "Download gagal setelah 3x"
return
fi

done

PKG=$(aapt dump badging "$NAME" | grep package | awk -F"'" '{print $2}')

echo "Package: $PKG"

echo "Uninstall versi lama..."
pm uninstall "$PKG" > /dev/null 2>&1

echo "Install APK..."
pm install -r "$NAME"

rm "$NAME"

echo "$NAME selesai ✔"

}

echo ""
echo "Memulai download..."

for num in $SELECT
do

download_install $num &

DELAY=$((RANDOM % 4 + 5))
echo "Delay $DELAY detik..."
sleep $DELAY

done

wait

rm list.txt

echo ""
echo "================================="
echo "            SELESAI"
echo "================================="
