#!/bin/bash

yum install httpd* mariadb-server php php-mysql wget -y
systemctl enable httpd mariadb
systemctl start httpd mariadb

read -p "Enter Dir name:" dbdir
mkdir -p "/var/www/"$dbdir
read -p "Enter username:" dbuser
useradd -d "/var/www/"$dbdir $dbuser
echo $dbuser"123" | passwd --stdin $dbuser
chown -R $dbuser "/var/www/"$dbdir

#websrever vhosts configuration
echo "<VirtualHost *:80>
DocumentRoot "/var/www/"$dbdir
</VirtualHost>" >>/etc/httpd/conf.d/vhosts.conf

#database env
read -p "Enter dbname:" dbname
read -p "Enter dbuser:" dbuser
read -p "Enter dppasswd:" dbpswd
read -p "Enter Allowed Host:" host

mysqladmin -u root password 12345
database="create database \`${dbname}\`;grant all privileges on \`${dbname}\`.* to '${dbuser}'@'${host}' IDENTIFIED BY '${dbpswd}';FLUSH PRIVILEGES;"
echo $database | /usr/bin/mysql -u root -p

#clone application
wget https://wordpress.org/latest.tar.gz
tar -xf latest.tar.gz
mv wordpress/* "/var/www/"$dbdir
cd "/var/www/"$dbdir
cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/$dbname/" wp-config.php
sed -i "s/username_here/$dbuser/" wp-config.php
sed -i "s/password_here/$dbpswd/" wp-config.php
sed -i "s/localhost/$host/" wp-config.php

setenforce 0
systemctl restart httpd mariadb

