# Install kubernetes components

## Installing kubeadm, kubelet and kubectl

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

apt-get install -y kubelet kubeadm kubectl
# apt-get upgrade -y kubelet kubeadm kubectl

# prevent the package from being automatically installed, upgraded or removed.
apt-mark hold kubelet kubeadm kubectl
```

If needed

```bash
systemctl daemon-reload
systemctl restart kubelet
```

## Download docker images

Download docker images used by kubernetes.

run follow command to see detail images

```bash
kubeadm config images list --kubernetes-version=v1.13.0
# k8s.gcr.io/kube-apiserver:v1.13.0
# k8s.gcr.io/kube-controller-manager:v1.13.0
# k8s.gcr.io/kube-scheduler:v1.13.0
# k8s.gcr.io/kube-proxy:v1.13.0
# k8s.gcr.io/pause:3.1
# k8s.gcr.io/etcd:3.2.24
# k8s.gcr.io/coredns:1.2.6
```

Save images to tarball

```bash
docker save \
k8s.gcr.io/kube-apiserver:v1.13.0 \
k8s.gcr.io/kube-controller-manager:v1.13.0 \
k8s.gcr.io/kube-scheduler:v1.13.0 \
k8s.gcr.io/kube-proxy:v1.13.0 \
k8s.gcr.io/pause:3.1 \
k8s.gcr.io/etcd:3.2.24 \
k8s.gcr.io/coredns:1.2.6 \
-o kubeadm-k8s-v1.13.0.tar
```