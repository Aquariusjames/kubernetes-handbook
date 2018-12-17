# Kubernetes dashboard handbook

## Install

```bash
# load k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0
docker load -i /var/kubernetes/kubernetes-dashboard-amd64.tar

kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

## Access control

[See more details](https://github.com/kubernetes/dashboard/wiki/Access-control)

For Skipping authorization, deploy following

```yaml
# ./role_bindings/k8s-dashboard-clusteradmin-crb.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:`
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
```

```bash
kubectl create -f ./k8s-dashboard-clusteradmin-crb.yaml
```