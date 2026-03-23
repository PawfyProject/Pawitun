#!/data/data/com.termux/files/usr/bin/bash

# ==============================
# PASTIKAN DEPENDENCY TERINSTALL
# ==============================
pkg update -y
pkg install curl -y    # untuk download raw file
pkg install tsu -y     # root access

# ==============================
# HAPUS FILE LAMA JIKA ADA
# ==============================
cd ~
rm -f optidev.sh

# ==============================
# DOWNLOAD OPTIMIZER SH DARI RAW
# ==============================
echo "[*] Download optimizer.sh dari GitHub raw"
curl -L -o ~/optidev.sh https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/optidev.sh

# ==============================
# SET EXECUTABLE
# ==============================
chmod +x ~/optidev.sh

echo "[✓] Install DONE"
echo "Jalankan optimizer dengan: tsu && bash ~/optidev.sh"
