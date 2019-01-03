# Handbook for user management

## Overview

1. Generate ras private key for user
    ```bash
    # openssl genrsa -out lvjianting.key 2048
    openssl genrsa -out ${username}.key 2048
    ```
2. Generate certificates sign request, which specify username and groupname
    ```bash
    # openssl req -new -key lvjianting.key -out lvjianting.csr -subj "/CN=lvjianting/O=developers"
    # CN is for the username and O for the group
    openssl req -new -key ${username}.key -out ${username}.csr -subj "/CN=${username}/O=${groupname}"
    ```
3. Generate certificates wirh csr, ca.crt and ca.key, besides needs to specify valid days, default is 30 days
    ```bash
    # openssl x509 -req -in lvjianting.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out lvjianting.crt -days 500
    openssl x509 -req -in ${username}.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ${username}.crt -days 500
    ```
4. (Optional)Create Role or Cluster Role for user
5. Bind user'Role whith RoleBinding or ClusterRoleBinding

    For example, using `Default ClusterRole` `edit`, [see more details](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles).

    2.1. User Binding

    ```bash
    cat <<EOF > ./dev-edit-binding.yaml
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1beta1
    metadata:
      name: dev-edit-binding
      namespace: dev
    subjects:
    - kind: User
      name: lvjianting
      apiGroup: ""
    roleRef:
      kind: ClusterRole
      name: edit
      apiGroup: ""
    EOF
    ```
    2.2. Group Binding

    ```yaml
    # This cluster role binding allows anyone in the "developers" group to be Default Cluster Role admin.
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
    name: developer-admin
    subjects:
    - kind: Group
    name: developers # Name is case sensitive
    apiGroup: rbac.authorization.k8s.io
    roleRef:
    kind: ClusterRole
    name: admin
    apiGroup: rbac.authorization.k8s.io
    ```
6. Configure the config file for user
    ```bash
    CLUSTER_CA_DATA=$(base64 -i ../workspace/certificates/ca@${CLUSTERNAME}.crt)
    kubectl config set-cluster ${CLUSTERNAME} \
        --kubeconfig=${KUBECONFIG_FILE} \
        --server=${API_SERVER_URL}
    kubectl config --kubeconfig=${KUBECONFIG_FILE} \
        set clusters.${CLUSTERNAME}.certificate-authority-data $CLUSTER_CA_DATA

    CLIENT_CRT_DATA=$(base64 -i ./user_certificates/${USERNAME}-${CLUSTERNAME}.crt)
    CLIENT_KEY_DATA=$(base64 -i ./user_certificates/${USERNAME}-${CLUSTERNAME}.key)
    kubectl config set-credentials ${USERNAME} \
        --kubeconfig=${KUBECONFIG_FILE}
    kubectl config --kubeconfig=${KUBECONFIG_FILE} \
        set users.${USERNAME}.client-certificate-data $CLIENT_CRT_DATA
    kubectl config --kubeconfig=${KUBECONFIG_FILE} \
        set users.${USERNAME}.client-key-data $CLIENT_KEY_DATA
    ```

## Create user by shell script

`Note`:
`Prerequisites`:

1. the admin permission of specified kubernetes cluster
2. valid namespace
    ```bash
    kubectl create namespace ${namespace}
    ```

Run the shell script.

```bash
./create_user.sh
```

### Use config

```bash
# temporally
export KUBECONFIG=$KUBECONFIG:${config_path}
# permanently for mac
vim ~/.bash_profile

kubectl config use-context ${contextname}
```

## Troubleshooting

Unable to connect to the server: x509: certificate is valid for 10.96.0.1, 10.161.233.80, not 114.215.201.87

```bash
# One option is to tell kubectl that you don't want the certificate to be validated. Obviously this brings up security issues but I guess you are only testing so here you go:
kubectl --insecure-skip-tls-verify --context=employee-context get pods

# [Suggested]The better option is to fix the certificate. Easiest if you reinitialize the cluster by running kubeadm reset on all nodes including the master and then do
kubeadm init --apiserver-cert-extra-sans=114.215.201.87

# It's also possible to fix that certificate without wiping everything, but that's a bit more tricky. Execute something like this on the master as root:
rm /etc/kubernetes/pki/apiserver.*
kubeadm alpha phase certs selfsign --apiserver-advertise-address=0.0.0.0 --cert-altnames=10.161.233.80 --cert-altnames=114.215.201.87
docker rm `docker ps -q -f 'name=k8s_kube-apiserver*'`
systemctl restart kubelet
```
