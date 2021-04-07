### Create SOPS Secret in AKS
``` bash
kubectl apply -f sops-secret.yaml
```

### Add github credentials as env vars
``` bash
set GITHUB_TOKEN=
set GITHUB_USER=
```

### Add a label to the node
``` bash
kubectl node
```

### Create the secret for the git pull commands
``` bash
flux create secret git wordpress-auth --url=https://github.com/marcoippel/k8s-wordpress --username=%GITHUB_USER% --password=%GITHUB_TOKEN%
```

### Init flux cluster
``` bash
flux bootstrap github --owner=%GITHUB_USER% --repository=gitops-infra --branch=main --path=./clusters/gitops-cluster --personal
```