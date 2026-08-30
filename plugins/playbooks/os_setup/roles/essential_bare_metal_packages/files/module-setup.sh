#!/bin/bash

# called by dracut
check() {
    require_binaries lsblk || return 1
    return 0
}

# called by dracut
depends() {
    echo btrfs
    return 0
}

# called by dracut
cmdline() {
    :
}

# called by dracut
installkernel() {
    :
}

# called by dracut
install() {
    inst_hook pre-mount 55 "$moddir/snapshot-rootfs.sh"
}
