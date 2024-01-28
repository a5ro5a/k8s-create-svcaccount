# create-serviceaccount
This is tool auto create ServiceAccount of kubernetes for cicdtool.

For limited use by third-party apps.

https://kubernetes.io/docs/concepts/security/service-accounts/

## environment
kubernetes v1.28.2

## how to use

### define file .env
```bash
cd k8s-create-svcaccount
vi .env
```
```markdown
# Namespace.name
export _NAMESPACE=testapps

# ServiceAccount.name
export _SERVICE_ACCOUNT=for-circleci
```

if "Namespace" not exist yet, you can create in this way.
```bash
cat <<END|kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
    name: testapps
END
```

### install
```bash
bash install.sh
```

## test
```bash
source .env 
```

### create test app
```bash
kubectl run nginx --image=nginx -n $_NAMESPACE
```

### check
```bash
TOKEN=`kubectl get secret/$_SERVICE_ACCOUNT-secret -n $_NAMESPACE -o jsonpath='{.data.token}' | base64 --decode`
KUBERNETES_SERVER=`grep server\: ~/.kube/config | awk '{print $2}'`
```

```bash
kubectl --insecure-skip-tls-verify --kubeconfig="/dev/null" --server=$KUBERNETES_SERVER --token=$TOKEN get pods -n $_NAMESPACE
```
> NAME    READY   STATUS              RESTARTS   AGE
> nginx   0/1     ContainerCreating   0          4s

### if you delete
```bash
kubectl delete pods/nginx -n $_NAMESPACE
```

```bash
kubectl delete -f ./k8s/
```
### delete namespace
#### caution
__If service is already running on production environment, please don't delete namespace.
 all resource of this namespace will deleted.__
```bash
kubectl delete namespace $_NAMESPACE
```

