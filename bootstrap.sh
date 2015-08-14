#!/usr/bin/env bash

### update & install base packages
sudo yum update
sudo yum -y install httpd
sudo yum -y install php php-devel php-intl php-ldap php-mysql php-xsl php-gd php-mbstring php-mcrypt
sudo yum -y install git
sudo yum -y install zsh
sudo yum -y install mysql-server

# Change Apache owner/group to vagrant
sed -i 's/User apache/User vagrant/' /etc/httpd/conf/httpd.conf
sed -i 's/Group apache/Group vagrant/' /etc/httpd/conf/httpd.conf
chown -R root:vagrant /var/lib/php/session

### Set Up ZSH
if [ ! -d ~vagrant/.oh-my-zsh  ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~vagrant/.oh-my-zsh
fi

### Create a new zsh configuration from the provided template
cp ~vagrant/.oh-my-zsh/templates/zshrc.zsh-template ~vagrant/.zshrc

### Change ownership of .zshrc
chown vagrant: ~vagrant/.zshrc

### Customize theme
sed -i -e 's/ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~vagrant/.zshrc

### Set zsh as default shell
chsh -s /bin/zsh vagrant

### Set servername in httpd.conf to localhost
sed -i -e 's/#ServerName www\.example\.com:80/ServerName localhost/' /etc/httpd/conf/httpd.conf

### Disable apache SendFile (causing crazy caching in VirtualBox shared directories)
sed -i -e 's/#EnableSendFile off/EnableSendFile off/' /etc/httpd/conf/httpd.conf

### Fix binding in Hosts
sed -i -e 's/127\.0\.0\.1/0\.0\.0\.0/' /etc/hosts

### point /var/www at /vagrant mount
if ! [ -L /var/www  ]; then
    rm -rf /var/www
    ln -fs /webstuff /var/www
fi



### restart Mysql & apache
sudo service mysqld start
/etc/init.d/httpd start

if [ ! -d /var/lib/mysql/sp3 ];
then
    echo "CREATE DATABASE sp3" | mysql -uroot
    if [ -f /var/www/html/sp3/sp3.sql ];
    then
        mysql -uroot sp3 < /var/www/html/sp3/sp3.sql 2> /dev/null
    fi
fi
