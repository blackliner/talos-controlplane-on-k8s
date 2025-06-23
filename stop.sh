#!/bin/bash

# shellcheck disable=1091
. .env

kubectl delete secret "$CLUSTER_NAME" --namespace "$NAMESPACE"
envsubst <talos-cp-in-k8s.yaml | kubectl delete -f -
