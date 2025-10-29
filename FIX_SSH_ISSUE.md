# Fix SSH Connection Issue

## Problem

SSH connection times out from everywhere (GitHub Actions, Cloud Shell, local machine).

## Diagnosis Commands (Run in Cloud Shell)

```bash
# 1. Check if VM is running
gcloud compute instances describe flarum-vm --zone=us-central1-a --format="value(status)"

# 2. Check VM's network tags
gcloud compute instances describe flarum-vm --zone=us-central1-a --format="value(tags.items)"

# 3. Check firewall rules
gcloud compute firewall-rules list --filter="name:flarum-ssh" --format="table(name,network,targetTags,allowed)"

# 4. Check if firewall rule exists and shows targetTags
gcloud compute firewall-rules describe flarum-ssh

# 5. Get VM's external IP
gcloud compute instances describe flarum-vm --zone=us-central1-a --format="value(networkInterfaces[0].accessConfigs[0].natIP)"

# 6. Test connectivity to SSH port
gcloud compute instances describe flarum-vm --zone=us-central1-a --format="value(networkInterfaces[0].accessConfigs[0].natIP)" | xargs -I {} nc -zv {} 22
```

## Most Likely Fix: Update VM Network Tags

The VM might not have the correct network tags for the firewall rule:

```bash
# Add the flarum-web tag to the VM (this allows the SSH firewall rule to apply)
gcloud compute instances add-tags flarum-vm \
  --zone=us-central1-a \
  --tags=flarum-web
```

## Alternative Fix: Recreate Firewall Rule

If the firewall rule is misconfigured:

```bash
# Delete existing SSH firewall rule
gcloud compute firewall-rules delete flarum-ssh

# Recreate it with correct settings
gcloud compute firewall-rules create flarum-ssh \
  --network=flarum-network \
  --allow=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=flarum-web \
  --description="Allow SSH access to Flarum VM"
```

## Nuclear Option: Stop and Start VM

Sometimes the VM needs a restart to apply network changes:

```bash
# Stop the VM
gcloud compute instances stop flarum-vm --zone=us-central1-a

# Wait 30 seconds
sleep 30

# Start the VM
gcloud compute instances start flarum-vm --zone=us-central1-a

# Wait for it to boot (2 minutes)
sleep 120

# Try connecting again
gcloud compute ssh flarum-vm --zone=us-central1-a
```

## Use Serial Console (Last Resort)

If SSH still doesn't work, use the Serial Console:

```bash
# Enable interactive serial console
gcloud compute instances add-metadata flarum-vm \
  --zone=us-central1-a \
  --metadata=serial-port-enable=TRUE

# Connect via serial console
gcloud compute connect-to-serial-port flarum-vm --zone=us-central1-a
```

Or use the GCP Console:

1. Go to Compute Engine → VM instances
2. Click on `flarum-vm`
3. Scroll down and click **"Connect to serial console"**

## Complete Rebuild (If Nothing Works)

If all else fails, recreate the infrastructure:

```bash
# 1. Delete existing VM
gcloud compute instances delete flarum-vm --zone=us-central1-a --quiet

# 2. From your local machine, run Terraform to recreate
cd /path/to/gcp-terraform-ansible-ghaction-flarum
cd terraform
terraform destroy -auto-approve
terraform apply -auto-approve
```

---

## Expected Output (When Working)

### Correct VM tags:

```
flarum-web
```

### Correct firewall rule:

```
NAME         NETWORK         TARGET_TAGS  ALLOWED
flarum-ssh   flarum-network  flarum-web   tcp:22
```

### Successful connection:

```
External IP address was not found; defaulting to using IAP tunneling.
Linux flarum-vm 5.15.0-1051-gcp #59~20.04.1-Ubuntu...
rocky@flarum-vm:~$
```
