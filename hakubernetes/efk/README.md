# EFK handbook

## Install Elasticsearch

Reference [Production Grade Elasticsearch on Kubernetes](https://imti.co/kubernetes-production-elasticsearch/)

```bash
kubectl create namespace efk

kubectl create -f elasticsearch.yaml
```

## Install Kibana

```bash
kubectl create -f kibana.yaml
```

For testing

```bash
kubectl port-forward ${kibana_pod_name} 5601 -n efk
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