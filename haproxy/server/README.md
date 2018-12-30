# Build haproxy service for loading balance K8S api-server

## Over view

[See more details](https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part5/)

## build local haproxy docker images

```bash
docker build -t server-haproxy-k8s:internal .
```

```bash
docker run -d -p 16443:16443 --name local-haproxy server-haproxy-k8s:internal
```

```bash
docker rm local-haproxy
docker rmi server-haproxy-k8s:internal
```