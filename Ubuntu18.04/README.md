# Handbook for Initializing Ubuntu18.04

## Disk

### Fix the GTP

```bash
parted -l
# Warning: Not all of the space available to /dev/xvda appears to be used, you can
# fix the GPT to use all of the space (an extra 104857600 blocks) or continue with
# the current setting?
# Fix/Ignore? Fix
```

### Partition disk

Partition disk `/dev/xvda`

```bash
fdisk /dev/xvda
=> m
=> p
=> F
=> n
```

Run `partprobe` for avoiding reboot

```bash
partprobe
```

### LVM

#### Extend

```bash
pvcreate /dev/xvda4

# Optional
vgextend ubuntu-vg /dev/xvda4

lvextend -l +100%free /dev/mapper/ubuntu--vg-lv_root
resize2fs /dev/mapper/ubuntu--vg-lv_root

df -hl
```

## Network

### Setting DNS configuration

```bash
vim /etc/systemd/resolved.conf
# [Resolve]
# DNS=114.114.114.114 1.2.4.8

systemctl restart systemd-resolved.service
```

### Static IP

```bash
vim /etc/netplan/50-cloud-init.yaml
# network:
#     ethernets:
#         eth0:
#             addresses: [${static_ip_0}/${prefixlength}]
#             dhcp4: false
#             routes:
#             - to: 10.0.0.0/8
#               via: ${gateway_0}
#         eth1:
#             addresses: [${static_ip_1}/${prefixlength}]
#             gateway4: ${default_gateway_1}
#             dhcp4: false
#     version: 2

# Or doing this like blew command
# cat <<EOF >/etc/netplan/50-cloud-init.yaml
# network:
#     ethernets:
#         eth0:
#             addresses: [192.168.94.14/24]
#             dhcp4: false
#             routes:
#             - to: 10.0.0.0/8
#               via: 192.168.94.1
#         eth1:
#             addresses: [192.168.108.133/24]
#             gateway4: 192.168.108.1
#             dhcp4: false
#     version: 2
# EOF
```

An Example

```yaml
network:
    ethernets:
        eth0:
            addresses: [192.168.138.174/24]
            dhcp4: false
            routes:
            - to: 10.0.0.0/8
              via: 192.168.138.1
        eth1:
            addresses: [192.168.137.102/24]
            gateway4: 192.168.137.1
            dhcp4: false
    version: 2
```

Apply the configuration

```bash
netplan apply
```

### Enable IPVS

```bash
# load module <module_name>
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4

# to check loaded modules, use
lsmod | grep -e ipvs -e nf_conntrack_ipv4
# or
cut -f1 -d " "  /proc/modules | grep -e ip_vs -e nf_conntrack_ipv4

apt update
apt install -y ipset

apt install -y ipvsadm
```

## System Paramters

### Verify HOSTNAME

```bash
hostnamectl set-hostname ${$UNIQUE_HOSTNAME}
vim /etc/cloud/cloud.cfg
# FROM:
# preserve_hostname: false
# TO:
# preserve_hostname: true

vim /etc/hosts
# add hosts like following
# 127.0.0.1 master-xxx
# or
# 127.0.0.1 worker-xxx

# For example
# 127.0.0.1       localhost.localdomain   localhost  master-102
# 192.168.137.102 devk8s
# ::1             localhost6.localdomain6 localhost6 master-102

```

### Time Date Control

```bash
# See if systemd-timesyncd.service active, if not, run:
# timedatectl set-ntp on
timedatectl

timedatectl set-timezone "Asia/Shanghai"

# For testing, following command will print "Wed Mar 21 08:00:00 CST 2018"
date 03210800
# To see if time is synced
date
```

### Turn off swap

`Ubuntu18.04` have none default swap

```bash
# 防止在内存紧张时kswapd0进程疯狂占用CPU
sysctl vm.swappiness=0

# Configure permanently
vim /etc/sysctl.conf
# net.ipv4.conf.all.arp_notify = 1
# net.ipv4.conf.default.arp_notify = 1
# net.ipv4.conf.eth0.arp_notify = 1
# net.ipv4.conf.lo.arp_notify = 1
# vm.swappiness = 0

# sysctl -p
```