# edi Project Configuration for Raspberry Pi Devices

Debian tool chain and image generation for the Raspberry Pi 2, 3, 4 and 5.

<img alt="Raspberry Pi" src=https://www.get-edi.io/assets/images/blog/pi-hardware.png width="75%"/>

> [!NOTE]
> The *master* branch is **experimental** and currently based on Debian *trixie*.
> To get the stable Debian *bookworm* configuration please check out the *debian_bookworm* branch.

## Introduction

The edi configuration contained in this repository can be used to
generate the following artifacts:

* A Debian trixie arm64 (64bit) image suitable for the Raspberry Pi 3, 4 or 5.
* A Debian trixie armhf (32bit) image suitable for the Raspberry Pi 2.
* Matching Mender update artifacts for the above configurations.
* A Podman/Docker image with a pre-installed cross development toolchains (armhf/arm64) for C and C++.

> [!NOTE]
> The Raspberry Pi 3 images are now making use of the tryboot feature too and do no longer
> rely on u-boot to switch the boot partitions. A bookworm or older image is therefore incompatible
> with a trixie or newer image. A migration to the new approach during the upgrade might be possible
> but is currently not implemented. Feel free to write a feature request in case your existing project
> would benefit from such a feature.

## Basic Usage

### Preparation

Prior to using this edi project configuration you have to install
[edi](https://www.get-edi.io) according to
[this instructions](https://docs.get-edi.io/en/stable/getting_started_v2.html).
Please take a careful look at the "Setting up ssh Keys" section since you
will need a proper ssh key setup in order to access the
the target device using ssh.

The artifact generation requires some additional tools. On
Ubuntu 24.04 and newer those tools can be installed as follows:

``` bash
sudo apt install buildah containers-storage crun curl distrobox dosfstools e2fsprogs fakeroot genimage git mender-artifact mmdebstrap mtools parted python3-sphinx python3-testinfra podman rsync zerofree
```

### Cloning this Repository

The edi-pi project configuration contained in this git repository can be cloned as follows:

``` bash
mkdir -p ~/edi-workspace/ && cd ~/edi-workspace/
git clone --recursive https://github.com/lueschem/edi-pi.git
```

The following steps assume that you are located within the project configuration directory:

``` bash
cd ~/edi-workspace/edi-pi/
```

If the repository has already been cloned earlier, do not forget to update the submodules:

``` bash
git submodule update --init
```

### Optional: Connecting to Mender

To enable over the air (OTA) updates, the generated images are configured
to connect to [https://hosted.mender.io/](https://hosted.mender.io/).
In order to connect to your Mender tenant you have to provide your tenant token prior to building the images.
The tenant token can be added to `configuration/mender/mender.yml`. If you do not want to
add the tenant token to the version control system you can also copy `configuration/mender/mender.yml` to
`configuration/mender/mender_custom.yml` and add the tenant token there.

### Creating a Raspberry Pi Image

A Raspberry Pi image can be created using the following command:

For Raspberry Pi 5, arm64:

``` bash
edi -v project make pi5.yml
```

For Raspberry Pi 5, arm64, prepared for GitOps (git and Ansible preinstalled):

``` bash
edi -v project make pi5-gitops.yml
```

For Raspberry Pi 4, arm64:

``` bash
edi -v project make pi4.yml
```

For Raspberry Pi 4, arm64, prepared for GitOps (git and Ansible preinstalled):

``` bash
edi -v project make pi4-gitops.yml
```

For Raspberry Pi 3, arm64:

``` bash
edi -v project make pi3.yml
```

For Raspberry Pi 2, armhf:

``` bash
edi -v project make pi2.yml
```

The resulting image can be copied to a SD card (here /dev/mmcblk0)
using the following command
(**Please note that everything on the SD card will be erased!**):

Example for Raspberry Pi 5, arm64:

``` bash
sudo umount /dev/mmcblk0p?
sudo dd if=artifacts/pi5.img of=/dev/mmcblk0 bs=4M conv=fsync status=progress
```

Once you have booted the Raspberry Pi using this SD card you can
access it using ssh (the access should be granted thanks to your
ssh keys):

``` bash
ssh pi@IP_ADDRESS
```

The password for the user _pi_ is _raspberry_ (just in case you want to
execute a command using `sudo` or login via a local terminal).

### Creating a Cross Development Container

A Podman image of a cross development container can be created using the
following command:

``` bash
edi -v project make pi-cross-dev.yml
```

distrobox can be used to transform the image into a convenient development container:

``` bash
source artifacts/pi-cross-dev_manifest
distrobox create --image ${podman_image} --name SOME_CONTAINER_NAME --init --unshare-all --additional-packages "systemd libpam-systemd"
```

For all the development work the container can be entered as follows:

``` bash
distrobox enter SOME_CONTAINER_NAME
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
[this blog post](https://www.get-edi.io/Rootless-Creation-of-Debian-OS-and-OCI-Images/).

For details about the Mender based robust update integration please refer to this
[blog post](https://www.get-edi.io/Updating-a-Debian-Based-IoT-Fleet/).

If you are curious about the U-Boot bootloader setup please take a look at this
[blog post](https://www.get-edi.io/Booting-Debian-with-U-Boot/).

For the kernel build instructions related to the Raspberry Pi 4 and 5 please check
[this blog post](https://www.get-edi.io/Getting-Started-with-a-new-Embedded-System/).

The WiFi setup is [documented here](docs/wifi_setup.md).

A GitOps example can be found [here](https://www.get-edi.io/Surprisingly-Easy-IoT-Device-Management/).
