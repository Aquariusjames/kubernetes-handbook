# Handbook for bootstraping single master kubernetes cluster

## Adjusting operate system

### Modify hosts

For master/worker node, add local host of control plane endpoint.

```bash
vim /etc/hosts
# ${control_plane_ip} ${control_plane_domain}
# For example
# 127.0.0.1         master-102
# 192.168.137.102   devk8s
#
# For example
# 127.0.0.1         worker-103
# 192.168.137.102   devk8s
```

## Installing kubernetes suite

* kubeadm: the command to bootstrap the cluster.

* kubelet: the component that runs on all of the machines in your cluster and does things like starting pods and containers.

* kubectl: the command line util to talk to your cluster.

```bash
apt-get update

apt-get install -y apt-transport-https

curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

apt-get update

apt-get install -y kubelet=1.13.1-00 kubeadm=1.13.1-00 kubectl=1.13.1-00
# apt-get upgrade -y kubelet kubeadm kubectl

# prevent the package from being automatically installed, upgraded or removed.
apt-mark hold kubelet kubeadm kubectl
```

If needed, run blew commands

```bash
systemctl daemon-reload
systemctl restart kubelet
```

## Initializing master

```bash
kubeadm init --config=devk8s_init_config.yaml
```

To control cluster

```bash
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

## Deploy pod network

### Flannel

For flannel to work correctly, you must pass --pod-network-cidr=`10.244.0.0/16` to kubeadm init.

Set /proc/sys/net/bridge/bridge-nf-call-iptables to 1 by running `sysctl net.bridge.bridge-nf-call-iptables=1` to pass bridged IPv4 traffic to iptables’ chains. This is a requirement for some CNI plugins to work, for more information please see here.

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
```

`IMPORTANT`:Don't Use `Calico` and `Weave` on our cloud enviroment!!!

## Joining worker node

```bash
kubeadm join devk8s:6443 --token ovzobs.662lwpm3dubrur8g --discovery-token-ca-cert-hash sha256:fd7312a80e1c0d0b3fd2f54221c3fe49cecf945672b5220207615c43c238fc5d
```

If you wanted explict role label for worker node, you can add label for worker node on master node

```bash
kubectl label node worker-103 node-role.kubernetes.io/worker=
```

## Reset

```bash
kubeadm reset

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

ipvsadm --clear

systemctl restart docker.service
```