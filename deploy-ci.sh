#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

export PATH="$HOME/.local/bin:$PATH"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/handclinic-deployer}"

kubectl -n handclinic create configmap site --from-file=index.html=index.html --dry-run=client -o yaml | kubectl apply -f -
kubectl -n handclinic create configmap site-img --from-file=hero.jpg=assets/hero.jpg --dry-run=client -o yaml | kubectl apply -f -
kubectl -n handclinic create configmap nginx-conf --from-file=default.conf=nginx/default.conf --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f k8s.yaml
kubectl -n handclinic rollout restart deployment/web
kubectl -n handclinic rollout status deployment/web --timeout=180s
kubectl -n handclinic get pods,svc -o wide
