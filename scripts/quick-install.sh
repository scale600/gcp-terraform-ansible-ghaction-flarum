#!/bin/bash
#
# Quick Flarum Installation Script for Ubuntu 22.04
# Run this on a fresh Ubuntu VM
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Flarum Quick Install for Ubuntu     ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get VM external IP
VM_IP=$(curl -s ifconfig.me)
DB_PASSWORD="MySecurePass123!"

echo -e "${GREEN}✓ VM IP: $VM_IP${NC}"
echo ""

# Update system
echo -e "${YELLOW}[1/8] Updating system packages...${NC}"
apt-get update -qq
apt-get upgrade -y -qq

# Install required packages
echo -e "${YELLOW}[2/8] Installing required packages (Nginx, PHP, MySQL, Composer)...${NC}"
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    nginx \
    php8.1 \
    php8.1-fpm \
    php8.1-mysql \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-zip \
    php8.1-curl \
    php8.1-opcache \
    php8.1-intl \
    php8.1-bcmath \
    php8.1-tokenizer \
    php8.1-dom \
    mysql-server \
    composer \
    git \
    unzip \
    wget \
    curl

# Start services
echo -e "${YELLOW}[3/8] Starting MySQL and Nginx...${NC}"
systemctl start mysql
systemctl enable mysql
systemctl start nginx
systemctl enable nginx

# Setup MySQL database
echo -e "${YELLOW}[4/8] Creating MySQL database and user...${NC}"
mysql << EOF
CREATE DATABASE IF NOT EXISTS flarum CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'flarum'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON flarum.* TO 'flarum'@'localhost';
FLUSH PRIVILEGES;
EOF

# Install Flarum
echo -e "${YELLOW}[5/8] Installing Flarum (this may take a few minutes)...${NC}"
mkdir -p /var/www/flarum
chown -R www-data:www-data /var/www/flarum
cd /var/www/flarum

# Install Flarum using Composer as www-data user
sudo -u www-data composer create-project flarum/flarum . --stability=beta --no-interaction

# Set proper permissions
chown -R www-data:www-data /var/www/flarum
chmod -R 755 /var/www/flarum
chmod -R 775 /var/www/flarum/storage

# Configure Nginx
echo -e "${YELLOW}[6/8] Configuring Nginx...${NC}"
cat > /etc/nginx/sites-available/flarum << 'NGINXCONF'
server {
    listen 80;
    listen [::]:80;
    server_name _;
    root /var/www/flarum/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires max;
        log_not_found off;
    }
}
NGINXCONF

# Enable Flarum site
ln -sf /etc/nginx/sites-available/flarum /etc/nginx/sites-enabled/flarum
rm -f /etc/nginx/sites-enabled/default

# Configure PHP-FPM
echo -e "${YELLOW}[7/8] Configuring PHP-FPM...${NC}"
sed -i 's/user = www-data/user = www-data/' /etc/php/8.1/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = www-data/' /etc/php/8.1/fpm/pool.d/www.conf

# Test Nginx configuration
nginx -t

# Restart services
echo -e "${YELLOW}[8/8] Restarting services...${NC}"
systemctl restart nginx
systemctl restart php8.1-fpm

# Setup swap (for e2-micro stability)
if [ ! -f /swapfile ]; then
    echo -e "${YELLOW}Setting up 2GB swap for VM stability...${NC}"
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Final status check
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Flarum Installation Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Access your forum at:${NC}"
echo -e "${BLUE}  http://$VM_IP${NC}"
echo ""
echo -e "${YELLOW}Complete the setup wizard with these details:${NC}"
echo -e "  ${GREEN}Database Host:${NC} localhost"
echo -e "  ${GREEN}Database Name:${NC} flarum"
echo -e "  ${GREEN}Database User:${NC} flarum"
echo -e "  ${GREEN}Database Password:${NC} $DB_PASSWORD"
echo ""
echo -e "${YELLOW}Service Status:${NC}"
systemctl is-active --quiet nginx && echo -e "  ${GREEN}✓ Nginx: Running${NC}" || echo -e "  ${RED}✗ Nginx: Stopped${NC}"
systemctl is-active --quiet php8.1-fpm && echo -e "  ${GREEN}✓ PHP-FPM: Running${NC}" || echo -e "  ${RED}✗ PHP-FPM: Stopped${NC}"
systemctl is-active --quiet mysql && echo -e "  ${GREEN}✓ MySQL: Running${NC}" || echo -e "  ${RED}✗ MySQL: Stopped${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"

