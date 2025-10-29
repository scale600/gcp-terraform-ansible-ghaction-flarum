# SSH Connection Guide

## EASIEST METHOD: Use GCP Console (Recommended)

Since you don't have local gcloud permissions, use the GCP Console:

1. **Open GCP Console**: https://console.cloud.google.com
2. **Navigate to**: Compute Engine → VM instances
3. **Find**: `flarum-vm` in the list
4. **Click**: The **SSH** button next to the VM name
5. A new browser window will open with direct SSH access

✅ **This works instantly with no local setup required!**

---

## Alternative Methods (if console doesn't work)

### Method 2: Using VM IP with private key

```bash
# 1. Get VM IP
gcloud compute instances list --filter="name:flarum-vm" --format="value(EXTERNAL_IP)"

# 2. SSH with your private key
ssh -i /path/to/your/private/key rocky@<VM_IP>
```

### Method 3: gcloud SSH (requires local permissions)

```bash
gcloud compute ssh flarum-vm --zone=us-central1-a
```

---

## Once Connected to VM

### Quick Status Check

```bash
# Check system info
cat /etc/os-release
whoami
hostname

# Check if SSH is running
sudo systemctl status sshd

# Check disk space
df -h

# Check memory
free -h

# Check what's installed
which nginx php mysql
```

### Check Existing Installations

```bash
# Check if Flarum directory exists
ls -la /var/www/

# Check running services
sudo systemctl list-units --type=service --state=running

# Check if any web server is running
sudo ss -tulnp | grep -E ':80|:443'
```

### Run Ansible Playbook Manually (if needed)

If nothing is installed yet, you can run the Ansible playbook from your local machine:

```bash
# Get VM IP
VM_IP=$(gcloud compute instances list --filter="name:flarum-vm" --format="value(EXTERNAL_IP)")
echo "VM IP: $VM_IP"

# Get your DB password from GitHub Secrets
# Replace 'YOUR_DB_PASSWORD' with the actual password
DB_PASSWORD="YOUR_DB_PASSWORD"

# Create temporary inventory file
cat > inventory-manual.ini << EOF
[flarum]
$VM_IP ansible_user=rocky ansible_ssh_private_key_file=~/.ssh/flarum_devops

[flarum:vars]
db_host=$VM_IP
db_name=flarum
db_user=flarum
db_password=$DB_PASSWORD
EOF

# Run Ansible playbook
ansible-playbook -i inventory-manual.ini ansible/playbook.yml \
  -e "db_host=$VM_IP" \
  -e "db_name=flarum" \
  -e "db_user=flarum" \
  -e "db_password=$DB_PASSWORD" \
  -vv
```

---

## Troubleshooting

### If SSH button in console is disabled:

1. Check VM is running (status should be green/running)
2. Try stopping and starting the VM
3. Check firewall rules allow SSH (port 22)

### If you need to check firewall rules:

```bash
gcloud compute firewall-rules list --filter="name:flarum-ssh"
```

### Get VM details:

```bash
gcloud compute instances describe flarum-vm --zone=us-central1-a --format=json
```
