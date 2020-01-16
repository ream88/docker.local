#!/bin/sh
set -e

if [ ! -d "/Volumes/boot" ]
then
    echo "❌ SD card is not mounted at /Volumes/boot"
    exit 1
fi

printf "❓ Wi-Fi password: "
read password

cp etc/wpa_supplicant/wpa_supplicant.conf /Volumes/boot
sed -i '' "s/password/$password/" /Volumes/boot/wpa_supplicant.conf
echo "✅ Copied Wi-Fi config"

touch /Volumes/boot/ssh
echo "✅ Enabled ssh"

printf "❓ Unmount SD card? [y/N]: "
read answer

if [[ $answer =~ ^[Yy]$ ]]
then
    diskutil unmount /Volumes/boot
fi
