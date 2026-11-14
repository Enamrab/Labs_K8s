
Kubernetes StatefulSet Lab: Sticky Identity, Dedicated Storage & Scaling:
This repository demonstrates how Kubernetes StatefulSets manage stateful workloads on bare-metal clusters using predictable network identities, volumeClaimTemplates, and local PersistentVolumes with nodeAffinity.

📁 Repository Structure:
statefulset-demo/
├── sts-pvs.yaml           # StorageClass (WaitForFirstConsumer) + initial local PVs
├── statefulset.yaml       # Headless Service + StatefulSet with volumeClaimTemplates
└── extra-pvs.yaml         # Additional local PVs to unblock scale-out to 5 replicas

🎯 Core Concepts Demonstrated:
Unlike standard Deployments where replicas share a single PVC and get random names, a StatefulSet guarantees:
• Sticky Network Identity: Pods receive predictable, sequential names (log-app-0, log-app-1) backed by a Headless Service (clusterIP: None).
• Dedicated Storage per Replica: volumeClaimTemplates automatically generates a unique PersistentVolumeClaim for each replica (log-storage-log-app-0, log-storage-log-app-1).
• Sticky Storage Re-attachment: If a Pod is deleted or rescheduled, Kubernetes re-attaches it strictly to its original PVC.
• Ordered Rollout & Termination: Pods start sequentially (0 -> 1 -> 2) and terminate in reverse order (2 -> 1 -> 0).

🛠️ Step 1: Prepare Worker Node Directories:
Because local volumes do not auto-create host directories, prepare isolated folders on the target bare-metal nodes before deploying:
# Create initial directories for replicas 0 and 1
ssh node-01 "mkdir -p /home/laborant/sts-data-0"
ssh node-02 "mkdir -p /home/laborant/sts-data-1"

🚀 Step 2: Deploy Storage & StatefulSet:
1. Apply the StorageClass and initial PersistentVolumes:
(Uses volumeBindingMode: WaitForFirstConsumer and nodeAffinity to lock each PV to its corresponding worker node).
kubectl apply -f sts-pvs.yaml

2. Deploy the Headless Service and StatefulSet:
kubectl apply -f statefulset.yaml

3. Verify Pod placement and auto-generated PVCs:
kubectl get pods -o wide
kubectl get pvc
• Expected Result: log-app-0 runs on node-01 bound to log-storage-log-app-0, and log-app-1 runs on node-02 bound to log-storage-log-app-1.

📈 Step 3: Scaling Behavior & Validation:
1. Scaling Up & Sequential Blocking (2 → 5 Replicas)
kubectl scale statefulset log-app --replicas=5
kubectl get pods -w

• Observation: Kubernetes creates log-app-2 and automatically stamps out log-storage-log-app-2.
• Blocking Gate: Because only 2 static PVs exist, log-app-2 remains Pending (FailedScheduling: didn't find available persistent volumes to bind). The StatefulSet controller blocks log-app-3 and log-app-4 from being created until log-app-2 reaches Running and Ready.

2. Unblocking Scale-Out:
Prepare the missing node directories and apply the additional PVs to trigger a sequential rollout:
ssh node-01 "mkdir -p /home/laborant/sts-data-2 /home/laborant/sts-data-4"
ssh node-02 "mkdir -p /home/laborant/sts-data-3"

kubectl apply -f extra-pvs.yaml
kubectl get pods -w
• Observation: log-app-2 binds and starts first, immediately unblocking log-app-3, followed by log-app-4.

3. Scaling Down & PVC Retention (5 → 2 Replicas):
kubectl scale statefulset log-app --replicas=2
kubectl get pods
kubectl get pvc
• Reverse Termination: Pods terminate strictly in reverse order (log-app-4 → log-app-3 → log-app-2).
• Data Safety: All 5 PVCs remain Bound. Kubernetes never deletes PVCs automatically during a scale-down so data remains intact if you scale back up later.

🧹 Cleanup:
To remove the StatefulSet and manually clean up retained PVCs and PVs:
kubectl delete -f statefulset.yaml
kubectl delete pvc -l app=log-app
kubectl delete -f sts-pvs.yaml -f extra-pvs.yaml
