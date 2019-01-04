# Handbook for metrics

## Install Prometheus Operator

```bash
kubectl create namespace metrics

helm install --name monitor --namespace metrics \
-f prometheus-operator-values.yaml \
stable/prometheus-operator
```

Admin account/password to log into the grafana UI: admin/prom-operator

## Upgrading Prometheus Operator

```bash
helm upgrade metrics-monitor stable/prometheus-operator -f prometheus-operator-values.yaml
```

## Uninstalling Prometheus Operator

```bash
helm delete metrics-monitor --purge

kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com

# Remove PV manually as appropriate
```

## Usage Case

TODO:

## Extracing Metrics

TODO: