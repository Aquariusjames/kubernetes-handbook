# Handbook for deploying Kubernetes Cluster

## Operations on every server

### Initializing operate system

1. [Initialize ubuntu18.04](./ubuntu18.04/README.md)

### Container runtime interface

1. [Deploy docker](./docker/README.md)

### Bootstraping kubernetes cluster

Decided blew choices by yourself.

1. Choose use external etcd cluster or not
2. Choose `single master solution` or `highly available solution`

#### Optional: external etcd cluster

1. TODO: [Deploy external etcd cluster](./etcd/README.md)

#### Single master solution

1. [Deploy single master kubernetes cluster](./smkubernetes/README.md)

#### Highly available solution

TODO: Lack of some required infrastructure in our cloud enviroment, including virtual ip, load blancer and so on. So we decide to pause testing this solution

1. ~~[Deploy highly available kubernetes cluster](./hakubernetes/README.md)~~

## Operations on kubernetes cluster

### User management

1. [RBAC](./rbac/README.md)

### Application management tool

1. [Deploy helm](./helm/README.md)

### Storage provider

1. [Deploy rook ceph in kubernetes cluster](./rook/README.md)
2. TODO: Gluster(not required)

### Infrastructure of operating and monitoring

1. [EFK for logging](./efk/README.md)
2. [Prometheus for metrics](./metrics/README.md)
3. [Kubernetes dashboard]()
4. [Ingress controller]()
5. Optional: [Certificates manager]()

### Microservice components

1. [Jaeger]()

## Operations of cluster

### Modify node

### Backup