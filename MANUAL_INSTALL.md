# Manual Flarum Installation Guide

## Quick Reference

- VM IP: 34.60.101.134
- Database: MySQL (local)
- DB Name: flarum
- DB User: flarum
- DB Password: MySecurePass123!

## Installation Steps

### 1. SSH into VM (from Cloud Shell)

```bash
gcloud compute ssh flarum-vm --zone=us-central1-a
```

### 2. Update System & Install EPEL

```bash
sudo dnf update -y
sudo dnf install -y epel-release
```

### 3. Install Remi Repository for PHP 8.1

```bash
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
sudo dnf module enable php:remi-8.1 -y
```

### 4. Install Required Packages

```bash
sudo dnf install -y nginx \
  php php-fpm php-mysqlnd php-gd php-mbstring \
  php-xml php-curl php-zip php-intl php-tokenizer \
  php-dom php-json php-opcache \
  mysql-server git unzip wget
```

### 5. Install Composer

```bash
cd /tmp
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
composer --version
```

### 6. Setup MySQL

```bash
# Start MySQL
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Create database and user
sudo mysql << EOF
CREATE DATABASE IF NOT EXISTS flarum CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'flarum'@'localhost' IDENTIFIED BY 'MySecurePass123!';
GRANT ALL PRIVILEGES ON flarum.* TO 'flarum'@'localhost';
FLUSH PRIVILEGES;
EOF

# Verify
sudo mysql -u flarum -p'MySecurePass123!' flarum -e "SELECT 1;"
```

### 7. Create Flarum Directory

```bash
sudo mkdir -p /var/www/flarum
sudo chown -R $USER:$USER /var/www/flarum
cd /var/www/flarum
```

### 8. Install Flarum

```bash
composer create-project flarum/flarum . --stability=beta
```

### 9. Set Permissions

```bash
sudo chown -R nginx:nginx /var/www/flarum
sudo chmod -R 755 /var/www/flarum
sudo chmod -R 775 /var/www/flarum/storage
sudo chmod 775 /var/www/flarum/public/assets
```

### 10. Configure Nginx

```bash
sudo tee /etc/nginx/conf.d/flarum.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/flarum/public;

    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Remove default config if exists
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/conf.d/default.conf

# Test Nginx config
sudo nginx -t
```

### 11. Configure PHP-FPM

```bash
# Update PHP-FPM settings
sudo sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sudo sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf

# Set PHP memory limit
sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php.ini
```

### 12. Start Services

```bash
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify services
sudo systemctl status nginx
sudo systemctl status php-fpm
sudo systemctl status mysqld
```

### 13. Setup 2GB Swap (for e2-micro stability)

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 14. Check Firewall (if enabled)

```bash
sudo systemctl status firewalld
# If active:
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

### 15. Get VM External IP

```bash
curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google"
```

## Access Flarum

Open your browser and go to:

```
http://34.60.101.134
```

## Web Setup Form

Fill in these values:

**Forum Settings:**

- Forum Title: (Your choice)
- Admin Username: admin
- Admin Email: your@email.com
- Admin Password: (Your choice)

**Database Settings:**

- Database Host: localhost
- Database Name: flarum
- Database Username: flarum
- Database Password: MySecurePass123!
- Table Prefix: (leave default or empty)

Click **Install Flarum** and wait for completion!

## Troubleshooting

### Check Logs

```bash
# Nginx logs
sudo tail -f /var/log/nginx/error.log

# PHP-FPM logs
sudo tail -f /var/log/php-fpm/www-error.log

# Flarum logs
sudo tail -f /var/www/flarum/storage/logs/flarum.log
```

### Permission Issues

```bash
cd /var/www/flarum
sudo chown -R nginx:nginx .
sudo chmod -R 755 .
sudo chmod -R 775 storage public/assets
```

### Service Issues

```bash
sudo systemctl restart nginx
sudo systemctl restart php-fpm
sudo systemctl restart mysqld
```

### Database Connection Test

```bash
sudo mysql -u flarum -p'MySecurePass123!' flarum -e "SHOW TABLES;"
```

## Success Checklist

- [ ] MySQL running and accessible
- [ ] Nginx running and serving files
- [ ] PHP-FPM running
- [ ] Flarum files in /var/www/flarum
- [ ] Permissions set correctly
- [ ] Can access http://34.60.101.134
- [ ] Flarum web installer loads
- [ ] Installation completes successfully

## Next Steps After Installation

1. Complete web setup
2. Configure forum settings
3. Install extensions (optional)
4. Set up email (optional)
5. Customize theme (optional)

Your Flarum forum will be live at: **http://34.60.101.134**
