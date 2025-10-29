# Product Requirements Document

## Overview

Deploy Flarum forum on GCP Free Tier using Infrastructure as Code.

## Requirements

### Functional
- [x] Automated GCP infrastructure deployment
- [x] Flarum forum installation and configuration
- [x] CI/CD pipeline with GitHub Actions
- [x] Database setup with Cloud SQL
- [x] Web server configuration (Nginx + PHP)

### Non-Functional
- [x] GCP Free Tier compliant
- [x] Rocky Linux 9 base OS
- [x] Automated cleanup scripts
- [x] Security best practices
- [x] Resource monitoring

## Architecture

```
GitHub Actions → Terraform → GCP Resources → Ansible → Flarum
```

## Resources

- **VM**: e2-micro (1 vCPU, 1GB RAM)
- **Database**: db-f1-micro Cloud SQL
- **Storage**: 20GB boot disk
- **OS**: Rocky Linux 9

## Exclusions

- Custom domain setup
- SSL certificate management
- Email configuration
- Advanced monitoring
- Load balancing