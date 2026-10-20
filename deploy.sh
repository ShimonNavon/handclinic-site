#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

HOST="${HOST:-ubuntu03}"

scp -q index.html "$HOST":/tmp/handclinic-index.html
scp -q assets/hero.jpg "$HOST":/tmp/handclinic-hero.jpg
scp -q nginx/default.conf "$HOST":/tmp/handclinic-default.conf

ssh "$HOST" 'kubectl create namespace handclinic --dry-run=client -o yaml | kubectl apply -f -'
ssh "$HOST" 'kubectl -n handclinic create configmap site --from-file=index.html=/tmp/handclinic-index.html --dry-run=client -o yaml | kubectl apply -f -'
ssh "$HOST" 'kubectl -n handclinic create configmap site-img --from-file=hero.jpg=/tmp/handclinic-hero.jpg --dry-run=client -o yaml | kubectl apply -f -'
ssh "$HOST" 'kubectl -n handclinic create configmap nginx-conf --from-file=default.conf=/tmp/handclinic-default.conf --dry-run=client -o yaml | kubectl apply -f -'
ssh "$HOST" 'kubectl apply -f -' < k8s.yaml
ssh "$HOST" 'kubectl -n handclinic rollout restart deployment/web'
ssh "$HOST" 'kubectl -n handclinic rollout status deployment/web --timeout=180s'
ssh "$HOST" 'kubectl -n handclinic get pods,svc -o wide'
