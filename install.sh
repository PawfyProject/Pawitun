#!/data/data/com.termux/files/usr/bin/bash

# ==============================
# PASTIKAN DEPENDENCY TERINSTALL
# ==============================
pkg update -y
pkg install curl -y
pkg install tsu -y
pkg install termux-api -y  # untuk auto run boot

# ==============================
# HAPUS FILE LAMA
# ==============================
cd ~
rm -f optidev.sh

# ==============================
# DOWNLOAD OPTIMIZER DARI RAW
# ==============================
echo "[*] Download optimizer.sh dari GitHub raw"
curl -L -o ~/optidev.sh https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/optidev.sh
chmod +x ~/optidev.sh
echo "[✓] Optimizer siap dijalankan"

# ==============================
# SET AUTO RUN SAAT REBOOT (TERMUX-BOOT)
# ==============================
mkdir -p ~/.termux/boot
rm -f ~/.termux/boot/start.sh

echo "[*] Membuat auto-run script di boot"
cat <<'EOF' > ~/.termux/boot/start.sh
#!/data/data/com.termux/files/usr/bin/bash
tsu -c "bash ~/optidev.sh"
EOF

chmod +x ~/.termux/boot/start.sh

echo "[✓] Auto-run setup selesai. Device akan menjalankan optimizer.sh otomatis saat reboot"
echo "[!] Untuk langsung menjalankan sekarang: tsu && bash ~/optidev.sh"
