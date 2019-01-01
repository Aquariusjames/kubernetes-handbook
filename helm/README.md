# Handbook for helm

## Installing helm

There are two parts to Helm: The Helm client (helm) and the Helm server (Tiller). [See more details](https://docs.helm.sh/using_helm/#installing-helm)

### Client

From Snap (Linux)

```bash
sudo snap install helm --classic
```

From Homebrew (macOS)

```bash
brew install kubernetes-helm
# brew info kubernetes-helm
# brew search kubernetes-helm
# brew upgrade kubernetes-helm
```

### Tiller

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
helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.12.1 --stable-repo-url https://burdenbear.github.io/kube-charts-mirror/ --service-account tiller
# see more details on https://github.com/BurdenBear/kube-charts-mirror
# or use https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts, but it is outdated since Nov, 2018
```

#### Tiller already exist

Check stable repo

```bash
helm repo list

# If stable repo is not valid, do following command
helm repo add stable https://burdenbear.github.io/kube-charts-mirror/
```

### Securing a Helm installation

TODO:
[See More Details](https://docs.helm.sh/using_helm/#securing-your-helm-installation)
