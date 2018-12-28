#! /bin/bash

#USING SHELL SCRIPT INSTALL AND CONFIGURE  TOMCAT-9.0.13

INSTALLING REQUIRED PKGS
yum install java git maven wget -y
wget http://mirrors.estointernet.in/apache/tomcat/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.tar.gz
tar -xvf apache-tomcat-9.0.14.tar.gz
mkdir /opt/tomcat9
mv apache-tomcat-9.0.14 /opt/tomcat9
useradd -M -d /opt/tomcat9  -s /sbin/nologin tomcat
chown -R tomcat. /opt/tomcat9

#CONFIGURE TOMCAT AS SYSTEMD SERVICE
echo "[Unit]
Description=Apache Tomcat9
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/tomcat9/apache-tomcat-9.0.14/bin/startup.sh
ExecStop=/opt/tomcat9/apache-tomcat-9.0.14/bin/shutdown.sh
RemainAfterExit=yes
User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target" >/usr/lib/systemd/system/tomcat9.service

#SERVICE  START AND ENABLE
systemctl daemon-reload
systemctl enable tomcat9
systemctl start tomcat9

#HERE GIVING  ADMIN AND MANAGER ROLES
echo "<role rolename="manager-gui"/>
<role rolename="manager-scripts"/>
<role rolename="manager-status"/>
<user username="manager" password="12345" roles="manager-gui,manager-script,manager-status"/>
<role rolename="admin-gui"/>
<user username="admin" password="54321" roles="admin-gui,manager-gui"/>
</tomcat-users>" >>/opt/tomcat9/apache-tomcat-9.0.14/conf/tomcat-users.xml

#ACCESS TOMCAT MANAGER FROM OUTSIDE
sed -i '19,20 s/ <Valve/<!--  <Valve/g' /opt/tomcat9/apache-tomcat-9.0.14/webapps/manager/META-INF/context.xml
sed -i '19,20 s/:1" \/>/:1" \/> -->/g' /opt/tomcat9/apache-tomcat-9.0.14/webapps/manager/META-INF/context.xml
sed -i '19,20 s/ <Valve/<!--  <Valve/g' /opt/tomcat9/apache-tomcat-9.0.14/webapps/host-manager/META-INF/context.xml
sed -i '19,20 s/:1" \/>/:1" \/> -->/g' /opt/tomcat9/apache-tomcat-9.0.14/webapps/host-manager/META-INF/context.xml

systemctl stop tomcat9
systemctl start tomcat9

yum install git maven -y
git clone https://github.com/demoglot/java.git
cd java
mvn package
cd /root/java/target
mv CounterWebApp.war /opt/tomcat9/apache-tomcat-9.0.14/webapps
chown -R tomcat. /opt/tomcat9
systemctl restart tomcat9

#ALLOW THIS PORTS
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

#SELINUX ENABLE
setenforce 0

