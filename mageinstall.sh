#!/bin/bash

#Declartions
MYSQL_USER="root"
MYSQL_PASSWORD="Goal#2022"
MYSQL_HOST="localhost"
DB_NAME="mage247_1"
PROJECTDIR="mage247_1"
MAGE_VERSION="2.4.6"
PHP_VERSION="8.2"
MAGE_URL="http://mage247e.local/"
MAGE_ADMIN="admin"
MAGE_ADMIN_PWD="admin123"

#Not need to change
COMPOSER_VERSION="2.8.6"
COMPOSER="composer.$COMPOSER_VERSION.phar"
MAGEPUBKEY="9f92ef46e683501d33ee0a7e40025443"
MAGEPRVKEY="b5be3d8fe042015382ba0a14e99b3393"


success() {
    echo "\e[32m ✔ $1\e[0m"
}

error() {
    echo "\e[31m ❌ $1\e[0m"
}


#Check if mysql installed or not
if command -v mysql &> /dev/null; then
    success "MySQL exists."
else
    error "MySQL is NOT installed. Useful link: https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04"
    exit
fi

#Download Compsoer
if [ ! -f "$COMPOSER" ]; then
    URL="https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar"
	curl -sS -o "$COMPOSER" "$URL"
	chmod +x "$COMPOSER"

	"php$PHP_VERSION" "$COMPOSER" config --global http-basic.repo.magento.com "$MAGEPUBKEY" "$MAGEPRVKEY"
fi

success "composer exists."

if ! php -v | grep -q "PHP $PHP_VERSION"; then
	apt install software-properties-common
	add-apt-repository ppa:ondrej/php
	apt install "php$PHP_VERSION" "php$PHP_VERSION-fpm" "php$PHP_VERSION-{mysql,xml,dom,bcmath,bz2,intl,gd,mbstring,zip,common,curl,mbstring,simplexml,soap,mcrypt}"
fi

success "PHP exists."

if mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "USE $DB_NAME;" 2>/dev/null; then
    success "Database '$DB_NAME' Found."
else
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    echo "Mysql DB May not created automatically, it is recommand to create it manually"
fi


if [ ! -d "$PROJECTDIR" ]; then
    "php$PHP_VERSION" "$COMPOSER" create-project --repository-url=https://repo.magento.com/ magento/project-community-edition="$MAGE_VERSION" "./$PROJECTDIR" --no-interaction
    success "Magento Composer Created"
else
    success "Project already exists."
    cd "$PROJECTDIR"
fi


"php$PHP_VERSION" bin/magento setup:install --base-url="$MAGE_URL" --db-host="$MYSQL_HOST"  --db-name="$DB_NAME" --db-user="$MYSQL_USER" --db-password=""$MYSQL_PASSWORD"" --admin-firstname=admin  --admin-lastname=admin  --admin-email=admin@admin.com  --admin-user="$MAGE_ADMIN"  --admin-password="$MAGE_ADMIN_PWD"   --language=en_US  --currency=USD  --timezone=America/Chicago  --use-rewrites=1  --backend-frontname=admin  --elasticsearch-index-prefix="$PROJECTDIR"

success "Execute the setup:upgrade, and compilation";
success "END";