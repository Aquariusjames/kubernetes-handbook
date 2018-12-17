# Helm handbook

## Installing Helm

There are two parts to Helm: The Helm client (helm) and the Helm server (Tiller). [See more details](https://docs.helm.sh/using_helm/#installing-helm)

### INSTALLING THE HELM CLIENT

From Snap (Linux)

```bash
sudo snap install helm --classic
```

From Homebrew (macOS)

```bash
brew install kubernetes-helm
```

### INSTALLING TILLER

Create a serviceaccount for tiller

```yaml
# ./role_bindings/tiller-clusteradmin-crb.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

```bash
kubectl create -f ./tiller-clusteradmin-crb.yaml
```

```bash
helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.11.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts --service-account tiller
```

### Securing a Helm installation

[See More Details](https://docs.helm.sh/using_helm/#securing-your-helm-installation)
