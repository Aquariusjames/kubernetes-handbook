# Set System for kubernetes

## Setting DNS

```bash
echo nameserver 1.2.4.8 > /etc/resolvconf/resolv.conf.d/head

resolvconf --enable-updates
resolvconf -u
```

## Time Date Control

```bash
timedatectl set-timezone "Asia/Shanghai"

vim /etc/systemd/timesyncd.conf
# Content
NTP=server ntp1.aliyun.com 1.ubuntu.pool.ntp.org

# systemd-timesyncd与ntp不能共存
systemctl stop ntp
systemctl disable ntp
# Or
systemctl stop ntpd
systemctl disable ntpd

# Optional
apt remove ntp

systemctl restart systemd-timesyncd.service

systemctl status systemd-timesyncd.service
```

## Turn off swap

```bash
swapoff -a

# comment swap config line
vim /etc/fstab
# For example
# swap was on /dev/xvda5 during installation
# UUID=de5ff52f-ffb9-41b5-9061-aeb60a21dab7 none            swap    sw              0       0

# 防止在内存紧张时kswapd0进程疯狂占用CPU
sysctl vm.swappiness=0

# Configure permanently
vim /etc/sysctl.conf
# net.ipv4.conf.all.arp_notify = 1
# net.ipv4.conf.default.arp_notify = 1
# net.ipv4.conf.eth0.arp_notify = 1
# net.ipv4.conf.lo.arp_notify = 1
# vm.swappiness = 0

sysctl -p
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

## Network

For static IP and consistent default network interface

```bash
vim /etc/network/interfaces

# Content
auto eth0
iface eth0 inet static
  address 192.168.138.175 # ip for 10 route
  netmask 255.255.255.0
  broadcast 192.168.138.255
  dns-nameservers 1.2.4.8

auto eth1
iface eth1 inet static
  address 192.168.137.103 # ip for 134 route, avaliable default when using static ip
  netmask 255.255.255.0
  broadcast 192.168.137.255
  gateway 192.168.137.1
  dns-nameservers 1.2.4.8

up route add -net 10.0.0.0 netmask 255.0.0.0 gw 192.168.138.1 # add 10 route for booting
```

## Partition disk

partition /dev/xvda

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
