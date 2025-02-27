# Setting Up Your Environment (for Graders or New Users)

## LOCAL DEVELOPMENT
Create a new folder on your machine and clone the repository into it.
```bash
git clone https://github.com/TytanGorilla/django-kubernetes-test.git
```

## ONLINE DEVELOPMENT (GITHUB CODESPACES) - RECOMMENDED
While inspecting the repository, click the green code button and select "Open with Codespaces."

## Other requirements
This application relies on an external cloud managed database Supabase https://supabase.com/dashboard/sign-up
Create a free easy to use account there https://supabase.com/dashboard/new?plan=free
Provide an organization name
Type of organization is personal
Plan : Free - $0/month
Click "Create organization"
Proceed filling out only where necessary, and keep the pre selected defaults.

#### Make scripts executable
Make relevant scripts executable:
```bash
chmod +x generate_k8s_secrets_configs.sh
chmod +x make_migrations_local.sh
chmod +x build_deploy.sh
chmod +x reset_redeploy.sh
chmod +x install_kind.sh
```

### Create A Kubernetes Cluster
```bash
./install_kind.sh
```

Expected Output:
```bash
Creating cluster "my-cluster" ...
 ✓ Ensuring node image (kindest/node:v1.32.1) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-my-cluster"
You can now use your cluster with:

kubectl cluster-info --context kind-my-cluster
```
## Setup Simple Cloud Managed Database with Supabase
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

## Update backend .env variable files (.env.config & .env.secrets_example_backend)
Rename .env.secrets_example_backend -> .env.secrets
This is your own backend secrets environment file.
Populate its contents with your sensitive information, and soon to be generated DJANGO_SECRET_KEY

Run the following command from the backend directory.
```bash
generate_django_secret_key.py
```

```
DATABASE_URL="postgresql://[POSTGRES_USER]:[POSTGRES_PASSWORD]@[POSTGRES_HOST]:[POSTGRES_PORT]/[POSTGRES_DB]"
POSTGRES_PASSWORD="YOUR_SUPABASE_PASSWORD"
DJANGO_SECRET_KEY="GENERATED_SECRET_KEY"
```

Then update your backend .env.config with YOUR OWN Supabase parameters
```
POSTGRES_DB=postgres
POSTGRES_USER=postgres.jxpsamnvzjziemtpziig
POSTGRES_HOST=aws-0-eu-central-1.pooler.supabase.com
POSTGRES_PORT=5432
```

### Generate a Django Secret Key
To generate a secure secret key, run the following command IN the backend directory:
```bash
cd backend
python generate_django_secret_key.py
```
Copy the key generated password in your CLI.
The save it in your `.env.secrets` file as the value of `DJANGO_SECRET_KEY`.

## Supabase parameters -> .env.secret Values 
```
host:aws-0-eu-central-1.pooler.supabase.com -> POSTGRES_HOST

port:5432 -> POSTGRES_PORT

database:postgres -> POSTGRES_DB

user:postgres.jxpsamnvzjziemtpziig -> POSTGRES_USER

password: NOT SHOWN HERE, but is the password you set for your Supabase account. This password fills the POSTGRES_PASSWORD value in the frontend/.env.secrets file.

```
  - The values of DJANGO_SECRET_KEY, POSTGRES_PASSWORD & DATABASE_URL, should be in quotations to prevent odd characters influencing the necessary database connection.

Then populate the DATABASE_URL with the relevant values referencing variables listed in the frontend's .env.config & .env.secrets.

Example 1: 
```
DATABASE_URL="postgresql://POSTGRES_USER:YOUR_SUPABASE_PASSWORD@POSTGRES_HOST:POSTGRES_PORT/POSTGRES_DB"
```

Example 2:
```
DATABASE_URL="postgresql://postgres.jxpsamnvzjziemtpziig:YOUR_SUPABASE_PASSWORD@aws-0-eu-central-1.pooler.supabase.com:5432/postgres"
```

## Update frontend .env variable files (.env.config & .env.secrets_example_frontend)
Rename .env.secrets_example_frontend -> .env.secrets
This is your own frontend secrets environment file.
Populate its contents with your sensitive information.

Obtain your Supabase Anonymous key:
1) Click the Gear cog "Project Settings"
2) Under CONFIGURATION, "Data API"
3) Copy your anonymous public key and paste it in your frontend/.env.secrets
```
REACT_APP_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANONYMOUS_KEY
```

Then update your frontend .env.config with YOUR OWN Supabase parameters
```
REACT_APP_BACKEND_URL=http://localhost:32212
REACT_APP_SUPABASE_URL=https://jxpsamnvzjziemtpziig.supabase.co
```

### Generate Your Kubernetes Manifests `django-secrets.yaml, frontend-secrets.yaml` & `django-config.yaml, frontend-config.yaml`
ENSURE YOU HAVE SAVED YOUR CHANGES TO ALL THE .env.secrets & .env.configs IN BOTH the frontend & backend folders.

Run the script to create a new `secrets & configs` file FROM THE ROOT folder:
```bash
./generate_k8s_secrets_configs.sh
```
This reads the `.env` files (.env.config & .env.secrets), within both the backend & frontend folders, Base64-encodes variables, and produces a Kubernetes manifests -> k8s/base/secrets/consolidated-secrets.yaml & k8s/base/configmaps/consolidated-config.yaml.

### Deploy
Apply secrets, manifests & restarts deployments:
```bash
./reset_redeploy.sh
```

### Verify pods
```bash
kubectl get pods
```

Expected Output:
```bash
NAME                          READY   STATUS    RESTARTS      AGE
django-app-5ffdf59874-nt5kk   1/1     Running   0             44s
nginx-675678bc8c-7t7p9        1/1     Running   0             44s
postgres-df8fc69d4-hlptz      1/1     Running   0             44s
```
Check services:
```bash
kubectl get svc
```
Expected Output:
```bash
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
db               ClusterIP   10.96.35.129    <none>        5432/TCP         100s
django-service   NodePort    10.96.56.138    <none>        8000:30007/TCP   100s
kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP          5m48s
nginx-service    NodePort    10.96.245.237   <none>        80:32212/TCP     100s
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
apt update
```
2) Install the PostgreSQL client tools
```bash
apt install -y postgresql-client
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
$ psql postgresql://postgres.jxpsamnvzjziemtpziig:[YOUR-PASSWORD]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres
psql (17.2, server 15.8)
WARNING: Console code page (850) differs from Windows code page (1252)
         8-bit characters might not work correctly. See psql reference
         page "Notes for Windows users" for details.
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off, ALPN: none)
Type "help" for help.
```

#### Test the database connection in the sql shell
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

### Check database table schema
```sql
\dt
```

### Port Forwarding to Access the App From a Codespace
To access your app without Minikube tunnels or LoadBalancers, use `kubectl port-forward`:
```bash
kubectl port-forward service/django-service 8000:8000
```

### Accessing the application
This maps the a private URL found within the codespace's "PORTS" tab, to the local port 8000.

Under the forwarded address is the URL for your application.
```
Example of port forwarding from a codespace
https://cautious-journey-wxvjr657pvq2g55q-8000.app.github.dev/

Ensure that you append /scheduler/ to the end of the URL, becoming:
https://cautious-journey-wxvjr657pvq2g55q-8000.app.github.dev/scheduler/
```
Equivalent to:
```example of port forwarding from a local host
http://localhost:8000/
```

### Accessing the App locally using Docker Desktop with a Kubernetes Cluster
To access the application locally, use the URL
http://localhost:32212/

## TESTING
If you have reached this stage in the README, you have successfully deployed the application to Kubernetes! Congratulations! Now you can proceed to testing / grading the application.

***********************************************************************************************

### Debugging
Check logs if the application does not behave as expected:
```bash
kubectl logs -f -l app=django-app
```
Describe the pod for detailed diagnostics:
```bash
kubectl describe pod -l app=django-app
```

### Making migrations locally for version control
```bash
./make_migrations_local.sh
```

### Creating Migrations Locally only after models changes UNSURE
```bash
DATABASE_URL="postgresql://postgres.jxpsamnvzjziemtpziig:Uyr04Wp9IoDd^h3@aws-0-eu-central-1.pooler.supabase.com:5432/postgres" python manage.py makemigrations scheduler

# To force creation use --empty
DATABASE_URL="postgresql://postgres.jxpsamnvzjziemtpziig:Uyr04Wp9IoDd^h3@aws-0-eu-central-1.pooler.supabase.com:5432/postgres" python manage.py makemigrations scheduler --empty
```


### Bashing into the active django-app pod
```bash
kubectl exec -it $(kubectl get pod -l app=django-app -o jsonpath="{.items[0].metadata.name}") -- bash
```

Connecting Interpod communication
Find a pods endpoint
```bash
kubectl get endpoints django-service
```

Installing curl on the fly inside a pod
```bash
apt-get update && apt-get install -y curl
```