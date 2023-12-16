#!/bin/bash

sudo apt update -y
sudo apt install -y default-jdk
cd /tmp/
wget "https://ftp.yandex.ru/mirrors/elastic/8/pool/main/k/kibana/kibana-8.9.2-amd64.deb"
sudo dpkg -i kibana-8.9.2-amd64.deb
sudo apt update -y
sudo systemctl start kibana.service
sudo systemctl enable kibana.service