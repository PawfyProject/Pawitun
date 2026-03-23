#!/data/data/com.termux/files/usr/bin/bash

# ==============================
# Auto Reboot Scheduler (4 Jam)
# ==============================
echo "[*] Auto-reboot scheduler aktif. Device akan reboot setiap 4 jam"

while true; do
  # Tunggu 4 jam
  sleep 14400  # 4 jam = 14400 detik

  echo "[*] Auto-reboot: memastikan semua auto-rejoin tools tetap jalan setelah reboot"

  # Reboot dengan root
  tsu -c "reboot"

  # Setelah reboot, Termux:Boot akan otomatis jalankan:
  # 1. optidev.sh (optimizer)
  # 2. auto-rejoin tools kamu (sesuai yang sudah di start.sh)
done
