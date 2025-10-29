#!/bin/bash

# Force Delete GCP Flarum Project Resources
# This script forcefully removes all Flarum-related resources

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

echo -e "${BLUE}🧹 Force Deleting GCP Flarum Project Resources${NC}"
echo -e "${YELLOW}Project: ${PROJECT_ID}${NC}"
echo ""

# Set project
echo -e "${BLUE}📋 Setting GCP project...${NC}"
gcloud config set project "$PROJECT_ID" --quiet

# 1. Delete Cloud SQL instances
echo -e "${BLUE}🗄️  Deleting Cloud SQL instances...${NC}"
for instance in $(gcloud sql instances list --format="value(name)" --filter="name~flarum" 2>/dev/null || true); do
    if [ ! -z "$instance" ]; then
        echo -e "${YELLOW}Deleting Cloud SQL instance: $instance${NC}"
        gcloud sql instances delete "$instance" --quiet --async 2>/dev/null || true
    fi
done

# 2. Delete VM instances
echo -e "${BLUE}🖥️  Deleting VM instances...${NC}"
for instance in $(gcloud compute instances list --format="value(name)" --filter="name~flarum" 2>/dev/null || true); do
    if [ ! -z "$instance" ]; then
        echo -e "${YELLOW}Deleting VM instance: $instance${NC}"
        gcloud compute instances delete "$instance" --zone="$ZONE" --quiet 2>/dev/null || true
    fi
done

# 3. Delete firewall rules
echo -e "${BLUE}🔥 Deleting firewall rules...${NC}"
for rule in $(gcloud compute firewall-rules list --format="value(name)" --filter="name~flarum" 2>/dev/null || true); do
    if [ ! -z "$rule" ]; then
        echo -e "${YELLOW}Deleting firewall rule: $rule${NC}"
        gcloud compute firewall-rules delete "$rule" --quiet 2>/dev/null || true
    fi
done

# 4. Delete subnets
echo -e "${BLUE}🌐 Deleting subnets...${NC}"
for subnet in $(gcloud compute networks subnets list --format="value(name)" --filter="name~flarum" 2>/dev/null || true); do
    if [ ! -z "$subnet" ]; then
        echo -e "${YELLOW}Deleting subnet: $subnet${NC}"
        gcloud compute networks subnets delete "$subnet" --region="$REGION" --quiet 2>/dev/null || true
    fi
done

# 5. Delete VPC networks
echo -e "${BLUE}🌍 Deleting VPC networks...${NC}"
for network in $(gcloud compute networks list --format="value(name)" --filter="name~flarum" 2>/dev/null || true); do
    if [ ! -z "$network" ]; then
        echo -e "${YELLOW}Deleting VPC network: $network${NC}"
        gcloud compute networks delete "$network" --quiet 2>/dev/null || true
    fi
done

# 6. Delete any remaining resources with flarum in name
echo -e "${BLUE}🔍 Deleting any remaining flarum resources...${NC}"

# Delete any compute resources
for resource in $(gcloud compute instances list --format="value(name)" --filter="name~flarum" 2>/dev/null || true); do
    if [ ! -z "$resource" ]; then
        echo -e "${YELLOW}Found remaining instance: $resource${NC}"
        gcloud compute instances delete "$resource" --zone="$ZONE" --quiet 2>/dev/null || true
    fi
done

# Delete any disks
for disk in $(gcloud compute disks list --format="value(name)" --filter="name~flarum" 2>/dev/null || true); do
    if [ ! -z "$disk" ]; then
        echo -e "${YELLOW}Deleting disk: $disk${NC}"
        gcloud compute disks delete "$disk" --zone="$ZONE" --quiet 2>/dev/null || true
    fi
done

# 7. Wait for async operations
echo -e "${BLUE}⏳ Waiting for async operations to complete...${NC}"
sleep 30

# 8. Final verification
echo -e "${BLUE}🔍 Final verification...${NC}"
echo -e "${YELLOW}Remaining resources:${NC}"

echo -e "${YELLOW}VM instances:${NC}"
gcloud compute instances list --filter="name~flarum" --format="table(name,zone,status)" 2>/dev/null || echo "No VM instances"

echo -e "${YELLOW}Firewall rules:${NC}"
gcloud compute firewall-rules list --filter="name~flarum" --format="table(name,direction,priority)" 2>/dev/null || echo "No firewall rules"

echo -e "${YELLOW}VPC networks:${NC}"
gcloud compute networks list --filter="name~flarum" --format="table(name,subnet_mode)" 2>/dev/null || echo "No VPC networks"

echo -e "${YELLOW}Cloud SQL instances:${NC}"
gcloud sql instances list --filter="name~flarum" --format="table(name,region,databaseVersion,state)" 2>/dev/null || echo "No Cloud SQL instances"

echo -e "${YELLOW}Disks:${NC}"
gcloud compute disks list --filter="name~flarum" --format="table(name,zone,sizeGb,status)" 2>/dev/null || echo "No disks"

echo ""
echo -e "${GREEN}🎉 Force deletion complete!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "${YELLOW}1. Wait 2-3 minutes for all resources to be fully deleted${NC}"
echo -e "${YELLOW}2. Start new deployment:${NC}"
echo -e "${BLUE}   git commit --allow-empty -m \"Deploy after force cleanup\"${NC}"
echo -e "${BLUE}   git push origin main${NC}"
echo ""
