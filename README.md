# Talos controlplane in a kubernetes cluster

The goal of this setup is to run a Talos controlplane inside a Kubernetes cluster.
Other talos nodes, virtual or bare metal, can then join this controlplane.

Based on the [Talos documentation for Kubernetes](https://www.talos.dev/v1.10/talos-guides/install/cloud-platforms/kubernetes/).

## Main components

| File/Script                                        | Description                                                                                                                                                                                                                                                                                    |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [talos-cp-in-k8s.yaml](talos-cp-in-k8s.yaml)       | Main manifest that deploys the Talos controlplane as a StatefulSet, plus a Service of type LoadBalancer. Includes persistent storage for certain container paths. See [Volume Mounts](https://www.talos.dev/v1.10/talos-guides/install/cloud-platforms/kubernetes/#volume-mounts) for details. |
| [patch-controlplane.yaml](patch-controlplane.yaml) | Patch that adds necessary configuration to the Talos controlplane for running inside Kubernetes. Ensures the `podSubnets` and `serviceSubnets` CIDR ranges do not overlap with the Kubernetes cluster's CIDR ranges.                                                                           |
| [.env](.env)                                       | Contains environment variables used by the deployment scripts. Set the correct values for your Kubernetes cluster.                                                                                                                                                                             |
| [start.sh](start.sh)                               | Script to deploy the Talos controlplane in the Kubernetes cluster. Ensure your `kubectl` context is set to the correct cluster before running.                                                                                                                                                 |
| [stop.sh](stop.sh)                                 | Script to stop the Talos controlplane in the Kubernetes cluster.                                                                                                                                                                                                                               |
