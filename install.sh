#!/bin/bash

sudo apt update
sudo apt install curl

sudo apt update
sudo apt install net-tools

sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh

# Update the package list
sudo apt update -y

# Install common dependencies
sudo apt install -y software-properties-common curl gnupg2 ca-certificates lsb-release apt-transport-https

# Add PHP repository
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y

# Install PHP 7.4, 8.1, 8.2
sudo apt install -y php7.4 php7.4-fpm php7.4-{mysql,xml,dom,bcmath,bz2,intl,gd,mbstring,zip,common,curl,mbstring,simplexml,soap,mcrypt}
sudo apt install -y php8.1 php8.1-fpm php8.1-{mysql,xml,dom,bcmath,bz2,intl,gd,mbstring,zip,common,curl,mbstring,simplexml,soap,mcrypt}
sudo apt install -y php8.2 php8.2-fpm php8.2-{mysql,xml,dom,bcmath,bz2,intl,gd,mbstring,zip,common,curl,mbstring,simplexml,soap,mcrypt}
sudo apt install -y php8.3 php8.3-fpm php8.3-{mysql,xml,dom,bcmath,bz2,intl,gd,mbstring,zip,common,curl,mbstring,simplexml,soap,mcrypt}
enable_display_errors() {
    local php_version=$1
    local ini_fpm="/etc/php/$php_version/fpm/php.ini"
    local ini_cli="/etc/php/$php_version/cli/php.ini"
    sudo sed -i 's/^display_errors = .*/display_errors = On/' $ini_fpm
    sudo sed -i 's/^display_errors = .*/display_errors = On/' $ini_cli
    sudo systemctl restart php$php_version-fpm
}
enable_display_errors 7.4
enable_display_errors 8.1
enable_display_errors 8.2
enable_display_errors 8.3

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install MySQL
sudo apt install -y mysql-server
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test%';"
mysql -e "FLUSH PRIVILEGES;"
sudo systemctl restart mysql

# Start and enable MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

php -v
composer -V
nginx -v
mysql --version




# Install Nginx
sudo apt install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx





# Output versions to verify installation
php -v
composer -V
nginx -v
mysql --version



#VS CODE
sudo apt-get update -y
sudo apt-get install -y software-properties-common apt-transport-https wget
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt-get update -y
sudo apt-get install -y code
code --version
#END VS CODE


#SUBLIME
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"
sudo apt-get update -y
sudo apt-get install -y sublime-text
subl --version
#END SUBLIME



# Elastic Search
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update -y
sudo apt-get install -y elasticsearch
sudo systemctl enable elasticsearch.service

HEAP_SIZE="2g"
sudo sed -i "s/^-Xms.*/-Xms$HEAP_SIZE/" /etc/elasticsearch/jvm.options
sudo sed -i "s/^-Xmx.*/-Xmx$HEAP_SIZE/" /etc/elasticsearch/jvm.options

sudo systemctl start elasticsearch.service
sudo systemctl status elasticsearch.service
#END Elastic Search


sudo apt update
sudo apt install filezilla


wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
tar -xvzf postman.tar.gz
sudo mv Postman /opt/Postman
sudo ln -s /opt/Postman/Postman /usr/local/bin/postman


#Setup Multiple Dummy Apache Vhost with different php versions