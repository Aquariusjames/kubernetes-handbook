# Prometheus handbook

## Install Prometheus Operator

```bash
helm install --name metrics-monitor --namespace metrics \
-f prometheus-operator-values.yaml \
stable/prometheus-operator
```

Admin account/password to log into the grafana UI: admin/prom-operator

## Uninstalling the Chart

```bash
helm delete metrics-monitor --purge

kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com

# Remove PV manually as appropriate
```

## Updateing the Chart

```bash
helm upgrade metrics-monitor stable/prometheus-operator -f prometheus-operator-values.yaml
```

## Usage Case

TODO:

## Extracing Metrics

TODO: