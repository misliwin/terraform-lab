#!/bin/bash
apt update -y
apt install -y nginx
systemctl start nginx
systemctl enable nginx
rm /var/www/html/index.nginx-debian.html
echo '<html><head><title>Taco Team Server</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">Strona stworzona przez terraform przez misliwin ${instance_counter} </span></span></p></body></html>' | tee /var/www/html/index.html
