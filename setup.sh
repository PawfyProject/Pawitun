#!/bin/bash

# Menunggu sejenak untuk stabilitas sistem awal
sleep $((RANDOM % 10 + 5))

echo "--- Memulai Setup Pawfy Project ---"

# 1. Update Database & Upgrade Library Sistem (WAJIB agar tidak error Linker)
echo "Mengupdate dan mengupgrade sistem Termux..."
yes | pkg update
yes | pkg upgrade -y

# 2. Instalasi Tool Dasar & Dependensi
echo "Menginstal curl, wget, git, lua, sqlite, dan api..."
yes | pkg install curl wget git lua53 sqlite termux-api -y

# 3. Setup Akses Penyimpanan (Akan muncul popup, silakan klik ALLOW)
echo "Meminta akses penyimpanan..."
termux-setup-storage

# 4. Optimasi Layar & Animasi (Hanya bekerja jika HP Root atau via ADB)
echo "Melakukan optimasi sistem (DPI & Animasi)..."
wm size 1280x720 || echo "Info: wm size butuh akses root/adb"
wm density 192 || echo "Info: wm density butuh akses root/adb"

settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0

# 5. Berpindah ke folder Download dan Eksekusi Script Winter
echo "Mendownload dan menjalankan script utama..."
cd /sdcard/Download || cd $HOME

# Download file dengan curl (Sekarang curl sudah aman digunakan)
curl -L -o /sdcard/Download/winter-rejoin.lua https://api.wintercode.dev/loader/winter-rejoin.lua && \
lua /sdcard/Download/winter-rejoin.lua </dev/null

echo "--- Setup Selesai ---"
