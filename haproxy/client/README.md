# Build haproxy service for loading balance K8S api-server

## Over view

[See more details](https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part5/)

## build local haproxy docker images

```bash
docker build -t haproxy-k8s:internal .
```

```bash
docker run --name local-haproxy haproxy-k8s:internal
```

```bash
docker rm local-haproxy
docker rmi haproxy-k8s:internal
```