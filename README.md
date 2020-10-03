# docker.local

This is the setup for my Raspberry Pi ~~Zero W~~ 3B (turns out the ARMv6
architecture is not supported by [LinuxServer](https://linuxserver.io) anymore)
running on `docker.local`. At the moment its only purpose is running as a Docker
host for various services including:

## Services

- ### [homebridge](https://github.com/oznu/docker-homebridge)

  ```sh
  docker run -itd \
    --net=host \
    --name=homebridge \
    -e PUID=1000 -e PGID=1000 \
    -e TZ=Europe/Vienna \
    -e HOMEBRIDGE_CONFIG_UI=1 \
    -e HOMEBRIDGE_CONFIG_UI_PORT=8888 \
    -v "$(pwd)/homebridge":/homebridge \
    --restart unless-stopped \
    oznu/homebridge
  ```

  Homebridge is used to make some appliances in my apartment HomeKit ready:

  - Nuki Smart Lock using <https://github.com/ream88/homebridge-nuki-latch>.
  - Two [ceiling lights](https://amzn.to/3iQLGHk) controlled using
    [ESPHome](https://esphome.io)-powered [Sonoff Basic
    Switches](https://amzn.to/3mHHUSV) using
    <https://github.com/lucavb/homebridge-esphome-ts>.

- ### pi-hole

  ```sh
  docker run -itd \
    --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -e TZ=Europe/Vienna \
    -e VIRTUAL_HOST=docker.mariouher.com \
    -v "$(pwd)/etc-pihole/":/etc/pihole/ \
    -v "$(pwd)/etc-dnsmasq.d/":/etc/dnsmasq.d/ \
    --dns=127.0.0.1 --dns=1.1.1.1 \
    --restart unless-stopped \
    --network=bridge \
    pihole/pihole:latest
  ```

- ### nginx

  ```sh
  docker run -itd \
    --name nginx \
    -p 80:80 \
    -v "$(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf" \
    -v "$(pwd)/nginx/html:/etc/nginx/html/index.html" \
    --network=nginx \
    --restart unless-stopped \
    nginx
  ```

  Nginx is used to render a simple website at <http://docker.local>.

  - <https://stackoverflow.com/a/38783433/326984>
  - <https://github.com/ream88/nginx-test>

## Setup

- Download and flash [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/) onto a Micro SD card with at least 8 GB.
- Mount the SD card. It will appear at `/Volumes/boot`.
- Run `setup.sh`. This script enables SSH and configures the Wi-Fi connection.
- Insert the SD card into the Raspberry Pi and boot it.
- Try connecting to it via `ssh pi@raspberrypi.local`.
- Change the hostname to `docker` by editing both `/etc/hosts` and `/etc/hostname`.
- Run `ssh-copy-id -i ~/.ssh/uhermariogmailcom.pub pi@docker.local`.
- Install Docker:

  ```sh
  curl -sSL https://get.docker.com | sh
  sudo usermod -aG docker pi
  ```

## Links

- <https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl>
- <https://howchoo.com/g/ndy1zte2yjn/how-to-set-up-wifi-on-your-raspberry-pi-without-ethernet>
- <https://howchoo.com/g/ote0ywmzywj/how-to-enable-ssh-on-raspbian-without-a-screen>

## License

[MIT](LICENSE.md)
