#!/bin/bash




IMAGE=lede-17.01.0-r3205-59508e3-armvirt-zImage-initramfs
LAN=ledetap0

create_system() {
# create tap interface which will be connected to OpenWrt LAN NIC
ip tuntap add mode tap $LAN
ip link set dev $LAN up
# configure interface with static ip to avoid overlapping routes                         
ip addr add 192.168.1.101/24 dev $LAN
qemu-system-arm \
    -device virtio-net-pci,netdev=lan \
    -netdev tap,id=lan,ifname=$LAN,script=no,downscript=no \
    -device virtio-net-pci,netdev=wan \
    -netdev user,id=wan \
    -M virt -nographic -m 64 -kernel $IMAGE
}

clean_system() {
# cleanup. delete tap interface created earlier
ip addr flush dev $LAN
ip link set dev $LAN down
ip tuntap del mode tap dev $LAN
}


case "$1" in
"create")
    create_system
    ;;
"clean")
    clean_system
    ;;
*)
    echo "Help:"
    echo "clean  - clean system"
    echo "create - run qemu system"
    ;;
esac

