#!/usr/bin/env python3
import os
import sys
import yaml

def update_file(filepath, env):
    with open(filepath, 'r') as f:
        data = yaml.safe_load(f)
    
    # Update storageClassName in spec for both PVCs.
    if 'spec' in data:
        if env == "local":
            data['spec']['storageClassName'] = "hostpath"
        elif env == "codespaces":
            data['spec']['storageClassName'] = "standard"
    
    # For staticfiles-pvc.yaml, update accessModes accordingly.
    basename = os.path.basename(filepath)
    if basename == "staticfiles-pvc.yaml":
        if env == "local":
            data['spec']['accessModes'] = ["ReadWriteMany"]
        elif env == "codespaces":
            data['spec']['accessModes'] = ["ReadWriteOnce"]
    # For postgres-pvc.yaml, leave accessModes unchanged.
    
    with open(filepath, 'w') as f:
        yaml.safe_dump(data, f, sort_keys=False)
    print(f"Updated {filepath} for {env} environment.")

def main():
    if len(sys.argv) < 2:
        print("Usage: python toggle_pvc.py [local|codespaces]")
        sys.exit(1)
    
    env = sys.argv[1].lower()
    if env not in ("local", "codespaces"):
        print("Invalid environment. Choose 'local' or 'codespaces'.")
        sys.exit(1)
    
    base_dir = os.path.join("k8s", "base", "pvc")
    files = ["postgres-pvc.yaml", "staticfiles-pvc.yaml"]
    
    for filename in files:
        filepath = os.path.join(base_dir, filename)
        if os.path.exists(filepath):
            update_file(filepath, env)
        else:
            print(f"File {filepath} not found.")
    
if __name__ == "__main__":
    main()