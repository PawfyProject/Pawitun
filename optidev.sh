#!/data/data/com.termux/files/usr/bin/bash

# ==============================
# ROOT CHECK
# ==============================
if [ "$(id -u)" -ne 0 ]; then
  echo "[!] Jalankan dengan root (tsu)"
  exit 1
fi

echo "=== FARM BOT HIGH DENSITY MODE START ==="

# ==============================
# AUTO UPDATE DARI GITHUB
# ==============================
echo "[*] Auto-update optimizer"
cd ~
curl -L -o ~/optidev.sh https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/optidev.sh
chmod +x ~/optidev.sh

# ==============================
# CPU PERFORMANCE
# ==============================
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo performance > $cpu 2>/dev/null
done

# ==============================
# DISABLE THERMAL
# ==============================
for z in /sys/class/thermal/thermal_zone*/mode; do
  echo disabled > "$z" 2>/dev/null
done
echo 0 > /sys/kernel/debug/msm_vidc/disable_thermal_mitigation 2>/dev/null

# ==============================
# ZRAM SETUP
# ==============================
swapoff /dev/block/zram0 2>/dev/null
echo 2147483648 > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0

# ==============================
# RAM OPTIMIZATION
# ==============================
echo 100 > /proc/sys/vm/swappiness
echo 0 > /proc/sys/vm/oom_kill_allocating_task
echo 1 > /proc/sys/vm/overcommit_memory

# ==============================
# LMK TUNING
# ==============================
echo "1536,2048,4096,6144,8192,12288" > /sys/module/lowmemorykiller/parameters/minfree

# ==============================
# I/O OPTIMIZATION
# ==============================
for i in /sys/block/*/queue/scheduler; do
  echo noop > $i 2>/dev/null
done

# ==============================
# DISABLE DOZE
# ==============================
dumpsys deviceidle disable
settings put global device_idle_constants inactive_to=999999999
settings put global device_idle_constants motion_inactive_to=999999999
settings put global device_idle_constants idle_after_inactive_to=999999999

# ==============================
# UNLIMITED BACKGROUND PROCESS
# ==============================
settings put global background_process_limit -1

# ==============================
# DISABLE LOGS
# ==============================
logcat -c
setprop log.tag.ActivityManager SUPPRESS
setprop log.tag.PackageManager SUPPRESS

# ==============================
# CACHE CLEAN LOOP (SETIAP 3 JAM)
# ==============================
echo "[*] Start Auto Cache Cleaner (3 Jam)"

while true; do
  echo "[*] Clearing Cache..."
  pm trim-caches 999G

  for pkg in $(pm list packages | cut -d ":" -f 2); do
    rm -rf /data/data/$pkg/cache/* 2>/dev/null
    rm -rf /data/user_de/0/$pkg/cache/* 2>/dev/null
  done

  echo "[✓] Cache Cleared - Sleep 3 Jam"
  sleep 10800
done
