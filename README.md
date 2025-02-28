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

Create a project, and store that database password, this will fill the POSTGRES_PASSWORD.
***AVOID creating a password that contains special characters, URL parse those differently!***

#### Make scripts executable
Make relevant scripts executable:
```bash
chmod +x generate_k8s_secrets_configs.sh
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
  - At the top of the screen click the button "Connect".
  - A popup will appear titled "Connect to your project".
  - Select the tab "Connection String".
  - Type of "URI" should be selected, and Source should be "Primary Database".
  - Under "Session Pooler", is your database URL & Parameters.
  - Click > "View parameters"

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

### Generate a Django Secret Key
To generate a secure secret key, run the following command IN the backend directory:
```bash
cd backend
python generate_django_secret_key.py
```
Copy the key generated password in your CLI.
The save it in your `.env.secrets` file as the value of `DJANGO_SECRET_KEY`.

The values of DJANGO_SECRET_KEY, POSTGRES_PASSWORD & DATABASE_URL, should be in quotations to prevent odd characters influencing the necessary database connection.

Then populate the DATABASE_URL with the copied URL from the top of the "View Parameters". Then complete that URL, by adding your recently created Supabase project password. This is DIFFERENT from the password used to log into your Supabase account.

Example 1: 
```
DATABASE_URL="postgresql://[POSTGRES_USER]:[POSTGRES_PASSWORD]@[POSTGRES_HOST]:[POSTGRES_PORT]/[POSTGRES_DB]"
```

Example 2:
Remove "[]" when completing this URL
```
DATABASE_URL="postgresql://postgres.vdapyfjuljtcxtzhhbvx:[YOUR-PASSWORD]@aws-0-us-west-1.pooler.supabase.com:5432/postgres"
```

```
DATABASE_URL="postgresql://postgres.vdapyfjuljtcxtzhhbvx:[YOUR-PASSWORD]@aws-0-us-west-1.pooler.supabase.com:5432/postgres"
POSTGRES_PASSWORD="YOUR_SUPABASE_PASSWORD"
DJANGO_SECRET_KEY="GENERATED_SECRET_KEY"
```
Save the backend/.env.secrets file!

Then update your backend .env.config with YOUR OWN Supabase parameters
```
POSTGRES_DB=postgres
POSTGRES_USER=postgres.jxpsamnvzjziemtpziig  # CHANGE THIS LINE
POSTGRES_HOST=aws-0-eu-central-1.pooler.supabase.com # CHANGE THIS LINE
POSTGRES_PORT=5432
```
Save the backend/.env.config file!

## Update frontend .env variable files (.env.config & .env.secrets_example_frontend)
Rename .env.secrets_example_frontend -> .env.secrets
This is your own frontend secrets environment file.
Populate its contents with your sensitive information.

Obtain your Supabase Anonymous key:
1) Click the Gear cog "Project Settings" on the left pop up menu.
2) Under CONFIGURATION, Click "Data API" on the left persistent menu.
3) Under API Settings, Under Project API Keys, "anon public"
3) Copy your anonymous public key and paste it in your frontend/.env.secrets
```
REACT_APP_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANONYMOUS_KEY
```
Save the frontend/.env.secrets file!

Then update your frontend .env.config with YOUR OWN PROJECT's Supabase URL.

The REACT_APP_SUPABASE_URL is your Supabase project URL, which is also found under the same place "Data API" -> API Settings -> Project URL, copy & paste this value.

The REACT_APP_BACKEND_URL in Codespace should be:
```bash
REACT_APP_BACKEND_URL=https://32212-your-codespace-id.githubpreview.dev
```

To complete this for your own unique codespace instance, look at your CLI:
```bash
root@codespaces-22fdef:/workspaces/django-kubernetes-test#
```

Complete the BACKEND_URL, should look something like this:
```bash
REACT_APP_BACKEND_URL=https://32212-22fdef.githubpreview.dev
```

The REACT_APP_BACKEND_URL in Local Development should be:
```bash
REACT_APP_BACKEND_URL=http://localhost:32212
```

### Example of frontend .env.config LOCALLY
```
REACT_APP_BACKEND_URL=http://localhost:32212
REACT_APP_SUPABASE_URL=https://jxpsamnvzjziemtpziig.supabase.co
```

### Example of frontend .env.config in CODESPACE
```
REACT_APP_BACKEND_URL=https://32212-22fdef.githubpreview.dev
REACT_APP_SUPABASE_URL=https://jxpsamnvzjziemtpziig.supabase.co
```
Save the frontend/.env.config file!

### Generate Your Kubernetes Manifests 
ENSURE YOU HAVE SAVED YOUR CHANGES TO ALL THE .env.secrets & .env.configs IN BOTH the frontend & backend folders.

Run the following script FROM THE ROOT folder to create a new `secrets & configs`:
```bash
./generate_k8s_secrets_configs.sh
```
This reads the `.env` files (.env.config & .env.secrets), within both the backend & frontend folders, Base64-encodes variables, and produces a Kubernetes manifests -> k8s/base/secrets/consolidated-secrets.yaml & k8s/base/configmaps/consolidated-config.yaml.

### Set up PVC
This following script "toggles" certain variables within the staticfiles-pvc.yaml & postgres-pvc.yaml to correctly mount PVC according to the environment in which this software is being set up in.

Run the following if you are local:
```bash
python toggle_pvc.py local
```
OR Run the following if you in a codespace:
```bash
python toggle_pvc.py codespaces
```

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

Copy your own database connection string from your backend/.env.secrets file.
Preappend "psql" to your CLI bash, paste your DATABASE_URL
```bash
Example:
psql postgresql://postgres.jxpsamnvzjziemtpziig:[YOUR-PASSWORD]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres
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
### Expected Output
```bash
                   List of relations
 Schema |            Name            | Type  |  Owner
--------+----------------------------+-------+----------
 public | auth_group                 | table | postgres
 public | auth_group_permissions     | table | postgres
 public | auth_permission            | table | postgres
 public | auth_user                  | table | postgres
 public | auth_user_groups           | table | postgres
 public | auth_user_user_permissions | table | postgres
 public | django_admin_log           | table | postgres
 public | django_content_type        | table | postgres
 public | django_migrations          | table | postgres
 public | django_session             | table | postgres
 public | scheduler_event            | table | postgres
(11 rows)
```

### Port Forwarding to Access the App From a Codespace
To access your app without Minikube tunnels or LoadBalancers, use `kubectl port-forward`:
```bash
kubectl port-forward service/nginx-service 32212:80
```
This command forwards traffic from your local port 32212 to port 80 on the nginx-service. 
Then, when you visit http://localhost:32212 (or use your Codespace’s forwarded URL), you'll hit the nginx service as expected.

### Accessing the application
Under the forwarded address tab is the URL for your application.

Example of forwarded port from a codespace
https://cautious-journey-wxvjr657pvq2g55q-8000.app.github.dev/ *** REPLACE


### Accessing the App locally using Docker Desktop with a Kubernetes Cluster
To access the application locally, use the URL
http://localhost:32212/

## TESTING
If you have reached this stage in the README, you have successfully deployed the application to Kubernetes! Congratulations! Now you can proceed to browser testing / grading the application.

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

Connecting Interpod communication
Find a pods endpoint
```bash
kubectl get endpoints django-service
```

Installing curl on the fly inside a pod
```bash
apt-get update && apt-get install -y curl
```

### Deleting hanging PVC
Running the following script aids in clearing leftover finalizers that could prevent applying the new PVC.
```bash
./reset_redeploy.sh
```