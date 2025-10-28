# 최소 사양 최적화 가이드

## 🎯 최적화 목표

GCP Free Tier 한도 내에서 최대한 효율적인 Flarum 포럼 운영을 위한 최적화 설정입니다.

## 📊 리소스 사용량 최적화

### 1. 디스크 사용량 최적화

- **VM 디스크**: 30GB → 20GB (33% 절약)
- **로그 로테이션**: 7일 보관 후 자동 삭제
- **압축**: 로그 파일 gzip 압축

### 2. 메모리 사용량 최적화

- **PHP 메모리 제한**: 256MB → 128MB (50% 절약)
- **PHP-FPM 프로세스**: 최대 5개 → 3개 (40% 절약)
- **Nginx 워커**: 1개로 제한
- **스왑 파일**: 2GB 설정으로 안정성 확보

### 3. CPU 사용량 최적화

- **PHP 실행 시간**: 300초 → 180초
- **Nginx 설정**: epoll, multi_accept 활성화
- **Gzip 압축**: 레벨 6으로 최적화

## 🔧 주요 최적화 설정

### Terraform 최적화

```hcl
# 디스크 크기 최적화
size = 20  # 30GB에서 20GB로 감소

# 백업 비활성화
backup_configuration {
  enabled = false
}

# 유지보수 창 설정
maintenance_window {
  day = 7
  hour = 3
}
```

### PHP-FPM 최적화

```ini
; e2-micro에 최적화된 설정
pm.max_children = 3        # 5에서 3으로 감소
pm.start_servers = 1       # 2에서 1로 감소
pm.max_spare_servers = 2   # 3에서 2로 감소
memory_limit = 128M        # 256M에서 128M로 감소
```

### Nginx 최적화

```nginx
# 단일 워커 프로세스
worker_processes 1;
worker_connections 256;

# 압축 최적화
gzip_comp_level 6;
gzip_min_length 1024;

# 업로드 크기 제한
client_max_body_size 8M;
```

## 📈 성능 모니터링

### 메모리 사용량 모니터링

```bash
# 실시간 메모리 사용량 확인
watch -n 5 'free -h && echo "---" && ps aux --sort=-%mem | head -5'
```

### 디스크 사용량 모니터링

```bash
# 디스크 사용량 확인
df -h
du -sh /var/log/*
```

### 서비스 상태 확인

```bash
# PHP-FPM 프로세스 확인
ps aux | grep php-fpm
sudo systemctl status php81-php-fpm

# Nginx 상태 확인
sudo systemctl status nginx
```

## ⚠️ 주의사항

### 메모리 부족 시 대응

1. **스왑 사용량 확인**: `swapon -s`
2. **PHP-FPM 프로세스 수 조정**: 필요시 2개로 더 감소
3. **로그 정리**: `sudo logrotate -f /etc/logrotate.d/flarum`

### 디스크 공간 부족 시 대응

1. **로그 파일 정리**: `sudo find /var/log -name "*.log" -mtime +7 -delete`
2. **임시 파일 정리**: `sudo find /tmp -type f -mtime +1 -delete`
3. **Flarum 캐시 정리**: `sudo rm -rf /var/www/flarum/storage/cache/*`

## 🚀 성능 향상 팁

### 1. 정적 파일 캐싱

- Nginx에서 정적 파일 직접 서빙
- 브라우저 캐싱 설정 최적화

### 2. 데이터베이스 최적화

- 불필요한 데이터 정기 정리
- 인덱스 최적화

### 3. 모니터링 설정

- 리소스 사용량 정기 확인
- 로그 파일 크기 모니터링

## 📋 최적화 체크리스트

- [ ] 디스크 사용량 20GB 이하 유지
- [ ] 메모리 사용량 1GB 이하 유지
- [ ] PHP-FPM 프로세스 3개 이하 유지
- [ ] 로그 파일 7일 이상 보관하지 않음
- [ ] 정기적인 리소스 모니터링 수행

## 🔄 정기 유지보수

### 주간 작업

- [ ] 디스크 사용량 확인
- [ ] 메모리 사용량 확인
- [ ] 로그 파일 정리

### 월간 작업

- [ ] GCP 비용 확인
- [ ] 성능 분석
- [ ] 보안 업데이트 확인

---

이 최적화 설정으로 GCP Free Tier 한도 내에서 안정적인 Flarum 포럼 운영이 가능합니다.
