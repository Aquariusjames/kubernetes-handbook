# EFK handbook

## Install Elasticsearch

Reference [Production Grade Elasticsearch on Kubernetes](https://imti.co/kubernetes-production-elasticsearch/)

```bash
kubectl create namespace efk

kubectl create -f elasticsearch.yaml
```

### Other Options

[See stable elasticsearch](https://github.com/helm/charts/tree/master/stable/elasticsearch)

## Install Kibana

```bash
kubectl create -f kibana.yaml
```

For testing

```bash
kubectl port-forward pod/${kibana_pod_name} 5601 -n efk
```

## Install Fluent Bit

```bash
kubectl create -f fluentbit.yaml
```

Create index `logstash*`

## Install Cerebro

```bash
helm install --name es-admin --namespace efk -f cerebro_values.yaml stable/cerebro
```

For testing

```bash
kubectl port-forward pod/${cerebro_pod_name} 9000 -n efk
```

### Upgrading When ES changed

```bash
helm upgrade es-admin stable/cerebro -f cerebro_values.yaml --namespace efk
```

## Deploy Ingress

```bash
kubectl create -f ingress-efk.yaml
```

### Optional Security

Using Basic Auth, [see more details](https://imti.co/kibana-kubernetes/) on part `Basic Auth`

## TODOs

1. 节点调整时观察到index丢失的情况，需后续跟进