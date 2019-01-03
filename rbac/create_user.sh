#! /bin/bash

echo =====================================================================
echo This shell script is used for creating kubernetes cluster user
echo Prerequisites: 
echo 1. the admin permission of specified kubernetes cluster
echo =====================================================================

# 用户名
echo 1. Please input USERNAME:
read USERNAME
echo "[INFO]username is ${USERNAME:?"USERNAME must not be null"}"

# 组名
echo 2. Please input GROUPNAME:
read GROUPNAME
echo "[INFO]groupname is ${GROUPNAME:?"GROUPNAME must not be null"}"

# 集群名
echo 3. Please input CLUSTERNAME:
read CLUSTERNAME
echo "[INFO]clustername is ${CLUSTERNAME:?"CLUSTERNAME must not be null"}"

# 命名空间
echo 4. Please input NAMESAPCE:
read NAMESAPCE
echo "[INFO]namespace is ${NAMESAPCE:?"NAMESAPCE must not be null"}"

# 角色
echo 5. Please input ROLE, defalt is ClusterRole \'edit\', options are \'cluster-admin\',\'admin\',\'edit\',\'view\' or other customed role object:
read ROLE
echo "[INFO]role is ${ROLE:=edit}"

# 有效期
echo 6. Please input VALIDY, default is \'30 days\':
read VALIDY
echo "[INFO]validy is ${VALIDY:=30} days"

# 生成用户私钥
openssl genrsa -out ./user_certificates/${USERNAME}-${CLUSTERNAME}.key 2048
if [ $? == 0 ]
then
    echo "[INFO]openssl genrsa for ${USERNAME} successfully"
else
    echo "[ERROR]openssl genrsa for ${USERNAME} unsuccessfully"
    exit 1
fi

# 生成证书请求文件
# CN is for the username and O for the group
openssl req -new \
    -key ./user_certificates/${USERNAME}-${CLUSTERNAME}.key \
    -out ./user_certificates/${USERNAME}-${CLUSTERNAME}.csr \
    -subj "/CN=${USERNAME}/O=${GROUPNAME}"
if [ $? == 0 ]
then
    echo "[INFO]openssl req -new for ${USERNAME} successfully"
else
    echo "[ERROR]openssl req -new for ${USERNAME} unsuccessfully"
    exit 1
fi

# 生成证书
openssl x509 -req \
    -in ./user_certificates/${USERNAME}-${CLUSTERNAME}.csr \
    -CA ../workspace/certificates/ca@${CLUSTERNAME}.crt \
    -CAkey ../workspace/certificates/ca@${CLUSTERNAME}.key \
    -CAcreateserial -out ./user_certificates/${USERNAME}-${CLUSTERNAME}.crt \
    -days ${VALIDY}
if [ $? == 0 ]
then
    echo "[INFO]openssl x509 -req for ${USERNAME} successfully"
else
    echo "[ERROR]openssl x509 -req for ${USERNAME} unsuccessfully"
    exit 1
fi

echo "[INFO]Begin to create role binding for user:${USERNAME} with namespace:${NAMESAPCE} and role:${ROLE}"

# 切换上下文至指定集群管理员
CURRENT_CONTEXT=$(kubectl config current-context)
if [ ${CURRENT_CONTEXT}x != "kubernetes-admin@"${CLUSTERNAME}x ]
then
    kubectl config use-context kubernetes-admin@${CLUSTERNAME}
fi
cat <<EOF | kubectl create -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${USERNAME}-${GROUPNAME}-${ROLE}
  namespace: ${NAMESAPCE}
subjects:
- kind: User
  name: ${USERNAME}
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: ${ROLE}
  apiGroup: ""
EOF
if [ $? == 0 ]
then
    if [ ${CURRENT_CONTEXT}x != kubernetes-admin@${CLUSTERNAME}x ]
    then
    kubectl config use-context ${CURRENT_CONTEXT}
    fi
    echo "[INFO]kubectl create RoleBinding for user:${USERNAME} with namespace:${NAMESAPCE} and role:${ROLE} successfully"
else
    echo "[ERROR]kubectl create RoleBinding for user:${USERNAME} with namespace:${NAMESAPCE} and role:${ROLE} unsuccessfully"
    exit 1
fi

# 获取指定集群于办公网下的IP
CLUSTERNAME="devk8s"
API_SERVER_URL=$(kubectl config view -o jsonpath={.clusters[?\(@.name==\"${CLUSTERNAME}\"\)].cluster.server})
echo "[INFO]api server url of cluster:${CLUSTERNAME} is ${API_SERVER_URL} "

KUBECONFIG_FILE=${USERNAME}-${NAMESAPCE}-${ROLE}@${CLUSTERNAME}.conf

# 为该用户设置集群信息
CLUSTER_CA_DATA=$(base64 -i ../workspace/certificates/ca@${CLUSTERNAME}.crt)
kubectl config set-cluster ${CLUSTERNAME} \
    --kubeconfig=${KUBECONFIG_FILE} \
    --server=${API_SERVER_URL}
kubectl config --kubeconfig=${KUBECONFIG_FILE} \
    set clusters.${CLUSTERNAME}.certificate-authority-data $CLUSTER_CA_DATA

if [ $? == 0 ]
then
    echo "[INFO]kubectl config set-cluster for user:${USERNAME} successfully"
else
    echo "[ERROR]kubectl config set-cluster for user:${USERNAME} unsuccessfully"
    exit 1
fi

# 为该用户设置证书信息
CLIENT_CRT_DATA=$(base64 -i ./user_certificates/${USERNAME}-${CLUSTERNAME}.crt)
CLIENT_KEY_DATA=$(base64 -i ./user_certificates/${USERNAME}-${CLUSTERNAME}.key)
kubectl config set-credentials ${USERNAME} \
    --kubeconfig=${KUBECONFIG_FILE} \
kubectl config --kubeconfig=${KUBECONFIG_FILE} \
    set users.${USERNAME}.client-certificate-data $CLIENT_CRT_DATA
kubectl config --kubeconfig=${KUBECONFIG_FILE} \
    set users.${USERNAME}.client-key-data $CLIENT_KEY_DATA
if [ $? == 0 ]
then
    echo "[INFO]kubectl config set-credentials for user:${USERNAME} successfully"
else
    echo "[ERROR]kubectl config set-credentials for user:${USERNAME} unsuccessfully"
    exit 1
fi

# 为该用户设置上下文信息
kubectl config set-context ${USERNAME}-${NAMESAPCE}-${ROLE}@${CLUSTERNAME} \
    --kubeconfig=${KUBECONFIG_FILE} \
    --cluster=${CLUSTERNAME} \
    --namespace=${NAMESAPCE} \
    --user=${USERNAME}
if [ $? == 0 ]
then
    echo "[INFO]kubectl config set-context for user:${USERNAME} successfully"
else
    echo "[ERROR]kubectl config set-context for user:${USERNAME} unsuccessfully"
    exit 1
fi

mv ${KUBECONFIG_FILE} ./user_configs/

echo "[INFO]The creatation of user:${USERNAME}:${ROLE} on cluster:${CLUSTERNAME}:${NAMESAPCE} is completed "
