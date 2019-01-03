# EFK handbook

## Install Elasticsearch

### Installing es4log

[See stable elasticsearch](https://github.com/helm/charts/tree/master/stable/elasticsearch)

```bash
helm install --name es4log --namespace efk stable/elasticsearch
```

### Upgrading es4log

```bash
# helm upgrade es4log --namespace efk stable/elasticsearch \
#   --set data.replicas=3 \
#   --set data.persistence.size=30Gi
```

### Deleting es4log

```bash
helm delete es4log --purge
```

## Install Kibana

### Installing kibana4log

[See more details](https://github.com/helm/charts/tree/master/stable/kibana)

```bash
helm install --name kibana4log --namespace efk stable/kibana \
    --set env.ELASTICSEARCH_URL=http://es4log-elasticsearch-client:9200
```

For testing

```bash
kubectl port-forward $(kubectl get pod -n efk -l app=kibana -o jsonpath='{.items[0].metadata.name}') -n efk 5601
```

### Upgrading kibana4log

```bash
helm upgrade kibana4log --namespace efk stable/kibana \
    --set env.ELASTICSEARCH_URL=http://es4log-elasticsearch-client:9200
```

### Deleting kibana4log

```bash
helm delete kibana4log --purge
```

## Install Fluent Bit

```bash
kubectl apply -f fluentbit.yaml
```

## Install Cerebro

### Installing Cerebro

```bash
helm install --name cerebro4log --namespace efk -f cerebro_values.yaml stable/cerebro
```

For testing

```bash
kubectl port-forward $(kubectl get pods --namespace efk -l "app=cerebro,release=cerebro4log" -o jsonpath="{.items[0].metadata.name}") 9000 -n efk
```

### Upgrading Cerebro

```bash
helm upgrade cerebro4log stable/cerebro -f cerebro_values.yaml --namespace efk
```

### Deleting Cerebro

```bash
helm delete cerebro4log --purge
```

## Optional Security

Using Basic Auth, [see more details](https://imti.co/kibana-kubernetes/) on part `Basic Auth`

## TODOs

1. 节点调整时观察到index丢失的情况，需后续跟进