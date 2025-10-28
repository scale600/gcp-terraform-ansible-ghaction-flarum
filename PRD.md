# Product Requirements Document (PRD): GCP Free Tier Flarum Deployment

## Overview

This PRD outlines the requirements for deploying Flarum (open-source forum software) on GCP Free Tier using Rocky Linux 9, with automation via Terraform, Ansible, and GitHub Actions CI/CD. Focus: Cost-free, automated setup for small-scale communities (up to 100 users, 100k monthly views).

## Key Requirements

- **OS**: Rocky Linux 9
- **Infrastructure**: GCP Free Tier (e2-micro VM, 30GB disk, Cloud SQL db-f1-micro MySQL)
- **Automation**: Terraform (infra provisioning) → Ansible (app installation) → GitHub Actions (CI/CD pipeline)
- **Memory Management**: 1GB RAM + 2GB Swap file to prevent OOM kills
- **Application Stack**: Flarum on PHP 8.1, Nginx web server, MySQL (via Cloud SQL)
- **Deployment Trigger**: `git push` to main branch auto-creates infra and installs Flarum
- **Exclusions**: No security (SELinux permissive for simplicity), no domain/SSL setup

## Non-Functional Requirements

- **Performance**: Page load <2s under low traffic; swap ensures stability
- **Cost**: Strictly within Free Tier limits (monitor via GCP Billing alerts)
- **Scalability**: Manual upgrade path (e.g., e2-small VM) for growth
- **Maintainability**: Version-controlled repo; easy rollback via Terraform destroy

## Risks & Mitigations

- **Free Tier Overage**: Traffic limits; auto-shutdown script on exceedance
- **Dependency Failures**: Ansible idempotency; retry logic in CI/CD

## Timeline & Milestones

- Week 1: Repo setup & local testing
- Week 2: Full automated deployment
- Ongoing: Monthly cost audits

Version: 1.0 | Date: October 28, 2025
