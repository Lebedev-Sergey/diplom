#!/bin/bash
sudo apt update -y
sudo apt install -y nginx
sudo rm /var/www/html/*.html
sudo mv /tmp/index.html /var/www/html/
sudo mv /tmp/nginx.conf /etc/nginx/
sudo systemctl start nginx
sudo systemctl enable nginx
sudo apt update -y
sudo apt install -y zabbix-agent
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
sudo systemctl restart nginx zabbix-agent
cd /tmp/
wget "https://ftp.yandex.ru/mirrors/elastic/8/pool/main/f/filebeat/filebeat-8.9.2-amd64.deb"
sudo dpkg -i filebeat-8.9.2-amd64.deb
sudo apt update
sudo rm install.sh