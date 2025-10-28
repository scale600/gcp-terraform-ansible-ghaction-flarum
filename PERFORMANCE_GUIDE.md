# GCP Free Tier 성능 풀 및 Swap 최적화 가이드

## 🚀 GCP Free Tier 성능 풀 활용

### 성능 풀 설정

```hcl
# Terraform에서 성능 풀 활성화
scheduling {
  preemptible = false           # 안정적인 성능을 위해 비활성화
  automatic_restart = true      # 자동 재시작 활성화
  on_host_maintenance = "MIGRATE"  # 유지보수 시 마이그레이션
}
```

### 성능 풀의 장점

- **CPU 성능 향상**: 더 나은 CPU 성능 제공
- **안정성**: Preemptible 인스턴스보다 안정적
- **자동 복구**: 장애 시 자동 재시작
- **유지보수 최소화**: 호스트 유지보수 시 자동 마이그레이션

## 💾 Swap Memory 최적화

### Swap 설정 개요

- **크기**: 2GB (e2-micro 1GB RAM의 2배)
- **위치**: `/swapfile`
- **타입**: 파일 기반 swap

### 최적화된 Swap 파라미터

| 파라미터                    | 값  | 설명                           |
| --------------------------- | --- | ------------------------------ |
| `vm.swappiness`             | 10  | Swap 사용을 덜 공격적으로 설정 |
| `vm.vfs_cache_pressure`     | 50  | 파일 시스템 캐시 최적화        |
| `vm.dirty_ratio`            | 15  | 더 빠른 쓰기 백                |
| `vm.dirty_background_ratio` | 5   | 백그라운드 쓰기 최적화         |

### Swap 설정 확인

```bash
# 현재 swap 상태 확인
swapon -s

# Swap 사용량 확인
free -h

# Swap 설정 확인
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/vfs_cache_pressure
cat /proc/sys/vm/dirty_ratio
cat /proc/sys/vm/dirty_background_ratio
```

## 📊 메모리 모니터링 시스템

### 자동 모니터링

- **주기**: 5분마다 실행
- **로그**: `/var/log/flarum/memory.log`
- **알림**: 메모리 사용률 90% 이상 시 경고
- **Swap 알림**: Swap 사용률 80% 이상 시 경고

### 모니터링 명령어

```bash
# 메모리 모니터링 서비스 상태
sudo systemctl status memory-monitor.timer

# 메모리 로그 실시간 확인
sudo tail -f /var/log/flarum/memory.log

# 메모리 사용량 실시간 모니터링
watch -n 5 'free -h && echo "---" && ps aux --sort=-%mem | head -5'
```

## 🔧 성능 튜닝 가이드

### 1. 메모리 사용량 최적화

```bash
# PHP-FPM 프로세스 수 조정 (필요시)
sudo systemctl edit php81-php-fpm
# pm.max_children = 2  # 3에서 2로 감소

# PHP 메모리 제한 확인
php -i | grep memory_limit
```

### 2. Swap 사용량 최적화

```bash
# Swap 사용량이 높은 경우
sudo swapoff -a && sudo swapon -a  # Swap 재시작

# Swap 사용량 모니터링
watch -n 1 'free -h && swapon -s'
```

### 3. 시스템 캐시 최적화

```bash
# 캐시 정리 (필요시)
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# 캐시 상태 확인
cat /proc/meminfo | grep -E "(Cached|Buffers|Dirty)"
```

## ⚠️ 문제 해결

### 메모리 부족 시

1. **PHP-FPM 프로세스 수 감소**

   ```bash
   sudo systemctl edit php81-php-fpm
   # pm.max_children = 2
   sudo systemctl restart php81-php-fpm
   ```

2. **PHP 메모리 제한 감소**

   ```bash
   sudo nano /etc/opt/remi/php81/php.ini
   # memory_limit = 96M
   sudo systemctl restart php81-php-fpm
   ```

3. **불필요한 서비스 중지**
   ```bash
   sudo systemctl stop postfix  # 이메일 서비스 (필요시)
   sudo systemctl disable postfix
   ```

### Swap 사용량이 높은 경우

1. **Swap 설정 조정**

   ```bash
   echo 5 | sudo tee /proc/sys/vm/swappiness  # 더 보수적으로 설정
   ```

2. **메모리 사용량 확인**
   ```bash
   ps aux --sort=-%mem | head -10  # 메모리 사용량 높은 프로세스 확인
   ```

## 📈 성능 벤치마크

### 예상 성능 지표

- **메모리 사용률**: 70-80% (정상)
- **Swap 사용률**: 0-20% (정상)
- **CPU 사용률**: 10-30% (일반적)
- **디스크 I/O**: 최소화

### 성능 모니터링 스크립트

```bash
#!/bin/bash
# 성능 모니터링 스크립트

echo "=== 시스템 리소스 상태 ==="
echo "메모리:"
free -h

echo -e "\nSwap:"
swapon -s

echo -e "\n디스크:"
df -h

echo -e "\nCPU 사용률 상위 5개 프로세스:"
ps aux --sort=-%cpu | head -6

echo -e "\n메모리 사용률 상위 5개 프로세스:"
ps aux --sort=-%mem | head -6
```

## 🎯 최적화 체크리스트

### 배포 전 확인사항

- [ ] GCP 성능 풀 활성화 확인
- [ ] Swap 파일 2GB 생성 확인
- [ ] Swap 파라미터 최적화 확인
- [ ] 메모리 모니터링 서비스 활성화 확인

### 운영 중 모니터링

- [ ] 메모리 사용률 90% 이하 유지
- [ ] Swap 사용률 80% 이하 유지
- [ ] 로그 파일 크기 모니터링
- [ ] 성능 지표 정기 확인

### 문제 발생 시 대응

- [ ] 메모리 부족 시 PHP-FPM 프로세스 수 감소
- [ ] Swap 사용량 높을 시 메모리 사용량 확인
- [ ] 디스크 공간 부족 시 로그 정리
- [ ] 성능 저하 시 캐시 정리

---

이 가이드를 따라하면 GCP Free Tier에서 최적의 성능으로 Flarum을 운영할 수 있습니다.
