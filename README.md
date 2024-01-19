# edi Project Configuration for Raspberry Pi Devices

Debian tool chain and image generation for the Raspberry Pi 2, 3, 4 and 5.

<img alt="Raspberry Pi" src=https://www.get-edi.io/assets/images/blog/pi-hardware.png width="75%"/>

> [!NOTE]
> The *master* branch is currently basing upon Debian *bookworm*.
> For Debian *bullseye* please check out the *debian_bullseye* branch. 

## Introduction

The edi configuration contained in this repository can be used to
generate the following artifacts:

* A Debian bookworm arm64 (64bit) image suitable for the Raspberry Pi 3, 4 or 5.
* A Debian bookworm armhf (32bit) image suitable for the Raspberry Pi 2.
* Matching Mender update artifacts for the above configurations.
* An LXD container with a pre-installed cross development toolchains (armhf/arm64) for C and C++.

> [!NOTE]
> **Raspberry Pi 5**: The Raspberry Pi 5 integration is brand new and might still come with a few glitches.

> [!WARNING]
> **New Raspberry Pi 4 bootloader integration**: Starting with Debian bullseye
> the Raspberry Pi 4 setup in regard to the bootloader integration has changed: Instead of
> U-Boot the setup now directly relies upon the Raspberry Pi bootloader. The new "tryboot feature"
> together with a custom Mender integration allowed us to solve the
> [device tree handling during A/B updates issue](https://github.com/lueschem/edi-pi/issues/23). To
> make use of this new setup a
> [recent (>=2021-04-19) bootloader EEPROM](https://github.com/raspberrypi/rpi-eeprom/blob/master/firmware/release-notes.md)
> is required. **Please upgrade your Raspberry Pi 4 EEPROM prior to using this new setup.**
> Unfortunately this **new bootloader integration is incompatible with the previous setup**.
> Additional work would be required to migrate an existing installation over the air from the previous
> setup to this new setup. At the moment an existing installation using the old bootloader setup will need to be re-flashed.

## Important Note

Please note that image generation operations require superuser privileges,
and therefore you can easily break your host operating system. Therefore,
make sure that you have a backup copy of your data.

## Acknowledgment

edi-pi would not be possible without the fantastic Raspberry Pi community.
Special thanks go to the people behind those two projects:

* [Advanced Debian "jessie", "stretch" and "buster" bootstrap script for RPi2/3.](https://github.com/drtyhlpr/rpi23-gen-image)
* [Raspberry Pi 3 Debian Image Specification.](https://github.com/Debian/raspi3-image-spec)


## Basic Usage

### Preparation

Prior to using this edi project configuration you have to install
[edi](https://www.get-edi.io) according to
[this instructions](https://docs.get-edi.io/en/latest/getting_started.html).
Please take a careful look at the "Setting up ssh Keys" section since you
will need a proper ssh key setup in order to access the container or
the target device using ssh.

The image post-processing commands require some additional tools. On
Ubuntu 20.04 and newer those tools can be installed as follows:

``` bash
sudo apt install e2fsprogs dosfstools bmap-tools mtools parted rsync zerofree python3-sphinx mender-artifact
```

### Creating a Raspberry Pi Image

A Raspberry Pi image can be created using the following command:

For Raspberry Pi 5, arm64:

``` bash
sudo edi -v image create pi5.yml
```

For Raspberry Pi 5, arm64, prepared for GitOps (git and Ansible preinstalled):

``` bash
sudo edi -v image create pi5-gitops.yml
```


For Raspberry Pi 4, arm64:

``` bash
sudo edi -v image create pi4.yml
```

For Raspberry Pi 4, arm64, prepared for GitOps (git and Ansible preinstalled):

``` bash
sudo edi -v image create pi4-gitops.yml
```

For Raspberry Pi 3, arm64:

``` bash
sudo edi -v image create pi3.yml
```

For Raspberry Pi 2, armhf:

``` bash
sudo edi -v image create pi2.yml
```

The resulting image can be copied to a SD card (here /dev/mmcblk0)
using the following command
(**Please note that everything on the SD card will be erased!**):

For Raspberry Pi 5, arm64:

``` bash
sudo bmaptool copy artifacts/pi5.img /dev/mmcblk0
```

For Raspberry Pi 4, arm64:

``` bash
sudo bmaptool copy artifacts/pi4.img /dev/mmcblk0
```

For Raspberry Pi 3, arm64:

``` bash
sudo bmaptool copy artifacts/pi3.img /dev/mmcblk0
```

For Raspberry Pi 2, armhf:

``` bash
sudo bmaptool copy artifacts/pi2.img /dev/mmcblk0
```

If the command fails, unmount the flash card and repeat the above command.

Once you have booted the Raspberry Pi using this SD card you can
access it using ssh (the access should be granted thanks to your
ssh keys):

``` bash
ssh pi@IP_ADDRESS
```

The password for the user _pi_ is _raspberry_ (just in case you want to
execute a command using `sudo` or login via a local terminal).

### Connecting to Mender

To enable over the air (OTA) updates, the generated images are configured
to connect to [https://hosted.mender.io/](https://hosted.mender.io/).
In order to connect to your Mender tenant you have to provide your tenant token prior to building the images.
The tenant token can be added to `configuration/mender/mender.yml`. If you do not want to
add the tenant token to the version control system you can also copy `configuration/mender/mender.yml` to
`configuration/mender/mender_custom.yml` and add the tenant token there.

### Creating a Cross Development LXD Container

A cross development container can be created using the
following command:

``` bash
sudo edi -v lxc configure edi-pi-cross-dev-bookworm pi-cross-dev.yml
```

The container can be accessed as follows (the password is _ChangeMe!_):

``` bash
lxc exec edi-pi-cross-dev-bookworm -- login ${USER}
```

Or with ssh (Hint: retrieve IP_OF_CONTAINER with `lxc list`):

``` bash
ssh IP_OF_CONTAINER
```

You can directly start to cross compile applications:


For the Raspberry Pi 3, 4 or 5, arm64:

``` bash
aarch64-linux-gnu-g++ ...
```

For the Raspberry Pi 2, armhf:

``` bash
arm-linux-gnueabihf-g++
```

For your convenience, the LXD container shares the folder _edi-workspace_
with the host operating system.

## Documenting an Artifact

During the image build the documentation gets rendered to artifacts/CONFIGNAME_documentation
as reStructuredText. The text files can be transformed into a nice pdf file with some
additional tools that need to be installed first:

``` bash
sudo apt install texlive-latex-recommended texlive-pictures texlive-latex-extra texlive-xetex latexmk
```

Then the pdf can be generated using the following commands:

``` bash
cd artifacts/CONFIGNAME_documentation
make PDFLATEX=xelatex latexpdf
make PDFLATEX=xelatex latexpdf
```

### More Information

For more information about this setup please read the [edi documentation](https://docs.get-edi.io) and
[this blog post](https://www.get-edi.io/A-new-Approach-to-Operating-System-Image-Generation/).

For details about the Mender based robust update integration please refer to this
[blog post](https://www.get-edi.io/Updating-a-Debian-Based-IoT-Fleet/).

If you are curious about the U-Boot bootloader setup please take a look at this
[blog post](https://www.get-edi.io/Booting-Debian-with-U-Boot/).

For the kernel build instructions related to the Raspberry Pi 4 and 5 please check
[this blog post](https://www.get-edi.io/Getting-Started-with-a-new-Embedded-System/).

The WiFi setup is [documented here](docs/wifi_setup.md).

A GitOps example can be found [here](https://www.get-edi.io/Surprisingly-Easy-IoT-Device-Management/).
