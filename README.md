# GCP Flarum Deployment

Deploy Flarum forum on GCP Free Tier with Terraform + Ansible + GitHub Actions.

## 🚀 Quick Start

1. **Fork this repo**
2. **Set GitHub Secrets** (see below)
3. **Push to main** - auto-deploy!

## 🔑 Required GitHub Secrets

Go to: Settings > Secrets and variables > Actions

| Secret | Value |
|--------|-------|
| `GCP_PROJECT_ID` | Your GCP project ID |
| `GCP_SA_KEY` | Service account JSON key |
| `GCP_SSH_PRIVATE_KEY` | SSH private key |
| `DB_PASSWORD` | Database password |

## 🛠️ Setup

### 1. GCP Setup

```bash
# Create project
gcloud projects create YOUR_PROJECT_ID

# Enable APIs
gcloud services enable compute.googleapis.com sqladmin.googleapis.com

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

### 3. GitHub Secrets

```bash
# Set secrets
gh secret set GCP_PROJECT_ID --body "YOUR_PROJECT_ID"
gh secret set GCP_SA_KEY --body "$(cat key.json)"
gh secret set GCP_SSH_PRIVATE_KEY --body "$(cat ~/.ssh/flarum_devops)"
gh secret set DB_PASSWORD --body "YOUR_PASSWORD"
```

## 📁 Project Structure

```
├── terraform/          # Infrastructure code
├── ansible/           # Application deployment
├── .github/workflows/ # CI/CD pipelines
└── scripts/           # Utility scripts
```

## 🎯 What Gets Deployed

- **VM**: e2-micro (1 vCPU, 1GB RAM)
- **Database**: Cloud SQL (db-f1-micro)
- **OS**: Rocky Linux 9
- **Web**: Nginx + PHP 8.1 + Flarum

## 🔧 Customization

Edit these files to customize:

- `terraform/main.tf` - Infrastructure settings
- `ansible/playbook.yml` - Application configuration
- `ansible/templates/` - Configuration templates

## 🚨 Troubleshooting

### Common Issues

1. **API not enabled**: Enable Compute Engine and Cloud SQL APIs
2. **Permission denied**: Check service account roles
3. **SSH failed**: Verify SSH key in GCP metadata
4. **Deployment timeout**: Check VM startup logs

### Cleanup

```bash
# Remove all resources
./scripts/cleanup-gcp-resources.sh
```

## 📊 Monitoring

After deployment, access your forum at: `http://YOUR_VM_IP`

Check logs:
```bash
# VM logs
sudo journalctl -u nginx
sudo journalctl -u php81-php-fpm

# Flarum logs
sudo tail -f /var/log/flarum/memory.log
```

## 💰 Cost

- **Free Tier**: $0/month (within limits)
- **VM**: e2-micro (744 hours/month free)
- **Database**: db-f1-micro (744 hours/month free)
- **Storage**: 30GB free

## 📚 Documentation

- [Performance Guide](PERFORMANCE_GUIDE.md) - Optimization tips
- [Optimization Guide](OPTIMIZATION.md) - Resource tuning
- [Secrets Setup](SECRETS.md) - Detailed secret configuration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.