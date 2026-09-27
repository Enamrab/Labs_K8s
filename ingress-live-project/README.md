# Ingress Live Project

A hands-on Kubernetes lab demonstrating path-based routing with an NGINX Ingress controller, fronting two independent backend services on a bare-metal-style cluster.

## Architecture

flowchart LR
    Client -->|Host header + path| NodePort[NodePort :31978]
    NodePort --> IngressCtrl[ingress-nginx controller]
    IngressCtrl -->|/welcome| FrontendSvc[frontend-svc :80]
    IngressCtrl -->|/data| BackendSvc[backend-svc :5678]
    FrontendSvc --> FrontendPod[frontend pod]
    BackendSvc --> BackendPod[backend pod]

## Stack

- Kubernetes cluster: 1 control-plane + 2 worker nodes
- Ingress Controller: `ingress-nginx`
- `frontend` — `nginxdemos/hello` (port 80)
- `backend` — `hashicorp/http-echo` (port 5678)
- TLS material provided (`tls.crt`, `tls.key`) — not yet wired into the Ingress

## Files

| File | Purpose |
|---|---|
| `deploy.yaml` | Deployments + Services for frontend and backend |
| `ingress-resource.yaml` | Ingress rules for path-based routing |
| `tls.crt` / `tls.key` | TLS cert pair (pending integration) |
| `about.txt` | Project notes |

## Setup

```bash
kubectl apply -f deploy.yaml
kubectl apply -f ingress-resource.yaml
```

Ingress controller service must be reachable externally. On bare-metal clusters without a cloud load balancer, that's why switch it to NodePort:

```bash
kubectl edit svc -n ingress-nginx ingress-nginx-controller
# change type: LoadBalancer -> type: NodePort
```

## Testing

Route by Host header (no real DNS involved):

```bash
curl -H "Host: my-local-apps.com" http://<node-ip>:<nodeport>/welcome
curl -H "Host: my-local-apps.com" http://<node-ip>:<nodeport>/data
```

Or map it locally for browser-style access:

```bash
echo "<node-ip>  my-local-apps.com" | sudo tee -a /etc/hosts
curl http://my-local-apps.com:<nodeport>/welcome
```

## Key Concepts Covered

- ClusterIP vs NodePort vs LoadBalancer
- Ingress routing by Host header + path, not IP/DNS
- Service port ↔ Ingress backend port alignment
- Pod network isolation (why pod IPs aren't externally reachable)
- Layered network troubleshooting: `ping` → `nc` → local curl → firewall rule

