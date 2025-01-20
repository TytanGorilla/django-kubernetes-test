# Setting Up Your Environment (for Graders or New Users)

## LOCAL DEVELOPMENT
Create a new folder on your machine and clone the repository into it.
```bash
git clone https://github.com/TytanGorilla/django-kubernetes-test.git
```

## ONLINE DEVELOPMENT (GITHUB CODESPACES) - RECOMMENDED
While inspecting the repository, click the green code button and select "Open with Codespaces."

### Check Python Version
```bash
python --version
# or
python3 --version
```
#### If not installed, install Python3
```bash
sudo apt install python3
```
> **Note**: While the application is containerized, the host machine’s Python version is still required for certain scripts and configurations. Consider using a virtual environment if you are not comfortable with global Python installations.

### Check Docker Installation
```bash
docker --version
```
#### If not installed, install Docker
```bash
sudo apt install docker.io
```

### Create a .env File
Create a `.env` file in the project’s root directory.
```bash
touch .env
```
Copy the example below into the `.env` file. Replace any placeholder values (***) with your actual credentials or desired settings.

For `DATABASE_URL`, use the format: `postgresql://username:password@host:port/database_name`.

#### Example .env
```
DJANGO_SECRET_KEY="GENERATED_SECRET_KEY"
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,10.1.0.43,*
POSTGRES_DB=***
POSTGRES_USER=***
POSTGRES_PASSWORD=***
POSTGRES_HOST=db
DATABASE_URL="postgresql://***:***@db:5432/***"
POSTGRES_PORT=5432
STORAGE_PATH=autofilled
```

### Generate a Django Secret Key
To generate a secure secret key, run:
```bash
python generate_django_secret_key.py
```
Save the key in the `.env` file as the value of `DJANGO_SECRET_KEY`.

### Generate Your `secrets.yaml`
Make the script executable:
```bash
chmod +x generate_secrets_configs.sh
```
Run the script to create a new `secrets.yaml` file:
```bash
./generate_secrets_configs.sh
```
This reads the `.env` file, Base64-encodes variables, and produces a Kubernetes Secret manifest named `secrets.yaml` in the `k8s/secrets` directory.

### Apply Manifests to Kubernetes
Apply the secrets and other manifests:
```bash
kubectl apply -f k8s/ --recursive
```
This deploys the application to Kubernetes.

### Verify Deployment
After 30 seconds, check that the pods are running:
```bash
kubectl get pods
```
Expected Output:
```bash
NAME                         READY   STATUS    RESTARTS   AGE
django-app-9c5675d7d-q58wt   1/1     Running   0          94s
postgres-6ff4d97f74-4zjw9    1/1     Running   0          94s
```
Check services:
```bash
kubectl get svc
```
Expected Output:
```bash
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
db               ClusterIP   10.110.145.2   <none>        5432/TCP         3m28s
django-service   NodePort    10.108.200.125 <none>        8000:30007/TCP   3m28s
```

### Port Forwarding to Access the App
To access your app without Minikube tunnels or LoadBalancers, use `kubectl port-forward`:
```bash
kubectl port-forward service/django-service 8000:8000
```
This maps the service to `localhost:8000`. Open your browser and navigate to:
```
http://localhost:8000
```

> **Note**: If using GitHub Codespaces, ensure port `8000` is added in the Ports tab and set to **Public**.

### Debugging
Check logs if the application does not behave as expected:
```bash
kubectl logs -f -l app=django-app
```
Describe the pod for detailed diagnostics:
```bash
kubectl describe pod -l app=django-app
```

### Deleting and Reapplying Manifests
To restart the deployment cleanly:
```bash
kubectl delete -f k8s/ --recursive
kubectl apply -f k8s/ --recursive
```

