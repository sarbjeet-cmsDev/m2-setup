#!/bin/bash

#Declartions
PHP_VERSION="8.2"
NGINX_CONF="/etc/nginx/sites-available/default"
MAGE_CONF="/etc/nginx/m2.conf"


#Not need to change
REMOTE_CONF = "https://raw.githubusercontent.com/sarbjeet-cmsDev/m2-setup/refs/heads/master/m2.conf"


success() {
    echo "\e[32m ✔ $1\e[0m"
}

error() {
    echo "\e[31m ❌ $1\e[0m"
}

#Check if nginx installed or not
if command -v nginx &> /dev/null; then
    success "Nginx is installed."
else
    success "installing nginx."
    sudo apt install -y nginx
    success "Nginx is installed."
fi


if ! php -v | grep -q "PHP $PHP_VERSION"; then
    success "installing php."
    apt install software-properties-common
    add-apt-repository ppa:ondrej/php
    apt install "php$PHP_VERSION" "php$PHP_VERSION-fpm" "php$PHP_VERSION-{mysql,xml,dom,bcmath,bz2,intl,gd,mbstring,zip,common,curl,mbstring,simplexml,soap,mcrypt}"
    success "php installed."
fi


if [ ! -f "$MAGE_CONF" ]; then
    if command -v curl &> /dev/null; then
        curl -L "$REMOTE_CONF" -o "$MAGE_CONF"
    elif command -v wget &> /dev/null; then
        wget -O "$MAGE_CONF" "$REMOTE_CONF"
    else
        error "Neither curl nor wget is installed!"
        exit 1
    fi
    success "magento2 conf installed."
else
    success "magento2 conf installed."
fi


#setup php fastcgi
FASTCGI=$(cat << EOF
upstream fastcgi_backend$PHP_VERSION {
  server  unix:/run/php/php$PHP_VERSION-fpm.sock;
}
EOF
)
if [ -f "$NGINX_CONF" ]; then
    if grep -q "fastcgi_backend$PHP_VERSION" "$NGINX_CONF"; then
        success "php fastcgi setup exist."
    else
        echo "$FASTCGI" | sudo tee -a $NGINX_CONF > /dev/null
        success "php fastcgi setup."
    fi
else
    error "nginx not installed, try again"
fi


#sample magneto nginx config
SAMPLEMAGE=$(cat << EOF
server{
        listen 80;
        server_name sample.local;
        set \$MAGE_PHP fastcgi_backend$PHP_VERSION;
        set \$MAGE_ROOT /var/www/sample;
        include /etc/nginx/m2.conf;
}
EOF
)
if [ -f "$NGINX_CONF" ]; then
    if grep -q "sample.local" "$NGINX_CONF"; then
        success "sample magneto domain setup."
    else
        echo "$SAMPLEMAGE" | sudo tee -a $NGINX_CONF > /dev/null
    fi
else
    error "sample magento domain not setup try again"
fi


# Define /etc/hosts entry
ENTRY="127.0.0.10   sample.local"
# Check if the entry already exists in the /etc/hosts file
if ! grep -q "$ENTRY" /etc/hosts; then
    # If the entry doesn't exist, append it to the /etc/hosts file
    echo "$ENTRY" | sudo tee -a /etc/hosts > /dev/null
    echo "Entry added to /etc/hosts."
else
    echo "Entry already exists in /etc/hosts."
fi