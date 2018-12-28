#! /bin/bash

# install lamp stack packages
yum update
yum install epel-release  -y
yum install httpd* mariadb-server php php-mysql mod_ssl vim wget -y

#start  and enable services
systemctl enable httpd mariadb
systemctl start httpd mariadb

#configure virtual host
echo "<VirtualHost *:80>
DocumentRoot /var/www/html
</VirtualHost>" >>/etc/httpd/conf.d/vhost.conf

#configure database
mysqladmin -u root password 12345
dbase="create database mydata; grant all privileges on mydata.* to 'kad'@'localhost' IDENTIFIED BY '54321'; FLUSH PRIVILEGES;"

echo $dbase | mysql -u root -p

#host wordpress
wget  https://wordpress.org/latest.tar.gz
tar -xf  latest.tar.gz
mv wordpress/* /var/www/html/
cd /var/www/html/
cp wp-config-sample.php wp-config.php

#Include database details
sed -i "s/database_name_here/mydata/" wp-config.php
sed -i "s/username_here/kad/" wp-config.php
sed -i "s/password_here/54321/" wp-config.php
sed -i "s/localhost/localhost/" wp-config.php

#disable selinux
setenforce 0

#restart httpd
systemctl restart httpd mariadb

:wq

aws : open security groups  : http  80 anywhere
virtual box : firewall-cmd --permanent  --add-port=80/tcp
                      firewall-cmd --reload
