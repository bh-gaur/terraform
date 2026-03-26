#!/bin/bash

# Update package list first
sudo apt update

# Install dependencies for adding Nginx repository
sudo apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# Add Nginx signing key
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# Import the key for verification
sudo gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

# Add the Nginx repository
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

# Pin Nginx packages to the Nginx origin
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx

# Update package list again after adding new repo
sudo apt update

# Install Nginx
sudo apt install -y nginx

# Check nginx version
nginx -v

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx

sudo apt update

sudo apt install fontconfig openjdk-21-jre -y
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update 

sudo apt-get install jenkins -y

NGINX_CONFIG_FILE="/etc/nginx/conf.d/default.conf"
# INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
INSTANCE_IP=$(curl -s ipinfo.io | grep -oP '"ip": "\K[\d.]+')
# Write the proxy pass configuration to the file
echo "server {
    listen 80;
    server_name $INSTANCE_IP;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}" | sudo tee $NGINX_CONFIG_FILE > /dev/null

sudo systemctl reload nginx
sudo nginx -s reload 