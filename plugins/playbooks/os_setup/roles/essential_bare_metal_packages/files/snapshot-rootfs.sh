#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

snapshot_rootfs() {
    local _root="$(getarg root=)"
    local _rootmnt="/rootmnt"
    local _rootfs_type="$(blkid -o value -s TYPE "${_root}")"
    local _rw_snapshot="@"
    if [ "${_rootfs_type}" != "btrfs" ] ; then
        info "no snapshot needed, root ${_root} is of type ${_rootfs_type}"
        return 0
    fi

    mkdir -p "${_rootmnt}"
    mount -t btrfs -o subvolid=5 "${_root}" "${_rootmnt}"
    local _snapshot="$(btrfs subvolume get-default "${_rootmnt}")"
    _snapshot="${_snapshot##* }"
    if [ "${_snapshot}" != "factory" ] ; then
        info "no snapshot needed, root ${_root} already got snapshot ${_snapshot}"
    else
        info "snapshot needed, root ${_root}: ${_snapshot} --> ${_rw_snapshot}"
        btrfs subvolume snapshot "${_rootmnt}"/"${_snapshot}" "${_rootmnt}"/"${_rw_snapshot}"
        btrfs subvolume set-default "${_rootmnt}"/"${_rw_snapshot}"
    fi
    umount "${_rootmnt}"
    return 0
}

snapshot_rootfs
