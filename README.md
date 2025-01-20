# Setting Up Your Environment (for Graders or New Users)

## LOCAL DEVELOPMENT
Create a new folder on your machine and clone the repository into it.
```bash
git clone https://github.com/TytanGorilla/django-kubernetes-test.git
```

# OR

## ONLINE DEVELOPMENT (GITHUB CODESPACES) - RECOMMENDED 
While inspecting the repository, click the green code button and select "Open with Codespaces"

### Check current environment for python version
```bash
python --version
# or
python3 --version
```
#### If not installed, install python3
```bash
sudo apt install python3
```
Considerations: Desipite the application being contained within a docker container, the application is still dependent on the host machine's python version. If you are comfortable with global python installation, proceed. If not, consider using a virtual environment.

## Check installed tools
### Docker
```bash
docker --version
```
#### If not installed, install docker
```bash
sudo apt install docker.io
```

### Kubernetes
```bash
kubectl version --client
```

#### If not installed, install kubectl
```bash
sudo snap install kubectl --classic
```


## Create a .env File
Create a .env file in the project's root directory.
```bash
touch .env
```

Copy the example below into a new file named `.env` in the project’s root directory (same folder as `generate_secrets.sh`). Replace any placeholder values (***) with your actual credentials or desired settings. 

For the `DATABASE_URL`, the value should be in the format `postgresql://username:password@host:port/database_name`. Whatever the values for `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_HOST` are, they should be the same as the values in the `.env` file. Use them in the `DATABASE_URL`.

### Example .env
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
### Generating a Django Secret Key
To generate a Django secret key for your project, run the following command:

```bash
python generate_django_secret_key.py
```
This will generate a secure secret key, save it into the newly created .env file as the value of DJANGO_SECRET_KEY. Ensure that this value is within "quotes".

## Generate Your secrets.yaml
Make sure the generate_secrets.sh file is executable:

```bash
chmod +x generate_secrets_configs.sh
```

Run the script to create a new secrets.yaml:

```bash
./generate_secrets_configs.sh
```
This reads the .env file, Base64-encodes each variable, and produces a Kubernetes Secret manifest named secrets.yaml. Found in the k8s/secrets directory.

## Ensure that the local Kubernetes cluster is running
```bash
minikube start
```
Look for the message "🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default"
### Check the status of the local Kubernetes cluster
```bash
kubectl cluster-info
```

### Check configuration
```bash
kubectl config view
```
Ensure the 'current-context: minikube' is present.
If developing locally, the current-context could be docker-desktop or minikube.

## Apply the Secrets and Other Manifests to Kubernetes

```bash
kubectl apply -f k8s/ --recursive
```
The secrets from your newly created secrets.yaml are now in the cluster.
The django-deployment.yaml and django-service.yaml define how your Django application is deployed and exposed.

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

## Access Your Django App ****
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

## DELETING & REAPPLYING MANIFESTS
```bash
kubectl delete -f k8s/ --recursive
kubectl apply -f k8s/ --recursive
```