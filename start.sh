#!/bin/bash

set -euo pipefail

if [ -f secrets.yaml ]; then
	echo "Using secrets.yaml for secrets"
else
	echo "secrets.yaml not found, generating new secrets.yaml"
	talosctl gen secrets -o secrets.yaml
fi

# shellcheck disable=1091
. .env

talosctl gen config bishop "https://$ENDPOINT:6443" \
	--force --with-secrets secrets.yaml \
	--with-docs=false \
	--with-examples=false \
	--config-patch-control-plane @patch-controlplane.yaml \
	--additional-sans="$ENDPOINT" \
	--with-kubespan=false \
	--with-cluster-discovery=false

### Variant with USERDATA from secret
# cat controlplane.yaml | base64 >controlplane.yaml.base64
# kubectl create secret generic bishop --from-file=controlplane.yaml.base64

kubectl create namespace "$NAMESPACE" || true
envsubst <talos-cp-in-k8s.yaml | kubectl apply --namespace "$NAMESPACE" -f -

while ! talosctl --talosconfig talosconfig \
	-n "$ENDPOINT" -e "$ENDPOINT" \
	apply-config --file controlplane.yaml --insecure >/dev/null 2>&1; do
	echo "Applying control plane configuration..."
	sleep 5
done

echo "Control plane configuration applied successfully."

talosctl --talosconfig talosconfig config node "$ENDPOINT"
talosctl --talosconfig talosconfig config endpoint "$ENDPOINT"

while ! talosctl --talosconfig talosconfig bootstrap >/dev/null 2>&1; do
	echo "Bootstrapping control plane..."
	sleep 5
done

echo "Control plane bootstrapped successfully."

talosctl --talosconfig talosconfig kubeconfig --force --merge=false ./kubeconfig

while ! KUBECONFIG=./kubeconfig kubectl get pods -A >/dev/null 2>&1; do
	echo "Waiting for control plane to be ready..."
	sleep 5
done
