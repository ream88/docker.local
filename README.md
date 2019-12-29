# raspberrypi.local

This is the setup for my Raspberry Pi Zero W running on `raspberrypi.local`. At the
moment its only purpose is running as a Docker host for various projects
including:

- [unifi](https://github.com/ream88/unifi)

  UniFi Network Management Controller software for my UAP-AC-PROs.
  Accessible at https://raspberrypi.local:8443

## Usage

- Flash Raspbian Lite onto a Micro SD card.
- Mount the SD card. It will appear at `/Volumes/boot`.
- Run `setup.sh`. This script enables SSH and configures the Wi-Fi connection.
- Insert the SD card into the Raspberry Pi.

## Links

- https://howchoo.com/g/ndy1zte2yjn/how-to-set-up-wifi-on-your-raspberry-pi-without-ethernet
- https://howchoo.com/g/ote0ywmzywj/how-to-enable-ssh-on-raspbian-without-a-screen

## License

[MIT](LICENSE.md)
