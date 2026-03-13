sleep $((RANDOM % 20))
yes | pkg install curl wget git -y
yes | pkg update
yes | pkg upgrade
termux-setup-storage
yes | pkg install lua53 sqlite termux-api -y
wm size 1280x720
wm density 192
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0
cd /sdcard/Download
curl -L -o winter-rejoin.lua https://api.wintercode.dev/loader/winter-rejoin.lua
LICENSE="074399DD2D7361FCD398420BC6A0C3F7"
while true
do
(
sleep 10
echo "$LICENSE"
) | lua /sdcard/Download/winter-rejoin.lua </dev/null
sleep 5
done
