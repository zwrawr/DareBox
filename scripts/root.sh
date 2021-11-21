#!/bin/sh
PHP_VERSION="7.4" # This is the default on ubuntu 20

export DEBIAN_FRONTEND=noninteractive

echo "Adding PPAs"
sudo add-apt-repository ppa:ondrej/php


echo "Updating Apt"
apt-get -y -qq update
apt-get -y -qq upgrade

echo "Install Utilities"
apt-get -y -qq install curl vim htop

echo "Installing PHP"
apt-get -y -qq install php7.4 php7.4-dev php7.4-redis php7.4-apcu php7.4-mbstring php7.4-mysql php7.4-xml php7.4-opcache php7.4-gd php7.4-curl php7.4-zip
apt-get -y -qq install php8.1 php8.1-dev php8.1-redis php8.1-apcu php8.1-mbstring php8.1-mysql php8.1-xml php8.1-opcache php8.1-gd php8.1-curl php8.1-zip

echo "Install Pip"
apt-get -y -qq install python3-pip

echo "Installing media tools"
apt-get -y -qq install ffmpeg imagemagick pngquant gifsicle freeglut3 webp

echo "Install Sphinx"
apt-get -y -qq install sphinxsearch

echo "Installing MariaDB"
apt-get -y -qq install -y mariadb-server mariadb-client mariadb-common mariadb-backup # galera is included in mariadb-server now

echo "Install PHPMyAdmin"
apt-get -y -qq install phpmyadmin
cp /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin
sudo service apache2 restart

echo "Configure PHP"
sudo update-alternatives --set php /usr/bin/php$PHP_VERSION
sudo update-alternatives --set php-config /usr/bin/php-config$PHP_VERSION
sudo update-alternatives --set phpdbg /usr/bin/phpdbg$PHP_VERSION
sudo update-alternatives --set phpize /usr/bin/phpize$PHP_VERSION

#sed -i "s/opcache\.enable.*/opcache.enable = 1/" /etc/php/$PHP_VERSION/apache2/conf.d/user.ini
sed -i "s/opache\.enable.*/opcache.enable = 1/" /etc/php/$PHP_VERSION/apache2/conf.d/user.ini # there's a typo :(
sed -i '/mongo.so/d' /etc/php/$PHP_VERSION/apache2/conf.d/user.ini
echo "session.save_handler = redis" >> /etc/php/$PHP_VERSION/apache2/conf.d/user.ini
echo "session.save_path = tcp://127.0.0.1:6379" >> /etc/php/$PHP_VERSION/apache2/conf.d/user.ini

#enable color prompts
sed -i '/#force_color_prompt=yes/s/^#//g' file

touch ~/root.provisioned
