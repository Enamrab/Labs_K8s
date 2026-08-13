# Labs_K8s

A collection of hands-on Kubernetes and containerization labs, built to learn and demonstrate core cluster operations, security, and application deployment patterns.

## Projects

### 🐳 flask-app — Containerized 3-Tier Application
A Flask REST API backed by MySQL, served through an Nginx reverse proxy, orchestrated with Docker Compose.
- Flask app with `/tasks` GET/POST endpoints
- MySQL persistence with connection retry handling
- Nginx as reverse proxy in front of the app
- Environment-based configuration via `.env`

**Run it:** `docker-compose up --build`

---

### 📈 hpa_hands_on — Horizontal Pod Autoscaling
Demonstrates Kubernetes HPA behavior under sustained CPU load.
- CPU-based HPA (`autoscaling/v2`), scales up to 150 replicas
- Synthetic load-generating deployment used to trigger and observe scaling
- Includes Job manifests for controlled load testing

**Try it:** `kubectl apply -f mydeploy.yaml -f hpa.yaml` then watch with `kubectl get hpa -w`

---

### 🌐 ingress-live-project — Path-Based Ingress with TLS
A mock frontend/backend app exposed through an NGINX ingress controller with path-based routing and TLS termination.
- Two backend services (`frontend-svc`, `backend-svc`) routed via path rules
- Self-signed TLS cert generated with OpenSSL, applied as a Kubernetes Secret
- Covers `rewrite-target` annotation and why it's needed for path-based routing

**Notes:** See `about.txt` for the full walkthrough and gotchas encountered.

---

### 🔐 kubeconfig-demo-rbac — Cluster RBAC with Scoped Access
Implements least-privilege cluster access for a sample user ("bob") using Kubernetes' native certificate-based auth.
- Client certificate issued via a `CertificateSigningRequest`
- Custom `kubeconfig` generated to scope "bob" to a specific Role/RoleBinding
- Demonstrates the full cert-request → approve → bind → authenticate flow

---

### 💾 live_project_php — Stateful App with PV/PVC/ConfigMap/Secrets
A PHP + MySQL application demonstrating persistent storage and externalized configuration in Kubernetes.
- `PersistentVolume` + `PersistentVolumeClaim` for MySQL data durability
- `ConfigMap` and `Secret` used to externalize app config and credentials
- Full deploy/service manifests for a stateful backend

---
### 🖥️ bash-scripts — Shell Scripting Fundamentals
A few standalone scripts demonstrating core Bash concepts: argument parsing, command substitution, and control flow.

- **`demo_backup.sh`** — Backs up a target directory to a timestamped `.tar` archive, using command substitution and string manipulation for dynamic naming.
- **`temp_conv.sh`** — Fahrenheit ↔ Celsius converter using `getopts` for flag-based input.
- **`timer.sh`** — Countdown timer that parses minutes/seconds via `getopts` and counts down using a `while` loop.

**Run any script:** `bash bash-scripts/<script-name>.sh'
---

## Stack
`Kubernetes` `Docker` `Docker Compose` `NGINX` `MySQL` `Flask` `Python` `Bash`

## Purpose
These labs were built as part of my hands-on preparation for the **Certified Kubernetes Administrator (CKA)** exam, covering core exam domains: workloads & scheduling, services & networking, storage, and cluster architecture/security.
