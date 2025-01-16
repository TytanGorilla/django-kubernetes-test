# Setting Up Your Local Environment (for Graders or New Users)

## Clone the Repository

```bash
git clone https://github.com/yourusername/yourproject.git
cd yourproject
```

## Create a .env File

Copy the example below into a new file named .env in the project’s root directory (same folder as generate_secrets.sh).
Replace any placeholder values (***) with your actual credentials or desired settings.

```
# Example .env

# Django-related
DJANGO_SECRET_KEY=***
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1

# Postgres-related
POSTGRES_DB=***
POSTGRES_USER=***
POSTGRES_PASSWORD=***
POSTGRES_HOST=db
POSTGRES_PORT=5432

# Optional: If using a single connection string
# DATABASE_URL=postgresql://<user>:<pass>@<host>:<port>/<dbname>

```

## Generate Your secrets.yaml
Make sure the generate_secrets.sh file is executable:

```bash
chmod +x generate_secrets.sh
```

Run the script to create a new secrets.yaml:

```bash
./generate_secrets.sh
```
This reads the .env file, Base64-encodes each variable, and produces a Kubernetes Secret manifest named secrets.yaml. Found in the k8s/secrets directory.

## Apply the Secrets and Other Manifests to Kubernetes

```bash
kubectl delete -f k8s/ --recursive
kubectl apply -f k8s/ --recursive
```
The secrets from your newly created secrets.yaml are now in the cluster.
The deployment.yaml and service.yaml define how your Django application is deployed and exposed.

## Confirm Everything Is Running
Check pods and services:
```bash
kubectl get pods
kubectl get svc
```

If you see any errors, run:
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

## Access Your Django App
NodePort service: Visit http://localhost:<nodePort> 
Confirm the NodePort via:
```bash
kubectl get svc
```

Port-forwarding: Run
```bash
kubectl port-forward svc/django-service 8000:8000
```
## Debugging
```bash
kubectl describe pod -l app=django-app
```