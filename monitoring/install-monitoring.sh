#!/bin/bash

set -e

echo "Adding Prometheus Helm repository..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

echo "Creating monitoring namespace if it doesn't exist..."

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Installing kube-prometheus-stack..."

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    -f values.yaml

echo "Monitoring installation completed."