#!/bin/bash
apt install -y zabbix-agent
systemctl enable zabbix-agent
sed -i 's/Server=127.0.0.1/Server=192.168.250.166/' /etc/zabbix/zabbix_agentd.conf
service zabbix-agent restart

apt install -y nginx
systemctl enable nginx

touch /etc/nginx/conf.d/upstream.conf
echo "upstream mainweb {" >> /etc/nginx/conf.d/upstream.conf
echo "server localhost:8080;" >> /etc/nginx/conf.d/upstream.conf
echo "server 192.168.250.167:80;" >> /etc/nginx/conf.d/upstream.conf
echo "}" >> /etc/nginx/conf.d/upstream.conf

rm /etc/nginx/sites-enabled/default

touch /etc/nginx/sites-available/balancing
echo "server {" >> /etc/nginx/sites-available/balancing
echo "listen       80;" >> /etc/nginx/sites-available/balancing
echo "server_name  localhost;" >> /etc/nginx/sites-available/balancing
echo "location / {" >> /etc/nginx/sites-available/balancing
echo "proxy_pass http://mainweb;" >> /etc/nginx/sites-available/balancing
echo "}" >> /etc/nginx/sites-available/balancing
echo "}" >> /etc/nginx/sites-available/balancing

ln -s /etc/nginx/sites-available/balancing /etc/nginx/sites-enabled/balancing


touch /etc/nginx/sites-available/8080
echo "server {" >> /etc/nginx/sites-available/8080
echo "listen       8080;" >> /etc/nginx/sites-available/8080
echo "server_name  localhost;" >> /etc/nginx/sites-available/8080
echo "root /var/www/html;" >> /etc/nginx/sites-available/8080
echo "index index.html index.htm index.nginx-debian.html;" >> /etc/nginx/sites-available/8080
echo "}" >> /etc/nginx/sites-available/8080

ln -s /etc/nginx/sites-available/8080 /etc/nginx/sites-enabled/8080

service nginx restart


apt install -y mysql-server
systemctl enable mysql

sed -i 's/bind-address/bind-address = 192.168.250.168 #/' /etc/mysql/mysql.conf.d/mysqld.cnf

service mysql restart

mysql -e "create user repl@'%' IDENTIFIED WITH caching_sha2_password BY 'oTUSlave#2020';"
mysql -e "GRANT REPLICATION SLAVE ON *.* TO repl@'%';"
mysql -e "FLUSH PRIVILEGES;"


BINLOG=$(mysql -e "SHOW MASTER STATUS;" | grep 'binlog' | awk '{print $1}')
POSITION=$(mysql -e "SHOW MASTER STATUS;" | grep 'binlog' | awk '{print $2}')
echo $BINLOG
echo $POSITION


