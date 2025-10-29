#!/bin/bash
# Manual Ansible Deployment Script

set -e

echo "==================================="
echo "Flarum Manual Deployment"
echo "==================================="

# Configuration
VM_IP="34.60.101.134"
ANSIBLE_USER="techcloudup_go_gmail_com"
DB_HOST="$VM_IP"
DB_NAME="flarum"
DB_USER="flarum"

# Get DB password from user
echo ""
echo "Enter your database password (from GitHub Secrets DB_PASSWORD):"
read -s DB_PASSWORD

if [ -z "$DB_PASSWORD" ]; then
  echo "Error: Database password cannot be empty"
  exit 1
fi

echo ""
echo "Creating inventory file..."

# Create inventory file
cat > inventory-manual.ini << EOF
[flarum]
$VM_IP ansible_user=$ANSIBLE_USER

[flarum:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
db_host=$DB_HOST
db_name=$DB_NAME
db_user=$DB_USER
db_password=$DB_PASSWORD
EOF

echo "Inventory file created: inventory-manual.ini"
echo ""
echo "Testing SSH connection to VM..."

# Test SSH connection
if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 $ANSIBLE_USER@$VM_IP 'echo SSH connection successful'; then
  echo "✅ SSH connection successful!"
else
  echo "❌ SSH connection failed. Make sure you can SSH to the VM from Cloud Shell first."
  exit 1
fi

echo ""
echo "Starting Ansible playbook deployment..."
echo "This will take 10-15 minutes..."
echo ""

# Run Ansible playbook
ansible-playbook -i inventory-manual.ini ansible/playbook.yml \
  -e "db_host=$DB_HOST" \
  -e "db_name=$DB_NAME" \
  -e "db_user=$DB_USER" \
  -e "db_password=$DB_PASSWORD" \
  -vv

echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="
echo ""
echo "Access your Flarum installation at:"
echo "http://$VM_IP"
echo ""
echo "Complete the setup through the web interface."

