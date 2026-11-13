# Kubernetes HorizontalPodAutoscaler (HPA) Hands-On Demo:
This repository contains a hands-on demonstration of Kubernetes **HorizontalPodAutoscaler (`autoscaling/v2`)** using CPU-based scaling with `AverageValue` metrics and custom scale-down behavior.

## Overview
In this demo, a Deployment (`my-deploy`) runs five Ubuntu containers executing an infinite shell loop (`while true; do :; done`) to generate continuous CPU load. A HorizontalPodAutoscaler (`my-hpa`) monitors the average CPU usage across the pods and scales the replica count between `1` and `100` to maintain an average CPU consumption of `50m` per pod.
---

## Prerequisites
Metric Server Setup:
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

#Fix the Configuration (Disable TLS Verification):
If you are running a local development, bare-metal, or custom cluster (like kubeadm), the metrics-server cannot validate the Kubelet certificates by default. You need to pass a bypass flag:

Open the deployment for editing:
kubectl edit deployment -n kube-system metrics-server
spec:
  containers:
  - args:
    - --kubelet-insecure-tls # <--- ADD THIS LINE
Save and exit the text editor (:wq in vim). The pod will automatically restart.
---

## Repository Structure
hpa_hands_on/
├── mydeploy.yaml   # Deployment manifest with a CPU-intensive workload
├── hpa.yaml        # HorizontalPodAutoscaler (autoscaling/v2) manifest
---

## Resource Specifications:
### 1. Deployment (`mydeploy.yaml`)
* **Name:** `my-deploy`
* **Initial Replicas:** `5`
* **Container Image:** `ubuntu`
* **Workload:** Infinite bash loop (`while true; do :; done`) to consume CPU cycles.
* **Resource Requests:**
  * CPU: `15m` *(Required so the HPA can calculate pod CPU metrics)*
  * Memory: `15Mi`

### 2. HorizontalPodAutoscaler (`hpa.yaml`)
* **Name:** `my-hpa`
* **Target:** `Deployment/my-deploy`
* **Min / Max Replicas:** `1` to `100`
* **Metric Target:** CPU `AverageValue` of `50m`
* **Scaling Behavior:** Custom `scaleDown` stabilization window set to `30` seconds (overrides the default 5-minute stabilization window for faster scale-down testing).
---

## Usage & Walkthrough
### Step 1: Deploy the Workload
Apply the deployment manifest to spin up the initial 5 CPU-consuming pods:
kubectl apply -f mydeploy.yaml

### Step 2: Apply the HPA Configuration
Create the HorizontalPodAutoscaler resource:
kubectl apply -f hpa.yaml

### Step 3: Monitor Scaling Behavior
Watch the HPA status and pod replica changes in real time:
kubectl get hpa my-hpa --watch

Check detailed scaling events and metric calculations:
kubectl describe hpa my-hpa

View current CPU utilization per pod:
kubectl top pods -l app=my-deploy

### Step 4: Test Scale-Down Behavior
To observe the 30-second `stabilizationWindowSeconds` scale-down behavior, reduce the load (e.g., scale down or patch the deployment command to `sleep infinity`):
kubectl patch deployment my-deploy --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["/bin/bash", "-c", "sleep infinity"]}]'
Watch `kubectl get hpa my-hpa --watch` to see the replica count drop back toward `minReplicas: 1` after ~30 seconds.
---

## Cleanup
Remove the demo resources from your cluster:
kubectl delete -f hpa.yaml
kubectl delete -f mydeploy.yaml

