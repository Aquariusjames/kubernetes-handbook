# Jaeger handbook

## Enable Incubator repository

```bash
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo update
```

## Installing By Helm

[See more tails](https://github.com/helm/charts/tree/master/incubator/jaeger)

```bash
helm install incubator/jaeger --name jaeger-tracing \
--namespace open-tracing \
--set cassandra.config.max_heap_size=1024M \
--set cassandra.config.heap_new_size=512M \
--set cassandra.resources.requests.memory=1024Mi \
--set cassandra.resources.requests.cpu=0.4 \
--set cassandra.resources.limits.memory=2Gi \
--set cassandra.resources.limits.cpu=1 \
--set cassandra.persistence.enabled=true

# If Job failed due to deadline exceeded, do follow command
helm upgrade jaeger-tracing incubator/jaeger \
--namespace open-tracing \
--set cassandra.config.max_heap_size=1024M \
--set cassandra.config.heap_new_size=512M \
--set cassandra.resources.requests.memory=1024Mi \
--set cassandra.resources.requests.cpu=0.4 \
--set cassandra.resources.limits.memory=2Gi \
--set cassandra.resources.limits.cpu=1 \
--set cassandra.persistence.enabled=true
```

### Installing the Chart using an Existing ElasticSearch Cluster

`Note`: Not verified

```bash
helm install incubator/jaeger --name jaeger-tracing \
--namespace open-tracing \
--set provisionDataStore.cassandra=false \
--set provisionDataStore.elasticsearch=false \
--set storage.type=elasticsearch \
--set storage.elasticsearch.host=<HOST> \
--set storage.elasticsearch.port=<PORT> \
--set storage.elasticsearch.user=<USER> \
--set storage.elasticsearch.password=<password>
```

### Uninstalling

```bash
helm delete jaeger-tracing --purge
```