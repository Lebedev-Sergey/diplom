#!/bin/bash

sudo apt update -y
sudo apt install -y nginx 
sudo mv /tmp/nginx.conf /etc/nginx/
sudo apt update -y
sudo apt install -y mysql-server
sudo cd /tmp/
sudo wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo apt update -y
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
sudo systemctl enable zabbix-server zabbix-agent nginx php8.1-fpm
sudo mv /tmp/zabbix_server.conf /etc/zabbix/
sudo systemctl restart zabbix-server zabbix-agent nginx php8.1-fpm
sudo mysql \
    --execute="create database zabbix character set utf8mb4 collate utf8mb4_bin;" \
    --execute="create user 'zabbix'@'localhost' identified by '123123';" \
    --execute="grant all privileges on zabbix.* to zabbix@localhost;" \
    --execute="set global log_bin_trust_function_creators = 1;" \

sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix zabbix -p123123

sudo mysql \
     --execute="set global log_bin_trust_function_creators = 0;" \