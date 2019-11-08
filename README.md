# edi-pi

Debian tool chain and image generation for the Raspberry Pi 2 and 3.

## Introduction

The edi configuration contained in this repository can be used to
generate the following artifacts:

* A pure Debian buster arm64 (64bit) image suitable for the Raspberry Pi 3.
* A pure Debian buster armhf (32bit) image suitable for the Raspberry Pi 2 or 3.
* Matching Mender update artifacts for the above configurations.
* An amd64/arm64 or amd64/armhf based LXD container with a pre-installed
cross development toolchain for C and C++.
* An emulated arm64 or armhf LXD container.

## Important Note

edi-pi is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

edi-pi is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

Please note that image generation operations require superuser privileges
and therefore you can easily break your host operating system. Therefore
make sure that you have a backup copy of your data.

## Acknowledgment

edi-pi would not be possible without the fantastic Raspberry Pi community.
Special thanks go to the people behind those two projects:

* [Advanced Debian "jessie", "stretch" and "buster" bootstrap script for RPi2/3.](https://github.com/drtyhlpr/rpi23-gen-image)
* [Raspberry Pi 3 Debian Image Specification.](https://github.com/Debian/raspi3-image-spec)


## Basic Usage

### Preparation

Prior to using edi-pi you have to install [edi](https://www.get-edi.io)
according to
[this instructions](https://docs.get-edi.io/en/latest/getting_started.html).
Please take a careful look at the "Setting up ssh Keys" section since you
will need a proper ssh key setup in order to access the container or
the Rasperry Pi using ssh.

The image post processing commands require some additional tools. On
Ubuntu 18.04 those tools can be installed as follows:

``` bash
sudo apt install e2fsprogs dosfstools bmap-tools mtools parted
```

To generate the Mender update artifact, the [mender-artifact](https://docs.mender.io/2.2/downloads)
tool is required. Please download the standalone binary and make it visible and executable:

``` bash
sudo cp ~/Downloads/mender-artifact /usr/local/bin/
sudo chmod +x /usr/local/bin/mender-artifact
```

### Creating a Raspberry Pi Image

A Raspberry Pi image can be created using the following command:

For Raspberry Pi 3, arm64:

``` bash
sudo edi -v image create pi3-buster-arm64.yml
```

For Raspberry Pi 2, armhf:

``` bash
sudo edi -v image create pi2-buster-armhf.yml
```

For Raspberry Pi 3, armhf:

``` bash
sudo edi -v image create pi3-buster-armhf.yml
```

The resulting image can be copied to a SD card (here /dev/mmcblk0)
using the following command
(**Please note that everything on the SD card will be erased!**):

For Raspberry Pi 3, arm64:

``` bash
sudo bmaptool copy artifacts/pi3-buster-arm64.img /dev/mmcblk0
```

For Raspberry Pi 2, armhf:

``` bash
sudo bmaptool copy artifacts/pi2-buster-armhf.img /dev/mmcblk0
```

For Raspberry Pi 3, armhf:

``` bash
sudo bmaptool copy artifacts/pi3-buster-armhf.img /dev/mmcblk0
```

If the command fails, unmount the flash card and repeat the above command.

Once you have booted the Raspberry Pi using this SD card you can
access it using ssh (the access should be granted thanks to to your
ssh keys):

``` bash
ssh pi@IP_ADDRESS
```

The password for the user _pi_ is _raspberry_ (just in case you want to
execute a command using `sudo` or login via a local terminal).

### Creating a Cross Development LXD Container

A cross development container can be created using the
following command:

For the Raspberry Pi 3, amd64/arm64:

``` bash
sudo edi -v lxc configure edi-pi-cross-dev-buster pi3-buster-arm64-cross-dev.yml
```

For the Raspberry Pi 2 or 3, amd64/armhf:

``` bash
sudo edi -v lxc configure edi-pi-cross-dev-buster pi23-buster-armhf-cross-dev.yml
```

The container can be accessed as follows (the password is _ChangeMe!_):

``` bash
lxc exec edi-pi-cross-dev-buster -- login ${USER}
```

Or with ssh (Hint: retrieve IP_OF_CONTAINER with `lxc list`):

``` bash
ssh IP_OF_CONTAINER
```

You can directly start to cross compile applications:


For the Raspberry Pi 3, arm64:

``` bash
aarch64-linux-gnu-g++ ...
```

For the Raspberry Pi 2 or 3, armhf:

``` bash
arm-linux-gnueabihf-g++
```

For your convenience, the LXD container shares the folder _edi-workspace_
with the host operating system.

### Creating an Emulated Development LXD Container

The following command generates an emulated container:

For the Raspberry Pi 3, arm64:

``` bash
sudo edi -v lxc configure edi-pi-arm64-dev-buster pi3-buster-arm64-dev.yml
```

For the Raspberry Pi 2 or 3, armhf:

``` bash
sudo edi -v lxc configure edi-pi-armhf-dev-buster pi23-buster-armhf-dev.yml
```

As above, you can access the container as follows (the password is _ChangeMe!_):

For the Raspberry Pi 3, arm64:

``` bash
lxc exec edi-pi-arm64-dev-buster -- login ${USER}
```

For the Raspberry Pi 2 or 3, armhf:

``` bash
lxc exec edi-pi-armhf-dev-buster -- login ${USER}
```

Please note that no services get started in the emulated container and thus
no ssh access will be possible.

To enable networking within the emulated container use the following command
to bring up the default network interface:

``` bash
sudo ip link set eth0 up && sudo dhclient eth0
```

### More Information

For more information please read the [edi documentation](https://docs.get-edi.io) and 
[this blog post](https://www.get-edi.io/A-new-Approach-to-Operating-System-Image-Generation/).

For details about the Mender based robust update integration please refer to this
[blog post](https://www.get-edi.io/Updating-a-Debian-Based-IoT-Fleet/).

If you are curious about the U-Boot bootloader setup please take a look at this
[blog post](https://www.get-edi.io/Booting-Debian-with-U-Boot/).
