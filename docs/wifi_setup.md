# WiFi Setup

As the SSID and password for the WiFi connection are usually unknown during the image build, the WiFi interface (wlan0)
is initially not configured.

## Initial Configuration

It is recommended to configure the WiFi interface using NetworkManager. Please replace
"SSID" and "PASSWORD" as required by your local wireless LAN setup and replace "CONNECTION-NAME" with
a meaningful name:

```
sudo nmcli radio wifi on
sudo nmcli dev wifi con "SSID" password "PASSWORD" name "CONNECTION-NAME"
```

## Configuration Handling During a Mender Upgrade

As the gateway might only be connected through WiFi it is essential that the WiFi connection gets re-established
immediately after the OS upgrade. For this reason the NetworkManager connections get backed up to
`/data/backup/NetworkManager` during a Mender based OS upgrade. The new OS image will then re-apply this
NetworkManager connections.
