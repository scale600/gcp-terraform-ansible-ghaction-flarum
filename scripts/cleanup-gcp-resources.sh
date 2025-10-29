#!/bin/bash

# GCP Flarum 프로젝트 리소스 정리 스크립트
# 이 스크립트는 기존에 생성된 GCP 리소스들을 안전하게 삭제합니다.

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 프로젝트 설정
PROJECT_ID="riderwin-flarum"
ZONE="us-central1-a"
REGION="us-central1"

echo -e "${BLUE}🧹 GCP Flarum 프로젝트 리소스 정리 시작${NC}"
echo -e "${YELLOW}프로젝트: ${PROJECT_ID}${NC}"
echo -e "${YELLOW}존: ${ZONE}${NC}"
echo -e "${YELLOW}리전: ${REGION}${NC}"
echo ""

# GCP 프로젝트 설정 확인
echo -e "${BLUE}📋 GCP 프로젝트 설정 확인 중...${NC}"
if ! gcloud config get-value project | grep -q "$PROJECT_ID"; then
    echo -e "${YELLOW}⚠️  GCP 프로젝트를 ${PROJECT_ID}로 설정합니다...${NC}"
    gcloud config set project "$PROJECT_ID"
fi

echo -e "${GREEN}✅ 프로젝트 설정 완료${NC}"
echo ""

# 1. VM 인스턴스 삭제
echo -e "${BLUE}🖥️  VM 인스턴스 삭제 중...${NC}"
if gcloud compute instances describe flarum-vm --zone="$ZONE" --quiet 2>/dev/null; then
    echo -e "${YELLOW}VM 인스턴스 'flarum-vm' 발견, 삭제 중...${NC}"
    gcloud compute instances delete flarum-vm --zone="$ZONE" --quiet
    echo -e "${GREEN}✅ VM 인스턴스 삭제 완료${NC}"
else
    echo -e "${YELLOW}⚠️  VM 인스턴스 'flarum-vm'이 존재하지 않습니다${NC}"
fi
echo ""

# 2. 방화벽 규칙 삭제
echo -e "${BLUE}🔥 방화벽 규칙 삭제 중...${NC}"

# SSH 방화벽 규칙
if gcloud compute firewall-rules describe flarum-ssh --quiet 2>/dev/null; then
    echo -e "${YELLOW}SSH 방화벽 규칙 'flarum-ssh' 삭제 중...${NC}"
    gcloud compute firewall-rules delete flarum-ssh --quiet
    echo -e "${GREEN}✅ SSH 방화벽 규칙 삭제 완료${NC}"
else
    echo -e "${YELLOW}⚠️  SSH 방화벽 규칙 'flarum-ssh'이 존재하지 않습니다${NC}"
fi

# HTTP 방화벽 규칙
if gcloud compute firewall-rules describe flarum-http --quiet 2>/dev/null; then
    echo -e "${YELLOW}HTTP 방화벽 규칙 'flarum-http' 삭제 중...${NC}"
    gcloud compute firewall-rules delete flarum-http --quiet
    echo -e "${GREEN}✅ HTTP 방화벽 규칙 삭제 완료${NC}"
else
    echo -e "${YELLOW}⚠️  HTTP 방화벽 규칙 'flarum-http'이 존재하지 않습니다${NC}"
fi
echo ""

# 3. 서브넷 삭제
echo -e "${BLUE}🌐 서브넷 삭제 중...${NC}"
if gcloud compute networks subnets describe flarum-subnet --region="$REGION" --quiet 2>/dev/null; then
    echo -e "${YELLOW}서브넷 'flarum-subnet' 삭제 중...${NC}"
    gcloud compute networks subnets delete flarum-subnet --region="$REGION" --quiet
    echo -e "${GREEN}✅ 서브넷 삭제 완료${NC}"
else
    echo -e "${YELLOW}⚠️  서브넷 'flarum-subnet'이 존재하지 않습니다${NC}"
fi
echo ""

# 4. VPC 네트워크 삭제
echo -e "${BLUE}🌍 VPC 네트워크 삭제 중...${NC}"
if gcloud compute networks describe flarum-network --quiet 2>/dev/null; then
    echo -e "${YELLOW}VPC 네트워크 'flarum-network' 삭제 중...${NC}"
    gcloud compute networks delete flarum-network --quiet
    echo -e "${GREEN}✅ VPC 네트워크 삭제 완료${NC}"
else
    echo -e "${YELLOW}⚠️  VPC 네트워크 'flarum-network'이 존재하지 않습니다${NC}"
fi
echo ""

# 5. Cloud SQL 리소스 삭제 (선택사항)
echo -e "${BLUE}🗄️  Cloud SQL 리소스 확인 중...${NC}"
if gcloud sql instances describe flarum-db --quiet 2>/dev/null; then
    echo -e "${YELLOW}Cloud SQL 인스턴스 'flarum-db'가 발견되었습니다${NC}"
    echo -e "${RED}⚠️  Cloud SQL 인스턴스는 수동으로 삭제해야 합니다:${NC}"
    echo -e "${YELLOW}   gcloud sql instances delete flarum-db --quiet${NC}"
    echo -e "${YELLOW}   또는 GCP Console에서 삭제하세요${NC}"
else
    echo -e "${YELLOW}⚠️  Cloud SQL 인스턴스 'flarum-db'가 존재하지 않습니다${NC}"
fi
echo ""

# 6. 정리 완료
echo -e "${GREEN}🎉 GCP 리소스 정리 완료!${NC}"
echo ""
echo -e "${BLUE}📋 다음 단계:${NC}"
echo -e "${YELLOW}1. Cloud SQL 인스턴스가 있다면 수동으로 삭제하세요${NC}"
echo -e "${YELLOW}2. GitHub Actions를 통해 새로운 배포를 시작하세요${NC}"
echo -e "${YELLOW}3. 또는 다음 명령어로 배포를 시작하세요:${NC}"
echo -e "${BLUE}   git commit --allow-empty -m \"Clean deployment after resource cleanup\"${NC}"
echo -e "${BLUE}   git push origin main${NC}"
echo ""

# 7. 남은 리소스 확인
echo -e "${BLUE}🔍 남은 리소스 확인 중...${NC}"
echo -e "${YELLOW}VM 인스턴스:${NC}"
gcloud compute instances list --filter="name~flarum" --format="table(name,zone,status)" 2>/dev/null || echo "VM 인스턴스 없음"

echo -e "${YELLOW}방화벽 규칙:${NC}"
gcloud compute firewall-rules list --filter="name~flarum" --format="table(name,direction,priority)" 2>/dev/null || echo "방화벽 규칙 없음"

echo -e "${YELLOW}VPC 네트워크:${NC}"
gcloud compute networks list --filter="name~flarum" --format="table(name,subnet_mode)" 2>/dev/null || echo "VPC 네트워크 없음"

echo -e "${YELLOW}Cloud SQL 인스턴스:${NC}"
gcloud sql instances list --filter="name~flarum" --format="table(name,region,databaseVersion,state)" 2>/dev/null || echo "Cloud SQL 인스턴스 없음"

echo ""
echo -e "${GREEN}✨ 스크립트 실행 완료!${NC}"
