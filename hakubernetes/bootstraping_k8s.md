# Bootstraping Kubernetes

## Stacked control plane

`IMPORTANT`:all `default` ether/link must be same on every node.

### First control plane node

```bash
vim /etc/hosts
# For example
192.168.137.103 internalk8s.10010sh.cn # main master node
127.0.0.1 master-xxx #hostname
```

```bash
kubeadm init --config=kubeadm-config.yaml
```

`kubeadm-config.yaml` is in `cluster-configuration` folder

Then to control cluster

```bash
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

`Another Options`:

```bash
# temporary
export KUBECONFIG=/etc/kubernetes/admin.conf
```

```bash
# permanent
echo export KUBECONFIG=/etc/kubernetes/admin.conf >> ~/.profile
source ~/.profile
```

### Apply CNI plugin

Use `Flannel`

For flannel to work correctly, you must pass --pod-network-cidr=10.244.0.0/16 to kubeadm init.

Set /proc/sys/net/bridge/bridge-nf-call-iptables to 1 by running sysctl net.bridge.bridge-nf-call-iptables=1 to pass bridged IPv4 traffic to iptables’ chains. This is a requirement for some CNI plugins to work, for more information please see here.

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
```

`IMPORTANT`:Don't Use `Calico` and `Weave`!!!

### SCP key and crt

On main master node

Run [the shell script](./scpca.sh), needs ability of ssh by rsa keys.

```bash
./scpca.sh
```

On other node

```bash
mkdir -p /etc/kubernetes/pki/etcd
mv ~/ca.crt /etc/kubernetes/pki/
mv ~/ca.key /etc/kubernetes/pki/
mv ~/sa.pub /etc/kubernetes/pki/
mv ~/sa.key /etc/kubernetes/pki/
mv ~/front-proxy-ca.crt /etc/kubernetes/pki/
mv ~/front-proxy-ca.key /etc/kubernetes/pki/
mv ~/etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
mv ~/etcd-ca.key /etc/kubernetes/pki/etcd/ca.key
mv ~/admin.conf /etc/kubernetes/admin.conf
```

### Other control plane node

```bash
vim /etc/hosts
# For example
192.168.137.103 internalk8s.10010sh.cn # main master node
127.0.0.1 master-xxx #hostname

192.168.137.254
```

Run the generated command by `First control plane node` section, with option `--experimental-control-plane`

```bash
kubeadm join internalk8s.10010sh.cn:6443 --token u0afgu.br2vucmep0tx7pvz --discovery-token-ca-cert-hash sha256:f0011cd2643256f2828e8b191bc0bd58716d9ce559c9485a269508a3ee08fefc --experimental-control-plane
```

To control cluster

```bash
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

#### Token expired

IF token expired(By default, tokens expire after 24 hours)

```bash
# get token info
kubeadm token list

# create token
kubeadm token create
# The output is similar to this: 5didvk.d09sbcov8ph2amjw

# get hash value
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```

### Master Isolation

By default, your cluster will not schedule pods on the master for security reasons. If you want to be able to schedule pods on the master, e.g. for a single-machine Kubernetes cluster for development, run:

```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Join Worker Node

```bash
kubeadm join internalk8s.10010sh.cn:6443 --token 99kcq5.83n2uj2ohdzxovud --discovery-token-ca-cert-hash sha256:f0011cd2643256f2828e8b191bc0bd58716d9ce559c9485a269508a3ee08fefc
```

## Tear down

```bash
# kubectl drain master-105 --delete-local-data --force --ignore-daemonsets
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>

kubeadm reset

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

ipvsadm --clear
```

## Trouble Shooting

### Recovery cluster with master full down

```bash
kubeadm init --ignore-preflight-errors=all --config=kubeadm-config.yaml
```

[See more details](https://labs.consol.de/kubernetes/2018/05/25/kubeadm-backup.html)