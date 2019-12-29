#!/bin/sh
set -e

printf "❓ Wi-Fi password: "
read password

cp etc/wpa_supplicant/wpa_supplicant.conf /Volumes/boot
sed -i '' "s/password/$password/" /Volumes/boot/wpa_supplicant.conf
echo "✅ Copied Wi-Fi config"

touch /Volumes/boot/ssh
echo "✅ Enabled ssh"
