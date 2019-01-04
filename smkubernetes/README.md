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

On laptop, by this way

Copy `/etc/kubernetes/admin.conf` to laptop, and adjust suitable server IP

```bash
# temporary
export KUBECONFIG=/etc/kubernetes/admin.conf

# permanent
vim ~/.profile # For mac is ~/.bash_profile
# export KUBECONFIG=/etc/kubernetes/admin.conf
```

### Master Isolation

`Note`: Not recommended

By default, your cluster will not schedule pods on the master for security reasons. If you want to be able to schedule pods on the master, e.g. for a single-machine Kubernetes cluster for development, run:

```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Deploy pod network

### Flannel

For flannel to work correctly, you must pass --pod-network-cidr=`10.244.0.0/16` to kubeadm init.

Set /proc/sys/net/bridge/bridge-nf-call-iptables to 1 by running `sysctl net.bridge.bridge-nf-call-iptables=1` to pass bridged IPv4 traffic to iptables’ chains. 

This is a requirement for some CNI plugins to work.

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
```

`IMPORTANT`: Don't Use `Calico` and `Weave` on our cloud enviroment!!!

## Joining worker node

```bash
kubeadm join devk8s:6443 --token px00zp.u9rwoo32fi96w6uc --discovery-token-ca-cert-hash sha256:fd7312a80e1c0d0b3fd2f54221c3fe49cecf945672b5220207615c43c238fc5d
```

If you wanted explict role label for worker node, you can add label for worker node on master node by kubectl

```bash
kubectl label node worker-103 node-role.kubernetes.io/worker=
```

## Tear down

```bash
# kubectl drain master-105 --delete-local-data --force --ignore-daemonsets
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>

kubeadm reset

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

ipvsadm --clear

systemctl restart docker.service
```

## Trouble Shooting

### Recovery cluster with master node down

```bash
kubeadm init --ignore-preflight-errors=all --config=kubeadm-config.yaml
```

[See more details](https://labs.consol.de/kubernetes/2018/05/25/kubeadm-backup.html)

### Token expired

If token expired(By default, tokens expire after 24 hours)

```bash
# get token info
kubeadm token list

# create token
kubeadm token create
# The output is similar to this: 5didvk.d09sbcov8ph2amjw

# get hash value
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'

kubeadm join devk8s:6443 --token ${created_token} --discovery-token-ca-cert-hash sha256:${hash_value}
```

### Remove worker node

```bash
kubectl drain $NODENAME --ignore-daemonsets --delete-local-data

# Make the node schedulable again:
# kubectl uncordon $NODENAME

kubectl delte node $NODENAME
```
