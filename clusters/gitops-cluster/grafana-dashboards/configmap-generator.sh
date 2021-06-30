#!/bin/sh

kubectl create configmap grafana-dashboards --from-file custom-dashboard.json --from-file control-plane.json --from-file cluster.json --dry-run -o yaml > configmap.yaml