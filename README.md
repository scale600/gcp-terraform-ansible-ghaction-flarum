# Flarum on GCP with Terraform, Ansible & GitHub Actions

Automated deployment of Flarum forum on Google Cloud Platform using Ubuntu 22.04 LTS.

## Features

- ✅ **Ubuntu 22.04 LTS** - Fast and lightweight OS
- ✅ **GCP Free Tier** - e2-micro VM (0.25-1GB RAM)
- ✅ **Automated CI/CD** - GitHub Actions workflows
- ✅ **Infrastructure as Code** - Terraform for GCP resources
- ✅ **Configuration Management** - Ansible for application setup
- ✅ **Optimized Performance** - 2GB swap for stability

## Quick Start

### 1. Prerequisites

- GCP account with billing enabled
- GitHub repository with secrets configured
- GCP Service Account with necessary permissions

### 2. Configure GitHub Secrets

Go to your repository → Settings → Secrets and add:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `GCP_PROJECT_ID` | Your GCP project ID | `my-flarum-project` |
| `GCP_SA_KEY` | Service Account JSON key | `{"type": "service_account"...}` |
| `GCP_SSH_PRIVATE_KEY` | SSH private key for VM access | `-----BEGIN RSA PRIVATE KEY-----` |
| `DB_PASSWORD` | Database password | `MySecurePass123!` |

See [SECRETS.md](SECRETS.md) for detailed setup instructions.

### 3. Deploy Infrastructure

```bash
# Manually trigger infrastructure deployment
gh workflow run deploy-infra.yml
```

Or push changes to `terraform/**` to trigger automatically.

### 4. Deploy Application

```bash
# Manually trigger application deployment
gh workflow run deploy-app-only.yml
```

Or push changes to `ansible/**` to trigger automatically.

### 5. Access Your Forum

After successful deployment, access your Flarum forum at:

```
http://<VM_IP_ADDRESS>
```

Complete the web installer:
- **Database Host**: `localhost`
- **Database Name**: `flarum`
- **Database User**: `flarum`
- **Database Password**: Your `DB_PASSWORD` secret

## Architecture

```
GitHub Actions
├── deploy-infra.yml (Infrastructure)
│   └── Terraform → GCP Resources
│       ├── VPC Network
│       ├── Subnet
│       ├── Firewall Rules
│       └── VM (Ubuntu 22.04)
│
└── deploy-app-only.yml (Application)
    └── Ansible → VM Configuration
        ├── System packages (Nginx, PHP, MySQL)
        ├── Swap setup (2GB)
        ├── Flarum installation
        └── Service configuration
```

## Tech Stack

- **OS**: Ubuntu 22.04 LTS (lighter than Rocky Linux)
- **Web Server**: Nginx
- **PHP**: 8.1 (via apt)
- **Database**: MySQL 8.0
- **Forum**: Flarum (latest stable)

## Why Ubuntu?

Previously used Rocky Linux 9, but switched to Ubuntu 22.04 for:
- ✅ **Better performance** on small instances (e2-micro)
- ✅ **Faster SSH responsiveness**
- ✅ **Lighter memory footprint**
- ✅ **More stable** package management (apt vs dnf)
- ✅ **Faster boot times**

## Project Structure

```
.
├── .github/workflows/
│   ├── deploy-infra.yml        # Infrastructure deployment
│   └── deploy-app-only.yml     # Application deployment
├── terraform/
│   └── main.tf                 # GCP resources (Ubuntu VM)
├── ansible/
│   ├── playbook.yml            # Flarum installation (Ubuntu)
│   └── inventory.ini           # Dynamic inventory
├── SECRETS.md                  # Secret setup guide
└── README.md                   # This file
```

## Troubleshooting

### VM is slow or unresponsive
- Ubuntu should be much faster than Rocky Linux
- Check swap usage: `free -h`
- Monitor memory: `top` or `htop`

### SSH connection timeout
- Verify firewall rules allow port 22
- Check VM status: `gcloud compute instances describe flarum-vm`
- Ubuntu SSH should be more stable

### Ansible fails
- Ensure you're using `ansible_user=ubuntu` in inventory
- Verify SSH key is correct
- Check GitHub Actions logs for details

## Cost Optimization

This setup uses GCP Free Tier:
- **VM**: e2-micro (always free in us-central1)
- **Disk**: 20GB standard persistent disk
- **Network**: Egress limits apply

## License

MIT License - Feel free to use and modify.
