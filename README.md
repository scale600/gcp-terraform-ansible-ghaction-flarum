# Flarum on GCP — Terraform + Ansible + GitHub Actions

Automated, one-command deployment of a Flarum forum on Google Cloud Platform Free Tier.

## Overview

Deploy a fully functional Flarum forum on GCP using Infrastructure as Code (Terraform), configuration management (Ansible), and CI/CD (GitHub Actions). Designed for the GCP Free Tier — zero ongoing compute cost.

- **Infrastructure** — Terraform provisions networking, firewall, and compute
- **Configuration** — Ansible installs and configures the full LEMP stack + Flarum
- **CI/CD** — GitHub Actions orchestrates infra then app deployment
- **Cost** — e2-micro instance in us-central1, always free

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Cloud** | Google Cloud Platform (Free Tier) |
| **Infrastructure as Code** | Terraform |
| **Configuration Management** | Ansible |
| **CI/CD** | GitHub Actions |
| **OS** | Ubuntu 22.04 LTS |
| **Compute** | e2-micro (0.25–1 vCPU, 1 GB RAM) |
| **Web Server** | Nginx |
| **Runtime** | PHP 8.1 |
| **Database** | MySQL 8.0 |
| **Application** | Flarum (latest stable) |

## Architecture

```
GitHub Actions
├── deploy-infra.yml (Infrastructure)
│   └── Terraform → GCP (VPC, Subnet, Firewall, VM)
│
└── deploy-app-only.yml (Application)
    └── Ansible → VM (Nginx, PHP, MySQL, Flarum)
```

## Quick Start

### 1. Configure Secrets

Add these to your repository → Settings → Secrets and variables → Actions:

| Secret | Description |
|--------|-------------|
| `GCP_PROJECT_ID` | GCP Project ID |
| `GCP_SA_KEY` | Service Account JSON key |
| `GCP_SSH_PRIVATE_KEY` | SSH private key for VM access |
| `DB_PASSWORD` | Database password |

See **[SECRETS.md](SECRETS.md)** for detailed setup.

### 2. Deploy

```bash
# Infrastructure
gh workflow run deploy-infra.yml

# Application (after infra completes)
gh workflow run deploy-app-only.yml
```

### 3. Access

```
http://<VM_EXTERNAL_IP>
```

Complete the Flarum web installer:
- **Database Host**: `localhost`
- **Database Name**: `flarum`
- **User**: `flarum`
- **Password**: Your `DB_PASSWORD` secret

## Project Structure

```
├── .github/workflows/
│   ├── deploy-infra.yml       # Infrastructure deployment
│   └── deploy-app-only.yml    # Application deployment
├── terraform/
│   ├── main.tf                # GCP resource definitions
│   └── backend.tf             # State backend config
├── ansible/
│   ├── playbook.yml           # Flarum & LEMP setup
│   └── inventory.ini          # Dynamic inventory
├── scripts/                   # Utility scripts
└── README.md
```

## Why Ubuntu 22.04

Switched from Rocky Linux 9 — Ubuntu delivers better performance on the constrained e2-micro instance:

| Metric | Ubuntu 22.04 | Rocky Linux 9 |
|--------|-------------|---------------|
| Memory Footprint | ~150 MB idle | ~400 MB idle |
| SSH Responsiveness | Instant | 5–10s delay |
| Package Manager | apt (fast) | dnf (slower) |
| Boot Time | ~15s | ~25s |

## License

MIT
