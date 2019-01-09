#!/bin/bash
set -e
set -o pipefail

# Add user to k8s using service account, no RBAC (must create RBAC after this script)
if [[ -z "$1" ]] || [[ -z "$2" ]]; then
 echo "usage: $0 <service_account_name> <namespace>"
 exit 1
fi

SERVICE_ACCOUNT_NAME=$1
NAMESPACE="$2"

context=$(kubectl config current-context)
echo -e "\\nSetting current context to: $context"

CLUSTER_NAME=$(kubectl config get-contexts "$context" | awk '{print $3}' | tail -n 1)
echo "Cluster name: ${CLUSTER_NAME}"

KUBECFG_DIR="../workspace/tiller/configs/${CLUSTER_NAME}"
KUBECFG_FILE_NAME="${KUBECFG_DIR}/${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-conf"
TARGET_FOLDER="../workspace/tiller/certificates/${CLUSTER_NAME}"

create_target_folder() {
    echo -n "Creating target directory to hold files in ${TARGET_FOLDER}..."
    mkdir -p "${TARGET_FOLDER}"
    echo -n "Creating kube config file directory in ${KUBECFG_DIR}..."
    mkdir -p "${KUBECFG_DIR}"
    printf "done"
}

create_service_account() {
    echo -e "\\nCreating a service account: ${SERVICE_ACCOUNT_NAME}-${NAMESPACE}"
    kubectl create sa "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}" -n ${NAMESPACE}
}

get_secret_name_from_service_account() {
    echo -e "\\nGetting secret of service account ${SERVICE_ACCOUNT_NAME}-${NAMESPACE}"
    SECRET_NAME=$(kubectl get sa "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}" -n ${NAMESPACE} -o jsonpath={.secrets[].name})
    echo "Secret name: ${SECRET_NAME}"
}

extract_ca_crt_from_secret() {
    echo -e -n "\\nExtracting ca.crt from secret..."
    kubectl get secret "${SECRET_NAME}" -n ${NAMESPACE} -o jsonpath='{.data.ca\.crt}' | base64 -D > "${TARGET_FOLDER}/ca.crt"
    printf "done"
}

get_user_token_from_secret() {
    echo -e -n "\\nGetting user token from secret..."
    USER_TOKEN=$(kubectl get secret "${SECRET_NAME}" -n ${NAMESPACE} -o jsonpath={.data.token} | base64 -D)
    printf "done"
}

set_kube_config_values() {
    ENDPOINT=$(kubectl config view \
    -n ${NAMESPACE} \
    -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")
    echo "Endpoint: ${ENDPOINT}"

    # Set up the config
    echo -e "\\nPreparing k8s-${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-conf"
    echo -n "Setting a cluster entry in kubeconfig..."
    kubectl config set-cluster "${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --server="${ENDPOINT}" \
    --certificate-authority="${TARGET_FOLDER}/ca.crt" \
    --embed-certs=true

    echo -n "Setting token credentials entry in kubeconfig..."
    kubectl config set-credentials \
    "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --token="${USER_TOKEN}"

    echo -n "Setting a context entry in kubeconfig..."
    kubectl config set-context \
    "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --cluster="${CLUSTER_NAME}" \
    --user="${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --namespace="${NAMESPACE}"

    echo -n "Setting the current-context in the kubeconfig file..."
    kubectl config use-context "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}"
}

create_role() {
cat <<EOF | kubectl create -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${SERVICE_ACCOUNT_NAME}-manager
  namespace: ${NAMESPACE}
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
EOF
}

create_rolebinding() {
cat <<EOF | kubectl create -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${SERVICE_ACCOUNT_NAME}-binding
  namespace: ${NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${SERVICE_ACCOUNT_NAME}-${NAMESPACE}
  namespace: ${NAMESPACE}
roleRef:
  kind: Role
  name: ${SERVICE_ACCOUNT_NAME}-manager
  apiGroup: rbac.authorization.k8s.io
EOF
}

create_target_folder
create_service_account
get_secret_name_from_service_account
extract_ca_crt_from_secret
get_user_token_from_secret
set_kube_config_values
create_role
create_rolebinding

echo -e "\\nAll done! Test with:"
echo "KUBECONFIG=${KUBECFG_FILE_NAME} kubectl get pods -n ${NAMESPACE}"
echo "you should not have any permissions by default - you have just created the authentication part"
echo "You will need to create RBAC permissions"
KUBECONFIG=${KUBECFG_FILE_NAME} kubectl get pods -n ${NAMESPACE}