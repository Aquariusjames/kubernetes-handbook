# Build highly available kubernetes cluster

## Prerequisite

* One or more machines running one of:
  * Ubuntu 16.04+
  * Debian 9
  * CentOS 7
  * RHEL 7
  * Fedora 25/26 (best-effort)
  * HypriotOS v1.0.1+
  * Container Linux (tested with 1800.6.0)
* 2 GB or more of RAM per machine (any less will leave little room for your apps)
* 2 CPUs or more
* Full network connectivity between all machines in the cluster (public or private network is fine)
* Unique hostname, MAC address, and product_uuid for every node. See [here](https://kubernetes.io/docs/setup/independent/install-kubeadm/#verify-the-mac-address-and-product-uuid-are-unique-for-every-node) for more details.
* Certain ports are open on your machines. See [here](https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports) for more details.
* Swap disabled. You MUST disable swap in order for the kubelet to work properly.
* Default permission is root

## Overview

This document is for indexing build highly available kubernetes cluster, based on kubernetes v1.13.0

[See more details](https://kubernetes.io/docs/setup/independent/high-availability/)

1. [System Settings](./set_system.md)
2. [Install Docker CE](./install_docker.md)
3. [Install Kubernetes Components](./install_k8s_components.md)
4. [Bootstraping Kubernetes](./bootstraping_k8s.md)
5. [Install Helm](./helm/README.md)

## Build client haproxy

TODO:
See haproxy>client folder README.md
