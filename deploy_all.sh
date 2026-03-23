#!/data/data/com.termux/files/usr/bin/bash

# ==============================
# Install dependencies (user shell)
# ==============================
pkg update -y
pkg install curl tsu termux-api -y

# ==============================
# Download install.sh & optidev.sh
# ==============================
cd ~
rm -f install.sh optidev.sh auto_reboot.sh

echo "[*] Download install.sh"
curl -L -o ~/install.sh https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/install.sh
chmod +x ~/install.sh

echo "[*] Download optidev.sh"
curl -L -o ~/optidev.sh https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/optidev.sh
chmod +x ~/optidev.sh

echo "[*] Download auto_reboot.sh"
curl -L -o ~/auto_reboot.sh https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/auto_reboot.sh
chmod +x ~/auto_reboot.sh

# ==============================
# Jalankan install.sh (user shell)
# ==============================
echo "[*] Menjalankan install.sh untuk setup auto-run Termux:Boot"
bash ~/install.sh

# ==============================
# Jalankan auto_reboot.sh di background
# ==============================
echo "[*] Menjalankan auto_reboot.sh di background"
nohup bash ~/auto_reboot.sh &

echo "[✓] Deploy selesai! Optimizer dan reboot scheduler siap jalan"
echo "[!] Untuk langsung menjalankan optimizer sekarang: tsu && bash ~/optidev.sh"
