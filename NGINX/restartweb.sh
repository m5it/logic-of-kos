#!/bin/bash
# script to restart nginx and php fpm

echo "Restarting Nginx & PHP !"
sudo service nginx restart
sudo /etc/init.d/php7.4-fpm restart
echo "Done!"
