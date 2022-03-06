#!/bin/sh
PHP_VERSION="7.4" # This is version we want

export DEBIAN_FRONTEND=noninteractive
#PATH="/usr/sbin:$PATH"
#. .bashrc

# /*===============================
# =            APT            =
# ===============================*/
echo "Adding PPAs"
sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:ondrej/apache2 # Super Latest Version

echo "Updating Apt"
apt-get -y -qq update
apt-get -y -qq upgrade

echo "Install Utilities"
apt-get -y -qq install curl vim htop


echo "Installing media tools"
apt-get -y -qq install ffmpeg imagemagick pngquant gifsicle freeglut3 webp


# /*===============================
# =            APACHE            =
# ===============================*/
echo "Setup Apache"

# Install the package
sudo apt-get -y install apache2


PHP_BASE=$(php -v | grep -Po '(?<=PHP )\d.\d')
echo "    PHP : ${PHP_BASE}"

# Remove "html" and add public
mv /var/www/html /var/www/public


# Clean VHOST with full permissions
MY_WEB_CONFIG="<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/public
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
	<Directory \"/var/www/public\">
		Options Indexes FollowSymLinks
		AllowOverride all
		Require all granted
	</Directory>
</VirtualHost>"

echo "$MY_WEB_CONFIG" | sudo tee /etc/apache2/sites-available/000-default.conf

 # Squash annoying FQDN warning
echo "ServerName darebox" | sudo tee /etc/apache2/conf-available/servername.conf
sudo a2enconf servername


# Enabled missing h5bp modules (https://github.com/h5bp/server-configs-apache)
a2enmod expires
a2enmod headers
a2enmod include
a2enmod rewrite

service apache2 restart


# /*===============================
# =            PHP            =
# ===============================*/

echo "Installing PHP"

# Add index.php to readable file types
MAKE_PHP_PRIORITY='<IfModule mod_dir.c>
	DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>'
echo "$MAKE_PHP_PRIORITY" | sudo tee /etc/apache2/mods-enabled/dir.conf

apt-get -y -qq install \
	php${PHP_VERSION} php${PHP_VERSION}-dev php${PHP_VERSION}-common php${PHP_VERSION}-redis \
	php${PHP_VERSION}-apcu php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql php${PHP_VERSION}-xml \
	php${PHP_VERSION}-opcache php${PHP_VERSION}-gd php${PHP_VERSION}-curl php${PHP_VERSION}-zip \
	php${PHP_VERSION}-bcmath php${PHP_VERSION}-bz2 php${PHP_VERSION}-cgi php${PHP_VERSION}-cli \
	php${PHP_VERSION}-fpm php${PHP_VERSION}-imap php${PHP_VERSION}-intl php${PHP_VERSION}-json \
	php${PHP_VERSION}-odbc php${PHP_VERSION}-pspell php${PHP_VERSION}-tidy \
	php${PHP_VERSION}-xmlrpc php${PHP_VERSION}-zip php${PHP_VERSION}-imagick php-pear

PHP_USER_INI_PATH=/etc/php/${PHP_VERSION}/apache2/conf.d/user.ini

apt-get -y install "libapache2-mod-php${PHP_VERSION}"
a2enmod "php${PHP_VERSION}"

echo 'display_startup_errors = On' | tee -a $PHP_USER_INI_PATH
echo 'display_errors = On' | tee -a $PHP_USER_INI_PATH
echo 'error_reporting = E_ALL' | tee -a $PHP_USER_INI_PATH
echo 'short_open_tag = On' | tee -a $PHP_USER_INI_PATH

echo 'opache.enable = 0' | tee -a $PHP_USER_INI_PATH
sed -i s,\;opcache.enable=0,opcache.enable=0,g /etc/php/${PHP_VERSION}/apache2/php.ini

service apache2 restart


# /*===============================
# =            Sphinx            =
# ===============================*/

echo "Install Sphinx"
apt-get -y -qq install sphinxsearch


# /*===============================
# =            MARIADB            =
# ===============================*/

echo "Installing MariaDB"
apt-get -y -qq install -y mariadb-server mariadb-client mariadb-common mariadb-backup # galera is included in mariadb-server now
mysql -e "CREATE DATABASE darebox"
mysql -e "GRANT ALL PRIVILEGES ON darebox.* TO root@localhost IDENTIFIED BY 'root'"


# /*===============================
# =            PHPMyAdmin            =
# ===============================*/

echo "Install PHPMyAdmin"
apt-get -y -qq install phpmyadmin
cp /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
a2enconf phpmyadmin
service apache2 restart


# /*===============================
# =            MAILHOG            =
# ===============================*/
apt-get -y install golang-go
#go get github.com/mailhog/MailHog

wget --quiet -O ~/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
chmod +x ~/mailhog

# Enable and Turn on
tee /etc/systemd/system/mailhog.service <<EOL
[Unit]
Description=MailHog Service
After=network.service vagrant.mount
[Service]
Type=simple
ExecStart=/usr/bin/env /home/vagrant/mailhog > /dev/null 2>&1 &
[Install]
WantedBy=multi-user.target
EOL

systemctl enable mailhog
systemctl start mailhog

# Install Sendmail replacement for MailHog
go get github.com/mailhog/mhsendmail
ln ~/go/bin/mhsendmail /usr/bin/mhsendmail
ln ~/go/bin/mhsendmail /usr/bin/sendmail
ln ~/go/bin/mhsendmail /usr/bin/mail

echo 'sendmail_path = /usr/bin/mhsendmail' | tee -a /etc/php/${PHP_VERSION}/apache2/conf.d/user.ini

service apache2 restart

# /*===============================
# =            PYTHON            =
# ===============================*/
echo "Install Pip"
apt-get -y -qq install python3 python3-pip


#enable color prompts
sed -i '/#force_color_prompt=yes/s/^#//g' file

touch ~/root.provisioned
