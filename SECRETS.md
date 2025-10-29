# GitHub Secrets Setup

Configure these secrets in: Settings > Secrets and variables > Actions

## Required Secrets

| Secret                | Description          | Example                               |
| --------------------- | -------------------- | ------------------------------------- |
| `GCP_PROJECT_ID`      | GCP project ID       | `my-flarum-project`                   |
| `GCP_SA_KEY`          | Service account JSON | `{"type": "service_account"...}`      |
| `GCP_SSH_PRIVATE_KEY` | SSH private key      | `-----BEGIN OPENSSH PRIVATE KEY-----` |
| `DB_PASSWORD`         | Database password    | `MySecurePass123!`                    |

## Quick Setup

### 1. GCP Service Account

```bash
# Create service account
gcloud iam service-accounts create flarum-deployer --project=YOUR_PROJECT_ID

# Grant permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:flarum-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:flarum-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

# Create key
gcloud iam service-accounts keys create key.json \
    --iam-account=flarum-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### 2. SSH Key

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/flarum_devops

# Add to GCP
gcloud compute project-info add-metadata \
    --metadata-from-file ssh-keys=~/.ssh/flarum_devops.pub
```

### 3. Set GitHub Secrets

```bash
# Via GitHub CLI
gh secret set GCP_PROJECT_ID --body "YOUR_PROJECT_ID"
gh secret set GCP_SA_KEY --body "$(cat key.json)"
gh secret set GCP_SSH_PRIVATE_KEY --body "$(cat ~/.ssh/flarum_devops)"
gh secret set DB_PASSWORD --body "YOUR_PASSWORD"
```

## Verification

```bash
# Check secrets
gh secret list
```

## Security Notes

- Never commit secrets to repository
- Use strong passwords (12+ characters)
- Rotate secrets regularly
- Monitor GCP audit logs
