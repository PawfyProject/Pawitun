#!/system/bin/sh

TARGET="/storage/emulated/0/PunkX/crash.log"

while true
do
    if [ -f "$TARGET" ]; then
        
        SIZE=$(du -h "$TARGET" | cut -f1)
        
        echo "=============================="
        echo "$(date)"
        echo "File ditemukan!"
        echo "Ukuran: $SIZE"
        
        rm -f "$TARGET"
        
        echo "Status: BERHASIL DIHAPUS"
        echo "=============================="
        
    else
        echo "$(date) - File tidak ditemukan"
    fi

    sleep 14400
done
