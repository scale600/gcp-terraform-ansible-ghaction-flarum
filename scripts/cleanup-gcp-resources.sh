#!/bin/bash

# GCP Flarum Project Resource Cleanup Script
# This script safely removes existing GCP resources.

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project settings
PROJECT_ID="riderwin-flarum"
ZONE="us-central1-a"
REGION="us-central1"

echo -e "${BLUE}🧹 Starting GCP Flarum Project Resource Cleanup${NC}"
echo -e "${YELLOW}Project: ${PROJECT_ID}${NC}"
echo -e "${YELLOW}Zone: ${ZONE}${NC}"
echo -e "${YELLOW}Region: ${REGION}${NC}"
echo ""

# Verify GCP project configuration
echo -e "${BLUE}📋 Verifying GCP project configuration...${NC}"
if ! gcloud config get-value project | grep -q "$PROJECT_ID"; then
    echo -e "${YELLOW}⚠️  Setting GCP project to ${PROJECT_ID}...${NC}"
    gcloud config set project "$PROJECT_ID"
fi

echo -e "${GREEN}✅ Project configuration complete${NC}"
echo ""

# 1. Delete VM instance
echo -e "${BLUE}🖥️  Deleting VM instance...${NC}"
if gcloud compute instances describe flarum-vm --zone="$ZONE" --quiet 2>/dev/null; then
    echo -e "${YELLOW}Found VM instance 'flarum-vm', deleting...${NC}"
    gcloud compute instances delete flarum-vm --zone="$ZONE" --quiet
    echo -e "${GREEN}✅ VM instance deletion complete${NC}"
else
    echo -e "${YELLOW}⚠️  VM instance 'flarum-vm' does not exist${NC}"
fi
echo ""

# 2. Delete firewall rules
echo -e "${BLUE}🔥 Deleting firewall rules...${NC}"

# SSH firewall rule
if gcloud compute firewall-rules describe flarum-ssh --quiet 2>/dev/null; then
    echo -e "${YELLOW}Deleting SSH firewall rule 'flarum-ssh'...${NC}"
    gcloud compute firewall-rules delete flarum-ssh --quiet
    echo -e "${GREEN}✅ SSH firewall rule deletion complete${NC}"
else
    echo -e "${YELLOW}⚠️  SSH firewall rule 'flarum-ssh' does not exist${NC}"
fi

# HTTP firewall rule
if gcloud compute firewall-rules describe flarum-http --quiet 2>/dev/null; then
    echo -e "${YELLOW}Deleting HTTP firewall rule 'flarum-http'...${NC}"
    gcloud compute firewall-rules delete flarum-http --quiet
    echo -e "${GREEN}✅ HTTP firewall rule deletion complete${NC}"
else
    echo -e "${YELLOW}⚠️  HTTP firewall rule 'flarum-http' does not exist${NC}"
fi
echo ""

# 3. Delete subnet
echo -e "${BLUE}🌐 Deleting subnet...${NC}"
if gcloud compute networks subnets describe flarum-subnet --region="$REGION" --quiet 2>/dev/null; then
    echo -e "${YELLOW}Deleting subnet 'flarum-subnet'...${NC}"
    gcloud compute networks subnets delete flarum-subnet --region="$REGION" --quiet
    echo -e "${GREEN}✅ Subnet deletion complete${NC}"
else
    echo -e "${YELLOW}⚠️  Subnet 'flarum-subnet' does not exist${NC}"
fi
echo ""

# 4. Delete VPC network
echo -e "${BLUE}🌍 Deleting VPC network...${NC}"
if gcloud compute networks describe flarum-network --quiet 2>/dev/null; then
    echo -e "${YELLOW}Deleting VPC network 'flarum-network'...${NC}"
    gcloud compute networks delete flarum-network --quiet
    echo -e "${GREEN}✅ VPC network deletion complete${NC}"
else
    echo -e "${YELLOW}⚠️  VPC network 'flarum-network' does not exist${NC}"
fi
echo ""

# 5. Check Cloud SQL resources (optional)
echo -e "${BLUE}🗄️  Checking Cloud SQL resources...${NC}"
if gcloud sql instances describe flarum-db --quiet 2>/dev/null; then
    echo -e "${YELLOW}Found Cloud SQL instance 'flarum-db'${NC}"
    echo -e "${RED}⚠️  Cloud SQL instance must be deleted manually:${NC}"
    echo -e "${YELLOW}   gcloud sql instances delete flarum-db --quiet${NC}"
    echo -e "${YELLOW}   Or delete via GCP Console${NC}"
else
    echo -e "${YELLOW}⚠️  Cloud SQL instance 'flarum-db' does not exist${NC}"
fi
echo ""

# 6. Cleanup complete
echo -e "${GREEN}🎉 GCP resource cleanup complete!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "${YELLOW}1. Delete Cloud SQL instance manually if it exists${NC}"
echo -e "${YELLOW}2. Start new deployment via GitHub Actions${NC}"
echo -e "${YELLOW}3. Or start deployment with the following commands:${NC}"
echo -e "${BLUE}   git commit --allow-empty -m \"Clean deployment after resource cleanup\"${NC}"
echo -e "${BLUE}   git push origin main${NC}"
echo ""

# 7. Check remaining resources
echo -e "${BLUE}🔍 Checking remaining resources...${NC}"
echo -e "${YELLOW}VM instances:${NC}"
gcloud compute instances list --filter="name~flarum" --format="table(name,zone,status)" 2>/dev/null || echo "No VM instances"

echo -e "${YELLOW}Firewall rules:${NC}"
gcloud compute firewall-rules list --filter="name~flarum" --format="table(name,direction,priority)" 2>/dev/null || echo "No firewall rules"

echo -e "${YELLOW}VPC networks:${NC}"
gcloud compute networks list --filter="name~flarum" --format="table(name,subnet_mode)" 2>/dev/null || echo "No VPC networks"

echo -e "${YELLOW}Cloud SQL instances:${NC}"
gcloud sql instances list --filter="name~flarum" --format="table(name,region,databaseVersion,state)" 2>/dev/null || echo "No Cloud SQL instances"

echo ""
echo -e "${GREEN}✨ Script execution complete!${NC}"