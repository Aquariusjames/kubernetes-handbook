# Handbook for metrics

## Install Prometheus Operator

[See more details](https://github.com/helm/charts/tree/master/stable/prometheus-operator)

```bash
kubectl create namespace metrics

helm install --name monitor --namespace metrics \
-f prometheus-operator-values.yaml \
stable/prometheus-operator
```

For accessing test

```bash
kubectl port-forward svc/monitor-grafana -n metrics 8181:80
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