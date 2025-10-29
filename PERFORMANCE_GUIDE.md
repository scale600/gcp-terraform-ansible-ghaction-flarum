# GCP Free Tier Performance Pool and Swap Optimization Guide

## 🚀 GCP Free Tier Performance Pool Utilization

### Performance Pool Configuration

```hcl
# Enable performance pool in Terraform
scheduling {
  preemptible = false           # Disabled for stable performance
  automatic_restart = true      # Enable automatic restart
  on_host_maintenance = "MIGRATE"  # Migrate during host maintenance
}
```

### Performance Pool Benefits

- **Enhanced CPU Performance**: Provides better CPU performance
- **Stability**: More stable than preemptible instances
- **Auto Recovery**: Automatic restart on failure
- **Minimal Maintenance**: Automatic migration during host maintenance

## 💾 Swap Memory Optimization

### Swap Configuration Overview

- **Size**: 2GB (2x the e2-micro 1GB RAM)
- **Location**: `/swapfile`
- **Type**: File-based swap

### Optimized Swap Parameters

| Parameter                    | Value | Description                           |
| --------------------------- | ----- | ------------------------------------- |
| `vm.swappiness`             | 10    | Less aggressive swap usage            |
| `vm.vfs_cache_pressure`     | 50    | File system cache optimization        |
| `vm.dirty_ratio`            | 15    | Faster writeback                      |
| `vm.dirty_background_ratio` | 5     | Background write optimization         |

### Swap Configuration Verification

```bash
# Check current swap status
swapon -s

# Check swap usage
free -h

# Check swap settings
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/vfs_cache_pressure
cat /proc/sys/vm/dirty_ratio
cat /proc/sys/vm/dirty_background_ratio
```

## 📊 Memory Monitoring System

### Automatic Monitoring

- **Interval**: Every 5 minutes
- **Log**: `/var/log/flarum/memory.log`
- **Alert**: Warning when memory usage exceeds 90%
- **Swap Alert**: Warning when swap usage exceeds 80%

### Monitoring Commands

```bash
# Check memory monitoring service status
sudo systemctl status memory-monitor.timer

# Real-time memory log monitoring
sudo tail -f /var/log/flarum/memory.log

# Real-time memory usage monitoring
watch -n 5 'free -h && echo "---" && ps aux --sort=-%mem | head -5'
```

## 🔧 Performance Tuning Guide

### 1. Memory Usage Optimization

```bash
# Adjust PHP-FPM process count (if needed)
sudo systemctl edit php81-php-fpm
# pm.max_children = 2  # Reduce from 3 to 2

# Check PHP memory limit
php -i | grep memory_limit
```

### 2. Swap Usage Optimization

```bash
# If swap usage is high
sudo swapoff -a && sudo swapon -a  # Restart swap

# Monitor swap usage
watch -n 1 'free -h && swapon -s'
```

### 3. System Cache Optimization

```bash
# Clear cache (if needed)
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# Check cache status
cat /proc/meminfo | grep -E "(Cached|Buffers|Dirty)"
```

## ⚠️ Troubleshooting

### When Memory is Low

1. **Reduce PHP-FPM Process Count**

   ```bash
   sudo systemctl edit php81-php-fpm
   # pm.max_children = 2
   sudo systemctl restart php81-php-fpm
   ```

2. **Reduce PHP Memory Limit**

   ```bash
   sudo nano /etc/opt/remi/php81/php.ini
   # memory_limit = 96M
   sudo systemctl restart php81-php-fpm
   ```

3. **Stop Unnecessary Services**
   ```bash
   sudo systemctl stop postfix  # Email service (if needed)
   sudo systemctl disable postfix
   ```

### When Swap Usage is High

1. **Adjust Swap Settings**

   ```bash
   echo 5 | sudo tee /proc/sys/vm/swappiness  # Set more conservatively
   ```

2. **Check Memory Usage**
   ```bash
   ps aux --sort=-%mem | head -10  # Check processes with high memory usage
   ```

## 📈 Performance Benchmarks

### Expected Performance Metrics

- **Memory Usage**: 70-80% (normal)
- **Swap Usage**: 0-20% (normal)
- **CPU Usage**: 10-30% (typical)
- **Disk I/O**: Minimized

### Performance Monitoring Script

```bash
#!/bin/bash
# Performance monitoring script

echo "=== System Resource Status ==="
echo "Memory:"
free -h

echo -e "\nSwap:"
swapon -s

echo -e "\nDisk:"
df -h

echo -e "\nTop 5 CPU usage processes:"
ps aux --sort=-%cpu | head -6

echo -e "\nTop 5 memory usage processes:"
ps aux --sort=-%mem | head -6
```

## 🎯 Optimization Checklist

### Pre-deployment Verification

- [ ] Verify GCP performance pool activation
- [ ] Confirm 2GB swap file creation
- [ ] Verify swap parameter optimization
- [ ] Confirm memory monitoring service activation

### Runtime Monitoring

- [ ] Keep memory usage below 90%
- [ ] Keep swap usage below 80%
- [ ] Monitor log file sizes
- [ ] Regular performance metric checks

### Problem Response

- [ ] Reduce PHP-FPM process count when memory is low
- [ ] Check memory usage when swap usage is high
- [ ] Clean logs when disk space is low
- [ ] Clear cache when performance degrades

---

Following this guide will enable optimal Flarum operation within GCP Free Tier limits.