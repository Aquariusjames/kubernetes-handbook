# Cert Manager handbook

## Install Cert Manager

[Reference](https://imti.co/lets-encrypt-kubernetes/)

```bash
helm install --name cert-manager --namespace kube-system stable/cert-manager
```

## Deploy Cluster Issuer

`Note`: The only essential difference between the staging and production ClusterIssuer is the server: URL.

Staging: server: `https://acme-staging.api.letsencrypt.org/directory`
Production: server: `https://acme-v01.api.letsencrypt.org/directory`

```bash
kubectl create -f cluster-issuer-letsencrypt-staging.yaml

# Check the status of the new ClusterIssuer
kubectl describe ClusterIssuer
```

## Obtain a Certificate

```bash
kubectl create -f cert-domain.yaml

# Under Conditions: look for Certificate issued successfully. 
# If the certificate issued successfully, you can view it in the Secret defined in your configuration. 
# In our example, the secret is named internalk8s-cn-staging-tls
# Warning: Can't continue due no public domain
kubectl get secret internalk8s-cn-staging-tls -o yaml
```

## Using the new cert for Ingress

`Warning`: Can't continue due no public domain

Usage example

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example
  labels:
    app: example
    system: test
spec:
  rules:
  - host: example.com
    http:
      paths:
      - backend:
          serviceName: "ok"
          servicePort: 5001
        path: /
  tls:
  - hosts:
    - example.com
    - www.example.com
    secretName: example-com-production-tls
```
