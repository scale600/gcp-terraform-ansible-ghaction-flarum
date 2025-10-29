# Minimal Specification Optimization Guide

## 🎯 Optimization Goals

Optimization settings for efficient Flarum forum operation within GCP Free Tier limits.

## 📊 Resource Usage Optimization

### 1. Disk Usage Optimization

- **VM Disk**: 30GB → 20GB (33% savings)
- **Log Rotation**: Auto-delete after 7 days
- **Compression**: gzip compression for log files

### 2. Memory Usage Optimization

- **PHP Memory Limit**: 256MB → 128MB (50% savings)
- **PHP-FPM Processes**: Max 5 → 3 (40% savings)
- **Nginx Workers**: Limited to 1
- **Swap File**: 2GB for stability

### 3. CPU Usage Optimization

- **PHP Execution Time**: 300s → 180s
- **Nginx Configuration**: epoll, multi_accept enabled
- **Gzip Compression**: Optimized to level 6

## 🔧 Key Optimization Settings

### Terraform Optimization

```hcl
# Disk size optimization
size = 20  # Reduced from 30GB to 20GB

# Disable backups
backup_configuration {
  enabled = false
}

# Maintenance window
maintenance_window {
  day = 7
  hour = 3
}
```

### PHP-FPM Optimization

```ini
; Optimized for e2-micro
pm.max_children = 3        # Reduced from 5 to 3
pm.start_servers = 1       # Reduced from 2 to 1
pm.max_spare_servers = 2   # Reduced from 3 to 2
memory_limit = 128M        # Reduced from 256M to 128M
```

### Nginx Optimization

```nginx
# Single worker process
worker_processes 1;
worker_connections 256;

# Compression optimization
gzip_comp_level 6;
gzip_min_length 1024;

# Upload size limit
client_max_body_size 8M;
```

## 📈 Performance Monitoring

### Memory Usage Monitoring

```bash
# Real-time memory usage check
watch -n 5 'free -h && echo "---" && ps aux --sort=-%mem | head -5'
```

### Disk Usage Monitoring

```bash
# Check disk usage
df -h
du -sh /var/log/*
```

### Service Status Check

```bash
# Check PHP-FPM processes
ps aux | grep php-fpm
sudo systemctl status php81-php-fpm

# Check Nginx status
sudo systemctl status nginx
```

## ⚠️ Precautions

### Memory Shortage Response

1. **Check swap usage**: `swapon -s`
2. **Adjust PHP-FPM process count**: Reduce to 2 if needed
3. **Clean logs**: `sudo logrotate -f /etc/logrotate.d/flarum`

### Disk Space Shortage Response

1. **Clean log files**: `sudo find /var/log -name "*.log" -mtime +7 -delete`
2. **Clean temp files**: `sudo find /tmp -type f -mtime +1 -delete`
3. **Clean Flarum cache**: `sudo rm -rf /var/www/flarum/storage/cache/*`

## 🚀 Performance Enhancement Tips

### 1. Static File Caching

- Direct static file serving via Nginx
- Optimized browser caching settings

### 2. Database Optimization

- Regular cleanup of unnecessary data
- Index optimization

### 3. Monitoring Setup

- Regular resource usage checks
- Log file size monitoring

## 📋 Optimization Checklist

- [ ] Keep disk usage below 20GB
- [ ] Keep memory usage below 1GB
- [ ] Keep PHP-FPM processes below 3
- [ ] Don't keep log files for more than 7 days
- [ ] Perform regular resource monitoring

## 🔄 Regular Maintenance

### Weekly Tasks

- [ ] Check disk usage
- [ ] Check memory usage
- [ ] Clean log files

### Monthly Tasks

- [ ] Check GCP costs
- [ ] Performance analysis
- [ ] Security update checks

---

This optimization setup enables stable Flarum forum operation within GCP Free Tier limits.