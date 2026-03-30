#!/system/bin/sh

TARGET="/storage/emulated/0/PunkX/crash.log"

while true
do
    if [ -f "$TARGET" ]; then
        rm -f "$TARGET"
        echo "$(date) - crash.log deleted"
    else
        echo "$(date) - crash.log not found"
    fi

    sleep 14400  # 4 jam = 14400 detik
done
