#!/system/bin/sh

TARGET="/storage/emulated/0/PunkX/crash.log"

echo "Script started..."

while true
do
    if [ -f "$TARGET" ]; then
        SIZE=$(du -h "$TARGET" 2>/dev/null | cut -f1)

        echo "$(date) | Found | Size: $SIZE"
        rm -f "$TARGET"
        echo "$(date) | Deleted"
    else
        echo "$(date) | Not found"
    fi

    sleep 14400
done
