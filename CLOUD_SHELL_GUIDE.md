# GCP Cloud Shell Access Guide

## Connect to VM from Cloud Shell

Cloud Shell has built-in permissions and tools. Use these commands:

### 1. Basic SSH Connection

```bash
gcloud compute ssh flarum-vm --zone=us-central1-a
```

### 2. If you need to specify the project

```bash
gcloud compute ssh flarum-vm --zone=us-central1-a --project=riderwin-flarum
```

### 3. Alternative: Direct SSH with internal tooling

```bash
gcloud compute ssh rocky@flarum-vm --zone=us-central1-a
```

---

## Once Connected - Quick Status Check

```bash
# System info
cat /etc/os-release
uname -a

# Check running services
sudo systemctl list-units --type=service --state=running | grep -E 'nginx|php|mysql|mariadb'

# Check if Flarum is installed
ls -la /var/www/

# Check web server status
sudo systemctl status nginx
sudo systemctl status php-fpm

# Check database
sudo systemctl status mysqld

# Check what's listening on ports
sudo ss -tulnp | grep LISTEN
```

---

## Manual Installation Steps (if needed)

If nothing is installed yet, you can run these commands directly on the VM:

### 1. Update System

```bash
sudo dnf update -y
```

### 2. Install EPEL and Remi Repositories

```bash
sudo dnf install -y epel-release
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
sudo dnf module enable php:remi-8.1 -y
```

### 3. Install Required Packages

```bash
sudo dnf install -y nginx \
  php81-php php81-php-fpm php81-php-mysqlnd \
  php81-php-gd php81-php-mbstring php81-php-xml \
  php81-php-curl php81-php-zip php81-php-intl \
  php81-php-tokenizer php81-php-dom \
  mysql-server git unzip
```

### 4. Install Composer

```bash
cd /tmp
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
composer --version
```

### 5. Setup MySQL

```bash
# Start MySQL
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Create database and user
sudo mysql -e "CREATE DATABASE IF NOT EXISTS flarum CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'flarum'@'localhost' IDENTIFIED BY 'YOUR_DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON flarum.* TO 'flarum'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

### 6. Install Flarum

```bash
# Create directory
sudo mkdir -p /var/www/flarum
sudo chown -R $USER:$USER /var/www/flarum

# Install Flarum
cd /var/www/flarum
composer create-project flarum/flarum . --stability=beta

# Set permissions
sudo chown -R nginx:nginx /var/www/flarum
sudo chmod -R 755 /var/www/flarum
```

### 7. Configure Nginx

```bash
# Create Nginx config
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

    location ~* \.(?:ico|css|js|gif|jpe?g|png|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Test and restart Nginx
sudo nginx -t
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 8. Configure PHP-FPM

```bash
# Start PHP-FPM
sudo systemctl start php81-php-fpm
sudo systemctl enable php81-php-fpm
```

### 9. Setup Flarum via Web UI

```bash
# Get VM external IP
curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google"

# Open this IP in your browser to complete Flarum setup
echo "Visit http://$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google") in your browser"
```

---

## Quick Verification Commands

```bash
# Check Nginx is running and accessible
sudo systemctl status nginx
curl -I localhost

# Check PHP-FPM
sudo systemctl status php81-php-fpm

# Check MySQL
sudo systemctl status mysqld
sudo mysql -u flarum -p -e "SHOW DATABASES;"

# Check Flarum files
ls -la /var/www/flarum/

# Check logs if something is wrong
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/php-fpm/www-error.log
```

---

## Troubleshooting

### If Nginx won't start:

```bash
sudo nginx -t
sudo journalctl -xeu nginx
```

### If PHP-FPM issues:

```bash
sudo journalctl -xeu php81-php-fpm
```

### If database connection fails:

```bash
sudo mysql -u flarum -p flarum -e "SELECT 1;"
```

### Check SELinux (if enabled):

```bash
sudo setenforce 0  # Temporarily disable for testing
sudo getenforce
```
