#!/bin/bash

sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h2>Welcome to nginx page</h2>" > /var/www/html/index.html
