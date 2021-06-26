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

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

/api/v1/nodes/kind-control-plane/proxy/metrics/cadvisor
/api/v1/nodes/kind-control-plane/proxy/metrics