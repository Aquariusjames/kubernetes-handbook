# Handbook for Docker

## Install Docker CE

```bash
apt-get update

apt-get -y install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

apt-cache madison docker-ce

apt-get -y install docker-ce=18.06.1~ce~3-0~ubuntu

# prevent the package from being automatically installed, upgraded or removed.
apt-mark hold docker-ce=18.06.1~ce~3-0~ubuntu
```

## Configurate docker daemon

```bash
# # add registry mirror
# curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io

# # enable JSON log files with logrotation
# vim /etc/docker/daemon.json
# {
#  "registry-mirrors": ["http://f1361db2.m.daocloud.io"],
#  "log-driver": "json-file",
#  "log-opts": {
#    "max-size": "10m",
#    "max-file": "5"
#  }
# }

cat <<EOF >/etc/docker/daemon.json
{
 "registry-mirrors": ["http://f1361db2.m.daocloud.io"],
 "log-driver": "json-file",
 "log-opts": {
   "max-size": "10m",
   "max-file": "5"
 }
}
EOF

systemctl restart docker.service
```