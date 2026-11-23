# MyDiary Helm deployment

## 1. Prerequisites
- Kubernetes cluster reachable by kubectl
- Helm 3
- Rancher local-path StorageClass named `local-path`
- Docker Hub images pushed to `cryptortheoneste/mydiary-frontend:1.0.0` and `cryptortheoneste/mydiary-backend:1.0.0`

## 2. Build and push images (run on c2-docker-host in the project-hub directory)
```bash
docker login
docker build -t cryptortheoneste/mydiary-frontend:1.0.0 ./frontend
docker build -t cryptortheoneste/mydiary-backend:1.0.0 ./backend
docker push cryptortheoneste/mydiary-frontend:1.0.0
docker push cryptortheoneste/mydiary-backend:1.0.0
```

## 3. Create application secrets (run on c2-k8s-master)
Generate a strong JWT secret and passwords. Do not commit these values to Git.
```bash
openssl rand -hex 32
kubectl create namespace mydiary
kubectl -n mydiary create secret generic mydiary-secrets \
  --from-literal=jwt-secret='REPLACE_WITH_GENERATED_64_HEX_CHAR_SECRET' \
  --from-literal=postgres-password='REPLACE_WITH_STRONG_DB_PASSWORD' \
  --from-literal=redis-password='REPLACE_WITH_STRONG_REDIS_PASSWORD'
```
Use passwords without shell-special characters for this lab, or carefully quote them.

## 4. Install
From the directory containing this chart:
```bash
helm upgrade --install mydiary ./mydiary-helm --namespace mydiary --create-namespace
kubectl -n mydiary get pods,svc,pvc
```
Access: `http://192.168.160.76:30080` (or either worker IP on port 30080).

## 5. Verify
```bash
kubectl -n mydiary rollout status statefulset/postgres
kubectl -n mydiary rollout status deployment/backend
kubectl -n mydiary rollout status deployment/frontend
kubectl -n mydiary rollout status deployment/nginx
curl http://192.168.160.76:30080/api/health
```

## 6. Persistence test
Create a user through the UI, then:
```bash
kubectl -n mydiary delete pod -l app=postgres
kubectl -n mydiary get pods -w
```
After PostgreSQL returns Ready, log in again. The PVC remains attached to the same node-local PV. This verifies pod replacement persistence, not node/disk failure recovery.

## Notes
- PostgreSQL uses a PVC backed by `local-path`. Redis intentionally has no PVC: it is a cache, can be rebuilt, and the application is designed to continue if Redis is unavailable.
- The chart uses the app's documented Spring Boot Actuator liveness/readiness endpoints.
- This chart is for the MyDiary source you showed, not the ProjectHub stack named in the exam text.
- The `mydiary` namespace is used to avoid mixing this deployment with other workloads.
