# GCP Free Tier Flarum Deployment

Automated deployment of Flarum forum software on Google Cloud Platform using Terraform, Ansible, and GitHub Actions. Optimized for GCP Free Tier with Rocky Linux 9.

## 🚀 Quick Start

1. **Fork this repository**
2. **Set up GCP credentials** (see [Setup](#setup) section)
3. **Configure GitHub Secrets** (see [Secrets](#secrets) section)
4. **Push to main branch** - deployment starts automatically!

## 📋 Prerequisites

- Google Cloud Platform account with billing enabled
- GitHub repository with Actions enabled
- SSH key pair for VM access

## 🛠️ Setup

### 1. GCP Project Setup

```bash
# Create a new GCP project
gcloud projects create your-flarum-project --name="Flarum Forum"

# Set the project
gcloud config set project your-flarum-project

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

### 2. Service Account Setup

```bash
# Create service account
gcloud iam service-accounts create flarum-deployer \
    --description="Service account for Flarum deployment" \
    --display-name="Flarum Deployer"

# Grant necessary permissions
gcloud projects add-iam-policy-binding your-flarum-project \
    --member="serviceAccount:flarum-deployer@your-flarum-project.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding your-flarum-project \
    --member="serviceAccount:flarum-deployer@your-flarum-project.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

# Create and download key
gcloud iam service-accounts keys create flarum-deployer-key.json \
    --iam-account=flarum-deployer@your-flarum-project.iam.gserviceaccount.com
```

### 3. SSH Key Setup

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "flarum-deploy" -f ~/.ssh/flarum-deploy

# Add public key to GCP metadata
gcloud compute project-info add-metadata \
    --metadata-from-file ssh-keys=~/.ssh/flarum-deploy.pub
```

## 🔐 Secrets Configuration

Add these secrets to your GitHub repository (Settings > Secrets and variables > Actions):

| Secret Name           | Description              | Value                                  |
| --------------------- | ------------------------ | -------------------------------------- |
| `GCP_PROJECT_ID`      | Your GCP project ID      | `your-flarum-project`                  |
| `GCP_SA_KEY`          | Service account JSON key | Contents of `flarum-deployer-key.json` |
| `GCP_SSH_PRIVATE_KEY` | Private SSH key          | Contents of `~/.ssh/flarum-deploy`     |
| `DB_PASSWORD`         | Database password        | Strong password for Flarum database    |

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub        │    │   GCP           │    │   Rocky Linux   │
│   Actions       │───▶│   Terraform     │───▶│   VM (e2-micro) │
│   (CI/CD)       │    │   (Infra)       │    │   + Flarum      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Cloud SQL     │
                       │   (db-f1-micro) │
                       │   MySQL 8.0     │
                       └─────────────────┘
```

## 📁 Project Structure

```
├── .github/workflows/          # GitHub Actions workflows
│   ├── deploy.yml              # Main deployment workflow
│   └── destroy.yml             # Infrastructure destruction
├── ansible/                    # Ansible configuration
│   ├── playbook.yml            # Main playbook
│   ├── requirements.yml        # Ansible dependencies
│   └── templates/              # Configuration templates
│       ├── nginx.conf.j2       # Nginx configuration
│       ├── php.ini.j2          # PHP configuration
│       ├── php-fpm.conf.j2     # PHP-FPM configuration
│       └── config.php.j2       # Flarum configuration
├── terraform/                  # Terraform configuration
│   ├── main.tf                 # Main infrastructure
│   ├── variables.tf            # Variable definitions
│   └── outputs.tf              # Output definitions
├── PRD.md                      # Product Requirements Document
├── SECRETS.md                  # Secrets documentation
└── README.md                   # This file
```

## 🚀 Deployment Process

1. **Push to main branch** triggers GitHub Actions
2. **Terraform** provisions GCP infrastructure:
   - e2-micro VM with Rocky Linux 9
   - Cloud SQL MySQL instance (db-f1-micro)
   - VPC network and firewall rules
3. **Ansible** configures the VM:
   - Installs PHP 8.1, Nginx, Composer
   - Sets up 2GB swap for e2-micro stability
   - Downloads and configures Flarum
   - Configures database connection

## 💰 Cost Optimization

This deployment is optimized for GCP Free Tier with minimal resource usage:

- **Compute**: e2-micro (1 vCPU, 1GB RAM) - Free tier eligible
- **Storage**: 20GB standard persistent disk - Free tier eligible (reduced from 30GB)
- **Database**: db-f1-micro (0.5GB RAM) - Free tier eligible
- **Network**: Minimal egress - Free tier eligible
- **Backup**: Disabled to save costs
- **Logs**: Rotated daily with 7-day retention

**Estimated monthly cost**: $0 (within free tier limits)

### 🚀 Performance Optimizations

- **GCP Performance Pool**: Enabled for better CPU performance
- **PHP-FPM**: Limited to 3 processes max (e2-micro optimized)
- **Memory**: PHP limited to 128MB per process
- **Nginx**: Single worker process with optimized settings
- **Logs**: Automatic rotation to prevent disk space issues
- **Swap**: 2GB swap file with optimized settings (swappiness=10)
- **Memory Monitoring**: Automated monitoring with alerts

## 🔧 Configuration

### Terraform Variables

Edit `terraform/variables.tf` to customize:

```hcl
variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"  # Change as needed
}
```

### Ansible Variables

Edit `ansible/playbook.yml` to customize:

```yaml
vars:
  flarum_version: "1.8.2" # Flarum version
  php_version: "8.1" # PHP version
  flarum_home: "/var/www/flarum" # Installation directory
```

## 🛠️ Manual Deployment

If you prefer manual deployment:

```bash
# 1. Deploy infrastructure
cd terraform
terraform init
terraform plan -var="project_id=your-project-id" -var="db_password=your-password"
terraform apply

# 2. Deploy application
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml \
  -e "db_host=$(cd ../terraform && terraform output -raw db_host)" \
  -e "db_name=$(cd ../terraform && terraform output -raw db_name)" \
  -e "db_user=$(cd ../terraform && terraform output -raw db_user)" \
  -e "db_password=your-password"
```

## 🔍 Monitoring

### Check Deployment Status

```bash
# Get VM IP
cd terraform && terraform output vm_ip

# SSH into VM
ssh rocky@$(cd terraform && terraform output -raw vm_ip)

# Check services
sudo systemctl status nginx php81-php-fpm

# Check resource usage
free -h
df -h
ps aux --sort=-%mem | head -10

# Check Flarum logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/php-fpm/www-error.log
```

### 📊 Resource Monitoring

```bash
# Monitor memory usage
watch -n 5 'free -h && echo "---" && ps aux --sort=-%mem | head -5'

# Monitor disk usage
watch -n 30 'df -h && echo "---" && du -sh /var/log/*'

# Check PHP-FPM processes
sudo systemctl status php81-php-fpm
ps aux | grep php-fpm

# Check swap usage and settings
swapon -s
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/vfs_cache_pressure

# Monitor memory logs
sudo tail -f /var/log/flarum/memory.log

# Check memory monitoring service
sudo systemctl status memory-monitor.timer
sudo journalctl -u memory-monitor.service
```

### Access Flarum

After deployment, access your forum at:

- **URL**: `http://YOUR_VM_IP`
- **Admin**: `http://YOUR_VM_IP/admin`

## 🗑️ Cleanup

### Destroy Infrastructure

```bash
# Manual cleanup
cd terraform
terraform destroy

# Or use GitHub Actions
# Go to Actions > Destroy Flarum Infrastructure > Run workflow
# Type "DESTROY" to confirm
```

## 🐛 Troubleshooting

### Common Issues

1. **VM not accessible**: Check firewall rules and SSH key
2. **Database connection failed**: Verify Cloud SQL instance is running
3. **Flarum installation failed**: Check PHP extensions and permissions
4. **Out of memory**: Ensure 2GB swap is configured

### Debug Commands

```bash
# Check VM status
gcloud compute instances list

# Check Cloud SQL status
gcloud sql instances list

# SSH into VM
ssh rocky@VM_IP

# Check logs
sudo journalctl -u nginx
sudo journalctl -u php81-php-fpm
```

## 📚 Documentation

- [Flarum Documentation](https://docs.flarum.org/)
- [GCP Free Tier](https://cloud.google.com/free)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Ansible Documentation](https://docs.ansible.com/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Important Notes

- This deployment is optimized for small communities (up to 100 users)
- Monitor GCP billing to ensure you stay within free tier limits
- Regular backups are recommended for production use
- SSL/HTTPS setup is not included (add separately if needed)

## 🆘 Support

If you encounter issues:

1. Check the [troubleshooting](#troubleshooting) section
2. Review GitHub Actions logs
3. Open an issue with detailed error information
4. Include relevant logs and configuration details

---

**Happy forum building! 🎉**
