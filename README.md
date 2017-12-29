# edi-pi

Debian tool chain and image generation for the Raspberry Pi 3.

## Introduction

The edi configuration contained in this repository can be used to
generate the following artifacts:

* A pure Debian stretch arm64 image for the Raspberry Pi 3.
* An amd64/arm64 based LXD container with a pre-installed cross development
toolchain for C and C++.
* An emulated arm64 LXD container.

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

## Acknowledgement

edi-pi would not be possible without the fantastic Raspberry Pi community.
Special thanks go to the people behind those two projects:

* [Advanced Debian "jessie", "stretch" and "buster" bootstrap script for RPi2/3.](https://github.com/drtyhlpr/rpi23-gen-image)
* [Raspberry Pi 3 Debian Image Specification.](https://github.com/Debian/raspi3-image-spec)


## Basic Usage

### Preparation

Prior to using edi-pi you have to install [edi](http://www.get-edi.io)
according to
[this instructions](http://docs.get-edi.io/en/latest/getting_started.html).

The image post processing commands require some additional tools. On
Ubuntu 16.04 those tools can be installed as follows:

``` bash
sudo apt install e2fsprogs dosfstools bmap-tools
```

### Creating a Raspberry Pi 3 Image

A Raspberry Pi 3 image can be created using the following command:

``` bash
sudo edi -v image create pi3-stretch-arm64.yml
```

The resulting image can be copied to a SD card (here /dev/mmcblk0)
using the following command
(**Please note that everything on the SD card will be erased!**):

``` bash
sudo bmaptool copy artifacts/pi3-stretch-arm64.img /dev/mmcblk0
```

If the command fails, unmount the flash card and repeat the above command.

Once you have booted the Raspberry Pi 3 using this SD card you can
access it using ssh (password is _raspberry_):

``` bash
ssh pi@IP_ADDRESS
```

### Creating a Cross Development LXD Container

An amd64/arm64 cross development container can be created using the
following command:

``` bash
sudo edi -v lxc configure edi-pi-cross-dev pi3-stretch-arm64-cross-dev.yml
```

The container can be accessed as follows (the password is _ChangeMe!_):

``` bash
lxc exec edi-pi-cross-dev -- login ${USER}
```

You can directly start to cross compile applications:

``` bash
aarch64-linux-gnu-g++ ...
```

For your convenience, the LXD container shares the folder _edi-workspace_
with the host operating system.

### Creating an Emulated Development LXD Container

The following command generates an emulated arm64 container:

``` bash
sudo edi -v lxc configure edi-pi-dev pi3-stretch-arm64-dev.yml
```

As above, you can access the container as follows (the password is _ChangeMe!_):

``` bash
lxc exec edi-pi-dev -- login ${USER}
```

### More Information

For more information please read the [edi documentation](http://docs.get-edi.io) and 
[this blog post](http://www.get-edi.io/A-new-Approach-to-Operating-System-Image-Generation/).
