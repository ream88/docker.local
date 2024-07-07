# docker.local

The following configuration is for my Raspberry Pi 3B, which operates on
`docker.local`. Currently, its primary function is to serve as a Docker host for
a range of services, which include:

## Services

- ### [Tailscale](https://tailscale.com)

  ```sh
  # export TS_AUTHKEY=tskey-auth-xxxxxxxxxxxxxxxx

  docker run -d \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --name=tailscale \
  --network=host \
  --restart unless-stopped \
  -e TS_AUTHKEY \
  -e TS_ROUTES=10.0.0.0/24 \
  -e TS_EXTRA_ARGS="--advertise-exit-node" \
  -v /dev/net/tun:/dev/net/tun \
  -v /var/lib:/var/lib \
  tailscale/tailscale
  ```

- ### [Homebridge](https://github.com/oznu/docker-homebridge)

  ```sh
  docker run -itd \
    --name=homebridge \
    --network=host \
    --restart unless-stopped \
    -e HOMEBRIDGE_CONFIG_UI=1 \
    -e HOMEBRIDGE_CONFIG_UI_PORT=8888 \
    -e PGID=1000 \
    -e PUID=1000 \
    -e TZ=Europe/Vienna \
    -v "$HOME/homebridge":/homebridge \
    oznu/homebridge
  ```

  Homebridge is used to enable several appliances in my apartment to be compatible with HomeKit:

  - Nuki Smart Lock using <https://github.com/ream88/homebridge-nuki-latch>.
  - Two [ceiling lights](https://amzn.to/3iQLGHk) controlled using
    [ESPHome](https://esphome.io)-powered [Sonoff Basic
    Switches](https://amzn.to/3mHHUSV) using
    <https://github.com/arachnetech/homebridge-mqttthing>.

- ### [Mosquitto](https://mosquitto.org)

  ```sh
  docker run -itd \
    --name=mosquitto \
    --restart unless-stopped \
    -p 1883:1883 \
    -p 9001:9001 \
    -v "$HOME/mosquitto/mosquitto.conf:"/mosquitto/config/mosquitto.conf \
    eclipse-mosquitto
  ```

  Mosquitto helps connect with my Sonoff lamps using MQTT. Here's the JSON setup
  I used in Homebridge-UI for the lamps:

  ```json
  {
    "type": "lightbulb-OnOff",
    "name": "Fridge",
    "url": "http://10.0.0.254:1883",
    "topics": {
        "getOnline": "fridge/status",
        "getOn": "fridge/switch/sonoff_lamp/state",
        "setOn": "fridge/switch/sonoff_lamp/command"
    },
    "onlineValue": "online",
    "offlineValue": "offline",
    "retryLimit": 3,
    "confirmationIndicateOffline": true,
    "onValue": "ON",
    "offValue": "OFF",
    "accessory": "mqttthing"
  }
  ```

- ### [Pi-hole](https://pi-hole.net)

  ```sh
  # export WEBPASSWORD=password
  
  docker run -itd \
    --dns=1.1.1.1 \
    --dns=127.0.0.1 \
    --name=pihole \
    --network=bridge \
    --restart unless-stopped \
    -e TZ=Europe/Vienna \
    -e VIRTUAL_HOST=docker.local \
    -e WEBPASSWORD \
    -p 53:53/tcp \
    -p 53:53/udp \
    -v "$HOME/etc-dnsmasq.d/":/etc/dnsmasq.d/ \
    -v "$HOME/etc-pihole/":/etc/pihole/ \
    pihole/pihole:latest
  ```

  Also don't forget to connect the `pihole` container to the `nginx` network:

  ```sh
  docker network connect nginx pihole
  ```

  Updating can be done by running the following commands, followed by running
  the above command to recreate the container:

  ```sh
  docker pull pihole/pihole
  docker rm -f pihole
  ```

- ### NGINX

  ```sh
  docker run -itd \
    --name=nginx \
    --network=nginx \
    --restart unless-stopped \
    -p 80:80 \
    -v "$HOME/nginx/dist:/etc/nginx/html" \
    -v "$HOME/nginx/nginx.conf:/etc/nginx/nginx.conf" \
    nginx
  ```

  Nginx is used to render a simple website at <http://docker.local>.

  - <https://stackoverflow.com/a/38783433/326984>
  - <https://github.com/ream88/nginx-test>

  Some useful commands during development:

  ```sh
  make
  rsync -r dist docker.local:/home/pi/nginx/
  rsync nginx.conf docker.local:/home/pi/nginx/
  ssh docker.local 'docker rm -f $(docker ps -qaf name=nginx)'
  ssh docker.local 'docker run -itd \
      --name=nginx \
      --network=nginx \
      -p 80:80 \
      -v "$HOME/nginx/dist:/etc/nginx/html" \
      -v "$HOME/nginx/nginx.conf:/etc/nginx/nginx.conf" \
      nginx'
  ```

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
