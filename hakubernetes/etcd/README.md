# Set up a High Availability etcd cluster with kubeadm

TODO:

Follow [official tutorial](https://kubernetes.io/docs/setup/independent/setup-ha-etcd-with-kubeadm/)

## Setting up the cluster

Configure the kubelet to be a service manager for etcd.

```bash
cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true
Restart=always
EOF

systemctl daemon-reload
systemctl restart kubelet
```