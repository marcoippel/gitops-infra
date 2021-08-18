### Install kind
https://kind.sigs.k8s.io/

### Create KIND Cluster
```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```


### Add github credentials as env vars
``` bash
export GITHUB_TOKEN= \
export GITHUB_USER=
```

### Init flux cluster
``` bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=gitops-infra \
  --branch=main \
  --path=./clusters/gitops-cluster \
  --personal
```

### Create SOPS Secret in AKS
``` bash
kubectl apply -f sops-secret.yaml
```

### Create the secret for the git pull commands
``` bash
kubectl apply -f github-pat-secret.yaml
```

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install --name my-release prometheus-community/prometheus-adapter
helm install prometheusadapter prometheus-community/prometheus-adapter --set prometheus.url=http://prometheus.monitoring.svc  --set rules.existing=prometheus-adapter -n monitoring

# query for custom resources
k get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/monitoring/pods/*/http_requests_per_second | jq


kubectl get secret --namespace loki-stack loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl port-forward --namespace loki-stack service/grafana 3000:80
kubectl port-forward --namespace loki-stack service/prometheus-server 3001:80
kubectl port-forward --namespace loki-stack service/prometheus-alertmanager 3002:80
kubectl port-forward --namespace monitoring service/loki-loki 3100:3100
kubectl port-forward --namespace monitoring daemonSet/promtail-daemonset 3101:3101
kubectl port-forward --namespace default daemonSet/my-promtail 3101:3101
kubectl port-forward --namespace monitoring service/sample-app 81:80


# get the token to access the kubernetes dashboard
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"

# start a proxy to access the kubernetes dashboard
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.