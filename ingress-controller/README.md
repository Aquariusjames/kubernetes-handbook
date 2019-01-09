# Handbook for ingress controller

## Install Ingress-Nginx

Change service-node-port-range to cover 80 and 443 on master node

```bash
vim /etc/kubernetes/manifests/kube-apiserver.yaml
#  - --service-node-port-range=1-65535
```

### Public traffic

```bash
helm install --name public-porter \
    --namespace nginx-ingress \
    --set rbac.create=true \
    --set controller.ingressClass=public-nginx \
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.http=80 \
    --set controller.service.nodePorts.https=443 \
    --set controller.image.repository=registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller \
    --set defaultBackend.image.repository=registry.cn-hangzhou.aliyuncs.com/google_containers/defaultbackend \
    stable/nginx-ingress

# helm upgrade public-porter stable/nginx-ingress \
#     --namespace nginx-ingress \
#     --set rbac.create=true \
#     --set controller.ingressClass=public-nginx \
#     --set controller.service.type=NodePort \
#     --set controller.service.nodePorts.http=80 \
#     --set controller.service.nodePorts.https=443 \
#     --set controller.image.repository=registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller \
#     --set defaultBackend.image.repository=registry.cn-hangzhou.aliyuncs.com/google_containers/defaultbackend \

# helm delete public-porter --purge
```

### Internal traffic

```bash
helm install --name internal-porter \
    --namespace nginx-ingress \
    --set rbac.create=true \
    --set controller.ingressClass=internal-nginx \
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.http=30080 \
    --set controller.service.nodePorts.https=30443 \
    --set controller.image.repository=registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller \
    --set defaultBackend.image.repository=registry.cn-hangzhou.aliyuncs.com/google_containers/defaultbackend \
    stable/nginx-ingress

# helm upgrade internal-porter stable/nginx-ingress \
#     --namespace nginx-ingress \
#     --set rbac.create=true \
#     --set controller.ingressClass=internal-nginx \
#     --set controller.service.type=NodePort \
#     --set controller.service.nodePorts.http=30080 \
#     --set controller.service.nodePorts.https=30443 \
#     --set controller.image.repository=registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller \
#     --set defaultBackend.image.repository=registry.cn-hangzhou.aliyuncs.com/google_containers/defaultbackend \

# helm delete internal-porter --purge
```

### By kubectl

[See more details.](https://kubernetes.github.io/ingress-nginx/deploy/)

## Ingress Resource

### Internal ingresses

Open all service for operator by internal ingress controller

```bash
kubectl apply -f devk8s-ingress.yaml
```

### Examples

See ingresses folder.

### For HTTPS

```bash
kubectl create secret tls tls-secret --key tls.key --cert tls.crt
```

### Multiple Ingress Controller

1. set controller.ingressClass
2. set annotations: kubernetes.io/ingress.class: "internal-nginx"

[See more details](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/multiple-ingress.md)

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  hosts:
    - $RELEASE_HOSTNAME
  tls:
    - secretName: $RELEASE_NAME-tls
      hosts:
        - $RELEASE_HOSTNAME
```