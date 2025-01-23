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

### Install kind
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

#### Check kind's versioN
```bash
kind version
```

### Create a Kubernetes Cluster
```bash
kind create cluster --name my-cluster
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
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORTNAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
db               ClusterIP   10.96.196.171   <none>        5432/TCP         54s
django-service   NodePort    10.96.245.57    <none>        8000:30007/TCP   54s
kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP          2m53s
```

### Delete & Reapply manifest and restart the application
```bash
kubectl delete -f k8s/ --recursive
kubectl apply -f k8s/ --recursive
kubectl rollout restart deployment django-app
kubectl rollout restart deployment nginx
kubectl rollout restart deployment postgres
```
Or to restart all deployments
```bash
kubectl get deployments -o name | xargs -n 1 kubectl rollout restart
```

### Port Forwarding to Access the App From a Codespace
To access your app without Minikube tunnels or LoadBalancers, use `kubectl port-forward`:
```bash
kubectl port-forward service/django-service 8000:8000
```

### Accessing the application
This maps the a private URL found within the codespace's "PORTS" tab, to the local port 8000.

Under the forwarded address is the URL for your application.
```example of port forwarding from a codespace
https://cautious-journey-wxvjr657pvq2g55q-8000.app.github.dev/scheduler/
```
Equivalent to:
```example of port forwarding from a local host
http://localhost:8000/scheduler/
```

### Accessing the App locally using Docker Desktop with a Kubernetes Cluster
To access the application locally, use the URL http://localhost:30007

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
```bash
kubectl delete -f k8s/ --recursive
kubectl apply -f k8s/ --recursive
```

### Rebuilding the Docker Image with dated versioning
```bash
docker build -t tytan22/django-app:1.0.20250122 .
```
### Pushing the Docker Image to Docker Hub
```bash
docker push tytan22/django-app:1.0.20250122
```
### Updating django-app Deployment to use the new Docker Image
```yaml
containers:
- name: django-container
  image: tytan22/django-app:1.0.20250122
  imagePullPolicy: Always
```

