# Required GitHub Secrets

These must be added to your GitHub repo Settings > Secrets and variables > Actions for automated deployment.

| Secret Name           | Description                          | Current Value | Source/Example Value                                  |
| --------------------- | ------------------------------------ | ------------- | ----------------------------------------------------- |
| `GCP_PROJECT_ID`      | GCP project identifier               | `riderwin-flarum` | From GCP Console > Project Info                       |
| `GCP_SA_KEY`          | Service account JSON key             | ✅ Configured | Contents of `flarum-deployer-key.json`                |
| `GCP_SSH_PRIVATE_KEY` | Private SSH key for VM access        | ✅ Configured | Contents of `~/.ssh/flarum_devops`                    |
| `DB_PASSWORD`         | Database password for Flarum         | `RiderWin123!@#` | User-defined strong password                          |

## 🔧 Setup Instructions

### 1. GCP Service Account Key (`GCP_SA_KEY`)
```bash
# Create service account (if not exists)
gcloud iam service-accounts create flarum-deployer \
    --description="Service account for Flarum deployment" \
    --display-name="Flarum Deployer" \
    --project=riderwin-flarum

# Grant necessary permissions
gcloud projects add-iam-policy-binding riderwin-flarum \
    --member="serviceAccount:flarum-deployer@riderwin-flarum.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding riderwin-flarum \
    --member="serviceAccount:flarum-deployer@riderwin-flarum.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

# Create and download key
gcloud iam service-accounts keys create flarum-deployer-key.json \
    --iam-account=flarum-deployer@riderwin-flarum.iam.gserviceaccount.com \
    --project=riderwin-flarum
```

### 2. SSH Key Setup (`GCP_SSH_PRIVATE_KEY`)
```bash
# Generate SSH key pair (if not exists)
ssh-keygen -t rsa -b 4096 -C "flarum-deploy" -f ~/.ssh/flarum_devops

# Add public key to GCP metadata
gcloud compute project-info add-metadata \
    --metadata-from-file ssh-keys=~/.ssh/flarum_devops.pub \
    --project=riderwin-flarum
```

### 3. GitHub Secrets Configuration
```bash
# Set all secrets via GitHub CLI
gh secret set GCP_PROJECT_ID --body "riderwin-flarum"
gh secret set GCP_SA_KEY --body "$(cat flarum-deployer-key.json)"
gh secret set GCP_SSH_PRIVATE_KEY --body "$(cat ~/.ssh/flarum_devops)"
gh secret set DB_PASSWORD --body "RiderWin123!@#"
```

## ⚠️ Important Notes

- **Security**: Never commit these values to the repository
- **GCP Permissions**: Service account needs Compute Admin and Cloud SQL Admin roles
- **SSH Key**: Public key must be added to GCP project metadata
- **Database**: Password is used for both Terraform and Flarum configuration
- **Validation**: All secrets are validated during GitHub Actions execution

## 🔍 Verification

Check if all secrets are properly configured:
```bash
gh secret list
```

Expected output:
```
DB_PASSWORD	2025-10-28T21:13:11Z
GCP_PROJECT_ID	2025-10-28T20:55:15Z
GCP_SA_KEY	2025-10-28T21:11:42Z
GCP_SSH_PRIVATE_KEY	2025-10-28T21:13:04Z
```
