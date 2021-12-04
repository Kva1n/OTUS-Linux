#!/bin/bash
apt install -y zabbix-agent
systemctl enable zabbix-agent
sed -i 's/Server=127.0.0.1/Server=192.168.250.166/' /etc/zabbix/zabbix_agentd.conf
service zabbix-agent restart

apt install -y apache2 
systemctl enable apache2

apt install -y mysql-server
systemctl enable mysql

sed -i 's/# server-id/server-id = 2 #/' /etc/mysql/mysql.conf.d/mysqld.cnf

service mysql restart

mysql -e "STOP SLAVE;"
mysql -e "CHANGE MASTER TO MASTER_HOST='192.168.250.168', MASTER_USER='repl', MASTER_PASSWORD='oTUSlave#2020', MASTER_LOG_FILE='binlog.000004', MASTER_LOG_POS=856, GET_MASTER_PUBLIC_KEY = 1;"
mysql -e "START SLAVE;"

mysql -e "show slave status\G"
