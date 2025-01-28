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
## Setup Simple Cloud Managed Database with Subabase
Visit [Supabase](https://supabase.com)
  - Setup a free account by signing in with your GitHub account.
  - Navigate to the database tab on the left of the initial screen.
  - At the top of the screen click the button "Connect".
  - A popup will appear titled "Connect to your project".
  - Select the tab "Connection String".
  - Type of "URI" should be selected, and Source should be "Primary Database".
  - Under "Session Pooler", under the connection string, click "View parameters".
```
host:aws-0-eu-central-1.pooler.supabase.com

port:5432

database:postgres

user:postgres.jxpsamnvzjziemtpziig

pool_mode: session
```
  - Copy each of these parameter values into your to be created .env file.

### Create a .env File
Create a `.env` file in the project’s root directory.
```bash
touch .env
```
Copy the example below into the `.env` file. Replace any placeholder values (***) with your actual credentials or desired settings.
Then populate the DATABASE_URL with the relevant values referenced in your .env file.
Example: DATABASE_URL="postgresql://postgres:example_password@:db.jxpsamnvzjziemtpziig.supabase.co:5432/postgres"

#### Example .env
```
DJANGO_SECRET_KEY="GENERATED_SECRET_KEY"
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,10.1.0.43,*
POSTGRES_DB=***
POSTGRES_USER=***
POSTGRES_PASSWORD="YOUR_SUPABASE_PASSWORD"
POSTGRES_HOST=***
POSTGRES_PORT=***
DATABASE_URL="postgresql://[POSTGRES_USER]:[POSTGRES_PASSWORD]@[POSTGRES_HOST]:[POSTGRES_PORT]/[POSTGRES_DB]"
STORAGE_PATH=autofilled
```

### Generate a Django Secret Key
To generate a secure secret key, run:
```bash
python generate_django_secret_key.py
```
Copy the key generated in your CLI.
The save it in your `.env` file as the value of `DJANGO_SECRET_KEY`.

### Generate Your `secrets.yaml`
Make the scripts executable:
```bash
chmod +x generate_secrets_configs.sh
chmod +x copy_static_to_docs.sh
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
NAME                          READY   STATUS    RESTARTS      AGE
django-app-5ffdf59874-nt5kk   1/1     Running   1 (20m ago)   15h
nginx-675678bc8c-7t7p9        1/1     Running   3 (19m ago)   15h
postgres-df8fc69d4-hlptz      1/1     Running   1 (20m ago)   15h
```
Check services:
```bash
kubectl get svc
```
Expected Output:
```bash
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORTNAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
db               ClusterIP   10.104.227.111   <none>        5432/TCP         15h
django-service   NodePort    10.98.214.242    <none>        8000:30007/TCP   15h
kubernetes       ClusterIP   10.96.0.1        <none>        443/TCP          11d
nginx-service    NodePort    10.108.113.22    <none>        80:32212/TCP     15h
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

### Test the database
#### Local Development
1) Download the PostgreSQL installer from the PostgreSQL Official Website.
2) During installation, select the Command Line Tools option.
3) After installation, add the bin directory to your PATH (e.g., C:\Program Files\PostgreSQL\15\bin).
4) Open a new terminal and verify:
```bash
psql --version
```

#### Code Space
For Debian-Based Codespaces (Default)
Codespaces are typically based on Ubuntu/Debian, so you can use apt to install the PostgreSQL client tools:

1) Open the Codespace terminal
Update the package list:
```bash
sudo apt update
```
2) Install the PostgreSQL client tools
```bash
sudo apt install -y postgresql-client
```
3) Open a new terminal and verify:
```bash
psql --version
```

Copy your own database connection string from your .env file.
```bash
psql postgresql://USERNAME:PASSWORD@HOST:PORT/DATABASE

Example:
postgresql://postgres.jxpsamnvzjziemtpziig:[YOUR-PASSWORD]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres
```

#### Expected Output
```bash
$ psql postgresql://postgres.jxpsamnvzjziemtpziig:Uyr04Wp9IoDd^h3@aws-0-eu-central-1.pooler.supabase.com:5432/postgres
psql (17.2, server 15.8)
WARNING: Console code page (850) differs from Windows code page (1252)
         8-bit characters might not work correctly. See psql reference
         page "Notes for Windows users" for details.
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off, ALPN: none)
Type "help" for help.
```

#### Test the database connection in the sqll shell
```sql
SELECT 'Connection successful!' AS message;
```
#### Expected Output
```bash
    message
-------------------
 Connection successful!
(1 row)
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
docker build -t tytan22/django-app:1.0.20250127 .
```
### Pushing the Docker Image to Docker Hub
```bash
docker push tytan22/django-app:1.0.20250127
```
### Updating django-app Deployment to use the new Docker Image
```yaml
containers:
- name: django-container
  image: tytan22/django-app:1.0.20250127 # Update this line to use the new image that is dated
  imagePullPolicy: Always
```

