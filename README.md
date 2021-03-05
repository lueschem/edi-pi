# edi-pi

Debian tool chain and image generation for the Raspberry Pi 2, 3 and 4.

<img alt="Raspberry Pi" src=https://www.get-edi.io/assets/images/blog/pi-hardware.png width="75%"/>


## Introduction

The edi configuration contained in this repository can be used to
generate the following artifacts:

* A Debian buster arm64 (64bit) image suitable for the Raspberry Pi 3 or 4.
* A Debian buster armhf (32bit) image suitable for the Raspberry Pi 2 or 3.
* Matching Mender update artifacts for the above configurations.
* An amd64/arm64 or amd64/armhf based LXD container with a pre-installed
cross development toolchain for C and C++.
* An emulated arm64 or armhf LXD container.

:warning: **Raspberry Pi 4 boot loader**: On the Raspberry Pi 4 the
[stock boot loader](https://github.com/raspberrypi/firmware)
does load the device tree binary and modifies it. For this reason it is difficult to
do a robust update of the kernel together with the device tree binary. For now, edi-pi
does not touch the device tree binary that gets loaded by the stock boot loader during
a robust update and the boot process will just take over the device tree that got loaded
by the stock boot loader instead of taking the one that gets bundled with the kernel.
This might be a setup that is not sustainable for industrial applications that require
long term support. For such scenarios you might want to consider other platforms such as
[edi-var](https://github.com/lueschem/edi-var/) and
[edi-cl](https://github.com/lueschem/edi-cl/). If I find a solid solution for the described
boot loader issue I will update the configuration accordingly.

## Important Note

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
sudo apt install e2fsprogs dosfstools bmap-tools mtools parted zerofree python3-sphinx
```

To generate the Mender update artifact, the [mender-artifact](https://docs.mender.io/downloads#mender-artifact)
tool is required. For Ubuntu Bionic and Debian Stretch please [download](https://docs.mender.io/downloads#mender-artifact)
the standalone binary and make it visible and executable:

``` bash
sudo cp ~/Downloads/mender-artifact /usr/local/bin/
sudo chmod +x /usr/local/bin/mender-artifact
```

If you are on Ubuntu Focal or Debian Buster or newer you can also use the following command to install
mender-artifact:

``` bash
sudo apt install mender-artifact
```

### Creating a Raspberry Pi Image

A Raspberry Pi image can be created using the following command:

For Raspberry Pi 4, arm64:

``` bash
sudo edi -v image create pi4-buster-arm64.yml
```

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

For Raspberry Pi 4, arm64:

``` bash
sudo bmaptool copy artifacts/pi4-buster-arm64.img /dev/mmcblk0
```

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

For the Raspberry Pi 3 or 4, amd64/arm64:

``` bash
sudo edi -v lxc configure edi-pi-cross-dev-buster pi-buster-arm64-cross-dev.yml
```

For the Raspberry Pi 2, 3 or 4, amd64/armhf:

``` bash
sudo edi -v lxc configure edi-pi-cross-dev-buster pi-buster-armhf-cross-dev.yml
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


For the Raspberry Pi 3 or 4, arm64:

``` bash
aarch64-linux-gnu-g++ ...
```

For the Raspberry Pi 2, 3 or 4, armhf:

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

For the Raspberry Pi 3, armhf:

``` bash
sudo edi -v lxc configure edi-pi-armhf-dev-buster pi3-buster-armhf-dev.yml
```

As above, you can access the container as follows (the password is _ChangeMe!_):

For the Raspberry Pi 3, arm64:

``` bash
lxc exec edi-pi-arm64-dev-buster -- login ${USER}
```

For the Raspberry Pi 3, armhf:

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

## Documenting an Artifact

During the image build the documentation gets rendered to artifacts/CONFIGNAME_documentation
as reStructuredText. The text files can be transformed into a nice pdf file with some
additional tools that need to be installed first:

``` bash
sudo apt install texlive-latex-recommended texlive-pictures texlive-latex-extra latexmk
```

Then the pdf can be generated using the following commands:

``` bash
cd artifacts/CONFIGNAME_documentation
make latexpdf
```

### More Information

For more information please read the [edi documentation](https://docs.get-edi.io) and
[this blog post](https://www.get-edi.io/A-new-Approach-to-Operating-System-Image-Generation/).

For details about the Mender based robust update integration please refer to this
[blog post](https://www.get-edi.io/Updating-a-Debian-Based-IoT-Fleet/).

If you are curious about the U-Boot bootloader setup please take a look at this
[blog post](https://www.get-edi.io/Booting-Debian-with-U-Boot/).
