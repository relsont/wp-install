#!/bin/bash
# wordpress auto install script by relsont
# Tested on Ubuntu 12.04 and 12.10
# Installs wordpress on Ubuntu machines with Nginx, Php and Mysql.

#check if root
if [ `whoami` != root ]; then
    echo "Please run as root or sudo."
    exit
fi

#check if necessary packages are installed

echo -e "\n\v\tChecking for Nginx, Php and Mysql"
for package in nginx-common nginx-full php5 php5-fpm php5-mysql mysql-server
	do
	if dpkg --get-selections | grep $package | grep -v deinstall 1> /dev/null;then
			echo -e "\n $package already installed"
#install packages if not already installed.
		else
			echo -e "\n Installing $package ..."
			apt-get install $package
		fi
	done

echo -e "\n\v\tEnter the domain name to be used"
read domain
echo "127.0.0.1 $domain" >> /etc/hosts
echo "127.0.0.1 www.$domain" >> /etc/hosts
echo -e "\n\v\tThank you ... $domain added"

echo -e "\n\v\tConfiguring nginx..."
mkdir /var/www/$domain
cd /var/www/$domain

echo -e "server {\n\tlisten 80;
\n\tserver_name $domain;
\n\tserver_name www.$domain;
\n\troot /var/www/$domain/;
\n\tindex index.html index.php;
\n
\n\tlocation ~ \.php$ {
\nfastcgi_pass 127.0.0.1:9000;
\ninclude /etc/nginx/fastcgi_params;}
}" >> /etc/nginx/sites-available/$domain

ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/$domain

echo -e "\n\v\tNginx Configured."

/etc/init.d/nginx reload 1> /dev/null # reload nginx

echo -e "\n\v\tNginx Reloaded."

/etc/init.d/php5-fpm restart 1> /dev/null # restart php5-fpm

echo -e "\n\v\tphp-fpm Restarted."

echo -e "\n\v\tDownloading Wordpress...."

wget http://wordpress.org/latest.zip
unzip -q latest.zip
echo -e "\n\v\tExtracting Wordpress...."
cp -r wordpress/* .
echo -e "\n\v\tFiles Copied to Doc Root"

echo -e "\n\v\tPlease provide Mysql Server Credentials."
echo -e "\n\vUsername :"
read dbuser
echo -e "\n\vPassword :"
read dbpass

if mysqladmin -u $dbuser -p$dbpass CREATE $domain"_db"; then
	echo -e "\n\v\tMysql DB Created Successfully"
else
	echo -e "\n\v\tMysql DB Creation Failed, check credentials and try again."
exit
fi

echo -e "\n\v\tSetting up WordPress...."

cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${domain}_db/g" wp-config.php
sed -i "s/username_here/${dbuser}/g" wp-config.php
sed -i "s/password_here/${dbpass}/g" wp-config.php

echo -e "\n\v\tClean up ... Deleting unwanted files."

rm -rf wordpress
rm -f latest.zip

echo -e "\n\v\tWordPress Installed
\n\v\tVisit http://www.$domain to start using your blog"



#You're here because you know something. What you know, you cant explain, but you feel it.



#The End.
