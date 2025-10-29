# Optimization Guide

Minimize resource usage for GCP Free Tier.

## 📊 Resource Limits

- **VM Disk**: 20GB (was 30GB)
- **PHP Memory**: 128MB (was 256MB)
- **PHP-FPM Processes**: 3 (was 5)
- **Log Retention**: 7 days

## 🔧 Key Settings

### PHP-FPM
```ini
pm.max_children = 3
pm.start_servers = 1
memory_limit = 128M
```

### Nginx
```nginx
worker_processes 1;
worker_connections 256;
client_max_body_size 8M;
```

## 📈 Monitoring

```bash
# Memory usage
watch -n 5 'free -h && ps aux --sort=-%mem | head -5'

# Disk usage
df -h
du -sh /var/log/*
```

## ⚠️ Troubleshooting

### Memory Low
```bash
# Check swap
swapon -s

# Reduce PHP processes
sudo systemctl edit php81-php-fpm
# pm.max_children = 2
```

### Disk Full
```bash
# Clean logs
sudo find /var/log -name "*.log" -mtime +7 -delete

# Clean cache
sudo rm -rf /var/www/flarum/storage/cache/*
```

## 📋 Checklist

- [ ] Disk usage < 20GB
- [ ] Memory usage < 1GB
- [ ] PHP-FPM processes < 3
- [ ] Logs cleaned weekly
- [ ] Regular monitoring active