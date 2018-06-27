#!/bin/bash

clear
echo "This script will install and/or modify"
echo "packages needed for the EnviroPi"
echo "environmental monitoring device. "
echo
echo "Run time 10+ minutes. Reboot required."
echo

if [ "$1" != '-y' ]; then
	echo -n "CONTINUE? [y/N]"
	read
	if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then
		echo "Canceled."
		exit 0
	fi
fi

echo "Continuing..."

echo "Installing webserver and database packages..."

sudo apt-get install apache2 php mysql-server php-mysql python-virtualenv -y
sudo service apache2 restart

echo "Creating Python vitual environment..."

virtualenv --python=/usr/bin/python3 /home/pi/enviropi/env
source env/bin/activate
pip install -r requirements.txt

echo "Creating MySQL database and importing structure..."

sudo mysql -u root --execute="CREATE DATABASE enviropi;"
sudo mysql -u root enviropi < enviropi_db_structure.sql

echo "Creating MySQL user..."

read -p "Enter the desired enviropi_user's MySQL password: " mpass

sudo mysql -u root --execute="CREATE USER 'enviropi_user'@'localhost' IDENTIFIED BY '"$mpass"';GRANT ALL PRIVILEGES ON enviropi.* TO 'enviropi_user'@'localhost';FLUSH PRIVILEGES;"

# Add db credentials to config file 
echo "[DATABASE]" > pygatt_sensors.ini
echo "db_name = enviropi" >> pygatt_sensors.ini
echo "username = enviropi_user" >> pygatt_sensors.ini
echo "password = $mpass" >> pygatt_sensors.ini
echo "host = localhost" >> pygatt_sensors.ini

echo "Configuring the sensor devices to be used..."

# prompt user to enter the device(s) hw address, sensor(s), and any handle(s) 

echo "Please enter each sensor device's information... Press q when finished adding devices."
num=1
while true; do
        read -p "Enter the BLE hardware address for device $num (q to quit) : " a
        if [ $a = "q" ]
        then
                break
        fi
        echo "Adding device $num to the configuration..."
		echo "[DEVICE$num]" >> pygatt_sensors.ini
		echo "address: $a" >> pygatt_sensors.ini
		echo "sensor_id: Si7021" >> pygatt_sensors.ini
		# These are the standard handles for the Adafruit Feather 32u4 Bluefruit LE
		# will need to be modified in pygatt_sensors.ini if a different device is used  
		echo "temp_handle: 00002a6e-0000-1000-8000-00805f9b34fb" >> pygatt_sensors.ini
		echo "humid_handle: 00002a6f-0000-1000-8000-00805f9b34fb" >> pygatt_sensors.ini
		echo "battery_handle: 00002a19-0000-1000-8000-00805f9b34fb" >> pygatt_sensors.ini
        echo "Adding device $num to the database..."
		sudo mysql -u root --execute="USE enviropi; INSERT INTO device VALUES ('"$a"','Adafruit Feather 32u4 Bluefruit LE','','');"
        echo "Finished with device $a !"
		num=$((num + 1))
done

echo "Creating crontab to collect data every 10 minutes..."

(crontab -l 2>/dev/null; echo "SHELL=/bin/bash") | crontab -
(crontab -l 2>/dev/null; echo "*/10 * * * * cd /home/pi/enviropi && source /home/pi/enviropi/env/bin/activate && /home/pi/enviropi/env/bin/python3 /home/pi/enviropi/pygatt_sensors.py") | crontab -

echo "Installing web interface..."

sudo mv html/* /var/www/html/.
sudo chown -R pi:www-data /var/www

# set up needed includes 
mkdir /var/www/includes
echo "<?php" > /var/www/includes/db-login.php
echo "\$hn = 'localhost';" >> /var/www/includes/db-login.php
echo "\$db = 'enviropi';" >> /var/www/includes/db-login.php
echo "\$un = 'enviropi_user';" >> /var/www/includes/db-login.php
echo "\$pw = '$mpass';" >> /var/www/includes/db-login.php
echo "?>" >> /var/www/includes/db-login.php

addr=`hostname -I`

echo "All finished!"
echo "Web interface viewable at: http://$addr"
echo 
echo "Reboot started..."
reboot
