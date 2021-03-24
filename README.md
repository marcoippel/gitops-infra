export GITHUB_TOKEN= \
export GITHUB_USER=

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=gitops-infra \
  --branch=main \
  --path=./clusters/gitops-cluster \
  --personal


flux create source git wordpress-prod \
    --url=https://github.com/marcoippel/k8s-wordpress \
    --branch=master \
    --username=$GITHUB_USER \
    --password=$GITHUB_TOKEN \
    --interval=30s \
    --secret-ref=wordpress-auth \
    --export > ./wordpress-source.yaml

flux create kustomization wordpress-prod \
  --source=wordpress-prod \
  --path="./kustomize/pverlays/prod" \
  --prune=true \
  --validation=client \
  --interval=5m \
  --export > ./wordpress-prod-kustomization.yaml

flux create secret git wordpress-auth \
    --url=https://github.com/marcoippel/k8s-wordpress \
    --username=$GITHUB_USER \
    --password=$GITHUB_TOKEN

flux create source git ingress \
    --url=https://github.com/kubernetes/ingress-nginx \
    --branch=master \
    --interval=30s \
    --export > ./clusters/gitops-cluster/ingress/ingress-source.yaml

flux create kustomization wordpress-prod \
  --source=ingress \
  --path="./deploy/static/provider/cloud" \
  --prune=true \
  --validation=client \
  --interval=5m \
  --export > ./clusters/gitops-cluster/ingress/ingress-kustomization.yaml

kubectl -n flux-system create secret generic slack-url \
--from-literal=address=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK