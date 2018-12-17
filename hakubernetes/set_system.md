# Set System for kubernetes

## Setting DNS

```bash
echo nameserver 1.2.4.8 > /etc/resolvconf/resolv.conf.d/head

resolvconf --enable-updates
resolvconf -u
```

## Time Zone

TODO:

## Turn off swap

```bash
swapoff -a

# comment swap config line
vim /etc/fstab
# For example
# swap was on /dev/xvda5 during installation
# UUID=de5ff52f-ffb9-41b5-9061-aeb60a21dab7 none            swap    sw              0       0
```

## Verify the HOSTNAME, MAC address and product_uuid are unique for every node

* Unique hostname, MAC address, and product_uuid for every node. See [here](https://kubernetes.io/docs/setup/independent/install-kubeadm/#verify-the-mac-address-and-product-uuid-are-unique-for-every-node) for more details.

### Verify HOSTNAME

```bash
hostnamectl set-hostname {$UNIQUE_HOSTNAME}

vim /etc/hosts
## add hosts like following
## 127.0.0.1 master-xxx
## or
## 127.0.0.1 worker-xxx
```

### Verify MAC address

```bash
ip link

# or ifconfig -a
```

### Verify product_uuid

```bash
cat /sys/class/dmi/id/product_uuid
```

## Configure SSH

In order to ssh other master node from main master node conveniently

```bash
# if no private key
ssh-keygen -t rsa -b 4096 -C "your email"

ssh-copy-id -i ~/.ssh/id_rsa.pub ${USER}@${IP}
# ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.137.105
```

## IPVS

Run following command

```bash
cut -f1 -d " " /proc/modules | grep ip_vs
```

If see nothing, then run following command

```bash
for i in ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh; do modprobe $i; done
```

For reboot automatically loading

```bash
vi /etc/modules

# /etc/modules: kernel modules to load at boot time.
#
# This file contains the names of kernel modules that should be loaded
# at boot time, one per line. Lines beginning with "#" are ignored.
ip_vs_rr
ip_vs_wrr
ip_vs_sh
ip_vs
```

## Partition disk

pattition /dev/xvda

```bash
fdisk /dev/xvda

=> m

=> p

=> F

=> n
```

partprobe

```bash
partprobe
```

## Create Logical Volume

```bash
# fdisk partition first
pvcreate /dev/xvda3
vgcreate cloud-native /dev/xvda3
lvcreate -l 100%free -n metadata cloud-native
mkfs.ext4 /dev/cloud-native/metadata
mkdir -p /var/cloud-native/metadata
mount /dev/cloud-native/metadata /var/cloud-native/metadata
lvdisplay
echo /dev/cloud-native/metadata /var/cloud-native/metadata ext4 defaults 0 0 >> /etc/fstab
```