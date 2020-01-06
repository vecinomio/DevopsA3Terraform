#!/bin/bash -x
echo "-------------------------START-----------------------------"
yum install -y httpd
echo "<h1>Deployed via Terraform</h1>" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
echo "-------------------------FINISH----------------------------"
