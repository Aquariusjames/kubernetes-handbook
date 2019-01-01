# Rook handbook

## TODOS

TODO:Following options needs to be think!!!!

1. `What will happen when all nodes are rebooting?`
2. CPU-intensive processes？
3. [Hardware Recommendations](http://docs.ceph.com/docs/master/start/hardware-recommendations/)

## Install Rook

### Bootstrap a rook-ceph-operator

Use `Rook:v.09`

```bash
helm repo add rook-beta https://charts.rook.io/beta

helm install --name rook-ceph --namespace rook-ceph-system --version v0.9.0 rook-beta/rook-ceph

# For upgrade
# helm upgrade rook-ceph rook-beta/rook-ceph --namespace rook-ceph-system --version v0.9.0
# For delete
# helm delete rook-ceph --purge
```

```bash
kubectl --namespace rook-ceph-system get pods -l "app=rook-ceph-operator"
```

### Create a Rook Ceph Cluster

#### Ceph Cluster

[See more details](https://rook.github.io/docs/rook/v0.9/ceph-cluster-crd.html)

`WARNING`: For test scenarios, if you delete a cluster and start a new cluster on the same hosts, the path used by `dataDirHostPath(default is /var/lib/rook)` must be deleted. Otherwise, stale keys and other config will remain from the previous cluster and the new mons will fail to start. If this value is empty, each pod will get an ephemeral directory to store their config files that is tied to the lifetime of the pod running on that node

Edit the ceph-cluster.yaml by yourself

```bash
kubectl create namespace rook-ceph

kubectl apply -f ./ceph-cluster.yaml
```

##### Node updates

Add and remove storage resources

```bash
kubectl -n rook-ceph edit CephCluster rook-ceph
```

### Ceph Block Storage

Edit the storageclass.yaml by yourself

```bash
kubectl create -f ./storageclass.yaml
```

See OSD Information

```bash
OSD_PODS=$(kubectl get pods --all-namespaces -l \
  app=rook-ceph-osd,rook_cluster=rook-ceph -o jsonpath='{.items[*].metadata.name}')
# Find node and drive associations from OSD pods
for pod in $(echo ${OSD_PODS})
do
 echo "Pod:  ${pod}"
 echo "Node: $(kubectl -n rook-ceph get pod ${pod} -o jsonpath='{.spec.nodeName}')"
 kubectl -n rook-ceph exec ${pod} -- sh -c '\
  for i in /var/lib/rook/osd*; do
    [ -f ${i}/ready ] || continue
    echo -ne "-$(basename ${i}) "
    echo $(lsblk -n -o NAME,SIZE ${i}/block 2> /dev/null || \
    findmnt -n -v -o SOURCE,SIZE -T ${i}) $(cat ${i}/type)
  done|sort -V
  echo'
done
```

#### Enable default StorageClass

Enable admission plugins `DefaultStorageClass`, then wait api server to restart

```bash
vim /etc/kubernetes/manifests/kube-apiserver.yaml
# For example
# spec:
#   containers:
#   - command:
#     - kube-apiserver
#     - --authorization-mode=Node,RBAC
#     - --advertise-address=192.168.137.102
#     - --allow-privileged=true
#     - --client-ca-file=/etc/kubernetes/pki/ca.crt
#     - --enable-admission-plugins=NodeRestriction,DefaultStorageClass
```

### Ceph Object Storage

TODO: I don't understand the scenarios of ceph object storage
[See more details](https://rook.github.io/docs/rook/v0.9/ceph-object.html)

### Ceph Shared File System

TODO: Need to explore the usage of shared file system
[See more details](https://rook.github.io/docs/rook/v0.9/ceph-filesystem.html)

### About Ceph

[See more details](http://docs.ceph.com/docs/mimic/start/intro/)

### Toolbox

```bash
kubectl create -f toolbox.yaml

kubectl -n rook-ceph get pod -l "app=rook-ceph-tools"

kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash

# kubectl -n rook-ceph delete deployment rook-ceph-tools
```

[See more deatils](https://rook.github.io/docs/rook/v0.9/ceph-toolbox.html)

### Ceph Dashboard

```bash
kubectl port-forward svc/rook-ceph-mgr-dashboard -n rook-ceph 8443
```

`Prerequisites`: Ingress Controller has been installed

[See more detals](https://rook.github.io/docs/rook/v0.9/ceph-dashboard.html)

```bash
kubectl create -f ./rook-ceph-ingress.yaml
```

admin/yPYTzfxNri

```bash
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o yaml | grep "password:" | awk '{print $2}' | base64 --decode
```

### Monitoring

TODO:
[See more details](https://rook.github.io/docs/rook/v0.8/monitoring.html)

### Tear Down

[See more details](https://rook.io/docs/rook/v0.9/ceph-teardown.html)

If you want to **tear down the cluster and bring up a new one**, be aware of the following resources that will need to be cleaned up:

* rook-ceph-system namespace: The Rook operator and agent created by operator.yaml
* rook-ceph namespace: The Rook storage cluster created by cluster.yaml (the cluster CRD)
* `dataDirHostPath(default is /var/lib/rook)`. Path on each host in the cluster where configuration is cached by the ceph mons and osds

```bash
# If do block storage tutorial
kubectl delete -f ./test/mysql.yaml
kubectl delete -f ./test/wordpress.yaml

kubectl delete -n rook-ceph CephBlockPool replicapool

kubectl delete storageclass rook-ceph-block

# If do filesystem tutorial
kubectl delete -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/kube-registry.yaml

kubectl -n rook-ceph delete cephcluster rook-ceph

# Verify that the cluster CRD has been deleted before continuing to the next step.
kubectl -n rook-ceph get cephcluster

helm delete rook-ceph --purge

kubectl delete namespace rook-ceph

kubectl delete namespace rook-ceph-system

# Delete the data on hosts
# Connect to each machine and delete /var/lib/rook, or the path specified by the dataDirHostPath
rm -rf ${dataDirHostPath}/*
rm -rf /var/lib/rook/*
```

## Trouble Shooting

[Common issues](https://github.com/rook/rook/blob/master/Documentation/common-issues.md)

1. Check in ceph context
    ```bash
    kubectl -n rook-ceph-system exec -it $(kubectl -n rook-ceph-system get pods -l app=rook-ceph-operator -o jsonpath='{.items[0].metadata.name}') -- bash
    ```
2. If namespace have CephCluster object terminating is stucked, it's because the finalizer of CephCluster object is rook operator, so if you can edit CephCluster object, look for the finalizers element and delete `- cluster.rook.io`
    ```bash
    kubectl edit CephCluster rook-ceph -n rook-ceph
    ```

### Node hangs after rebooting
  
    The node needs to be drained before reboot.After the successful drain, the node can be rebooted as usual.

    Because kubectl drain command automatically marks the node as unschedulable (kubectl cordon effect), the node needs to be uncordoned once it’s back online.

    ```bash
    # Drain the node
    kubectl drain <node-name> --ignore-daemonsets --delete-local-data

    reboot

    # Uncordon the node
    kubectl uncordon <node-name>
    ```

### Rook 0.9 modules failed on default install

`Note`: This solution is suspected, because of invaliding `kubectl port-forward`, which may cause ingress and service invalid

```bash
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash

ceph config set mgr.a mgr/prometheus/server_addr ${mgr_pod_ip}
ceph config set mgr.a mgr/dashboard/server_addr ${mgr_pod_ip}

kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-mgr" -o jsonpath='{.items[0].metadata.name}') bash

rook@pod kill 1
```

[See Issue on github](https://github.com/rook/rook/issues/2335#issuecomment-448488847)

### Operator Logic

The operator will decide on the expected monmap during the Operator health check. The sequence would be:

* Check if we have mon quorum.
* If we have quorum
  * If a mon is down, bring up a new one and remove the bad one
  * If all mons are up, check again at the next health interval
* If we don't have quorum
  * Ensure the mon pods are in Running state.
    * If any mon pods refuse to start, remove them from the monmap
  * If the running pod IPs don't match the expected pod IPs
    * Update the monmap that is stored in the configmap
  * The operator stops the mon pods and then restarts them. See below for the behavior inside the Rook mon when restarted.
  * Wait for the mons to form quorum again
  * If we have fewer mons than expected (3)
    * add new mons to restore redundancy

When the Rook monitor pod starts, it will compare its local monmap to what the operator desires the monmap to be. If the monmap is not exactly as specified by the operator, the mon will refuse to start and wait for the operator to reconcile the issue and restart the mon.

* If the local monmap does not exist, this is a new monitor
  * Start the mon. No more checks are necessary.
* Retrieve the desired monmap from the Rook API service. The API service gets the monmap from the configmap that the operator set.
* If the local monmap has the same ip as the podIP for this monitor:
  * If the podIP is the same as the desired podIP:
    * Start the mon
  * If the podIP is different than the desired podIP
    * Write an error to the log and wait to be shutdown by the operator
* If the local monmap has a different ip than the podIP:
  * If the podIP is the same as desired monmap
    * Inject the desired monmap using embedded ceph-mon
    * Start the mon
  * If the podIP is different from the desired monmap
    * Write an error to the log and wait to be shutdown by the operator

## Disaster recovery

TODO: I have failed with testing disaster recovery

```bash
kubectl -n rook-ceph-system delete deployment rook-ceph-operator

kubectl -n rook-ceph exec -it rook-ceph-mon-f-7f5447c6f6-p5hxr bash

cluster_namespace=rook-ceph
good_mon_id=mon-d
monmap_path=/tmp/monmap

cluster_namespace=rook-ceph
good_mon_id=mon-f
monmap_path=/tmp/monmap

# make sure the quorum lock file does not exist
rm -f /var/lib/rook/${good_mon_id}/data/store.db/LOCK

# extract the monmap to a file
ceph-mon -i ${good_mon_id} --extract-monmap ${monmap_path} \
  --cluster=${cluster_namespace} --mon-data=/var/lib/rook/${good_mon_id}/data \
  --conf=/var/lib/rook/${good_mon_id}/${cluster_namespace}.config \
  --keyring=/var/lib/rook/${good_mon_id}/keyring \
  --monmap=/var/lib/rook/${good_mon_id}/monmap

# review the contents of the monmap
monmaptool --print /tmp/monmap

# remove the bad mon(s) from the monmap
monmaptool ${monmap_path} --rm <bad_mon>

# in this example we remove mon0 and mon2:
monmaptool ${monmap_path} --rm a
monmaptool ${monmap_path} --rm c

# inject the monmap into the good mon
ceph-mon -i ${good_mon_id} --inject-monmap ${monmap_path} \
  --cluster=${cluster_namespace} --mon-data=/var/lib/rook/${good_mon_id}/data \
  --conf=/var/lib/rook/${good_mon_id}/${cluster_namespace}.config \
  --keyring=/var/lib/rook/${good_mon_id}/keyring

kubectl -n rook-ceph get pod -l mon=f
kubectl -n rook-ceph delete pod -l mon=f
```