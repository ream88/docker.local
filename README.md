# docker.mariouher.com

This is the setup for my Raspberry Pi ~~Zero W~~ 3B (turns out the ARMv6
architecture is not supported by [LinuxServer](https://linuxserver.io) anymore)
running on `docker.mariouher.com`. At the moment its only purpose is running as a Docker
host for various projects including:

- ### [acme.sh](https://github.com/Neilpang/acme.sh/wiki/Run-acme.sh-in-docker#3-run-acmesh-as-a-docker-daemon)

  Automatic certificates for the Raspberry Pi. Thx to **@splagemann** for the
  tip!

  acme.sh does not provide a Docker image for ARMv7 yet, so you have to build it on your own:

  ```
  docker build -t acme.sh .

  docker run -itd \
    -v "$(pwd)/certs":/acme.sh \
    --net=host \
    --name=acme.sh \
    --env GANDI_LIVEDNS_KEY \
    --restart unless-stopped \
    acme.sh daemon

  docker exec acme.sh --issue --dns dns_gandi_livedns -d docker.mariouher.com
  ```

  Ensure [`GANDI_LIVEDNS_KEY`](https://github.com/Neilpang/acme.sh/wiki/dnsapi#18-use-gandi-livedns-api)
  is set so [Gandi DNS](https://github.com/Neilpang/acme.sh/wiki/dnsapi#18-use-gandi-livedns-api)
  is properly configured before running any certificate issue/renewal.

- ### [unifi](https://github.com/ream88/unifi)

  UniFi Network Management Controller software for my UAP-AC-PROs.
  Accessible at https://docker.mariouher.com:8443

  ```
  docker exec unifi-controller \
    openssl pkcs12 -export -passout pass:aircontrolenterprise \
      -in /home/certs/docker.mariouher.com.cer \
      -inkey /home/certs/docker.mariouher.com.key \
      -out /home/certs/chain.pem \
      -name unifi

  docker exec unifi-controller \
    keytool -trustcacerts -importkeystore \
      -deststorepass aircontrolenterprise \
      -destkeypass aircontrolenterprise \
      -destkeystore data/keystore \
      -srckeystore /home/certs/chain.pem \
      -srcstoretype PKCS12 \
      -srcstorepass aircontrolenterprise \
      -alias unifi \
      -noprompt
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

- https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl
- https://howchoo.com/g/ndy1zte2yjn/how-to-set-up-wifi-on-your-raspberry-pi-without-ethernet
- https://howchoo.com/g/ote0ywmzywj/how-to-enable-ssh-on-raspbian-without-a-screen

## License

[MIT](LICENSE.md)
