# Performance Guide

Optimize Flarum for GCP Free Tier.

## 🚀 Performance Pool

Enable in Terraform:

```hcl
scheduling {
  preemptible = false
  automatic_restart = true
  on_host_maintenance = "MIGRATE"
}
```

## 💾 Swap Memory

2GB swap file for e2-micro stability:

```bash
# Check swap
swapon -s
free -h

# Monitor
watch -n 5 'free -h'
```

## 📊 Monitoring

```bash
# Memory logs
sudo tail -f /var/log/flarum/memory.log

# System status
sudo systemctl status nginx php81-php-fpm
```

## ⚠️ Troubleshooting

### Memory Issues

```bash
# Reduce PHP processes
sudo systemctl edit php81-php-fpm
# pm.max_children = 2

# Restart services
sudo systemctl restart php81-php-fpm
```

### High Swap Usage

```bash
# Check processes
ps aux --sort=-%mem | head -10

# Restart swap
sudo swapoff -a && sudo swapon -a
```

## 🎯 Optimization Checklist

- [ ] Performance pool enabled
- [ ] 2GB swap configured
- [ ] Memory usage < 90%
- [ ] Swap usage < 80%
- [ ] Regular monitoring active