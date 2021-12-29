#!/bin/bash
################################################################################
# Script for uninstalling Odoo on Ubuntu 16.04, 18.04 and 20.04 (could be used for other version too)
# Author: Roman Lacko
#-------------------------------------------------------------------------------
# Make a new file:
# sudo nano odoo-uninstall.sh
# Place this content in it and then make the file executable:
# sudo chmod +x odoo-uninstall.sh
# Execute the script to install Odoo:
# ./odoo-uninstall <odoo_user_name> <domain>
# For example:
# ./odoo-uninstall odoo14-demo www.my-odoo14-demo.com
################################################################################

# Display every command before executing it
#set -x
# Exit the script if any statement returns a non-true return value
set -e

OE_USER="$1"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
OE_CONFIG="${OE_USER}-server"
OE_DOMAIN="$2"

if [ -z "$OE_USER" ]; then
  echo "Error: Parameter 'odoo user' not set. Can not continue."
  exit 1
fi

if [ ! -d "$OE_HOME" ]; then
  echo "Error: ${OE_HOME} not found. Can not continue."
  exit 1
fi

if [ -z "$OE_DOMAIN" ]; then
  echo "Error: Parameter 'domain' not set. Can not continue."
  exit 1
fi

#--------------------------------------------------
# Odoo user, service, logs, configs, ...
#--------------------------------------------------

echo -e "\n---- Stop Odoo Service"
sudo su root -c "/etc/init.d/$OE_CONFIG stop"

echo -e "\n---- Remove Odoo Service"
sudo update-rc.d $OE_CONFIG remove

echo -e "\n---- Remove init file"
sudo rm /etc/init.d/$OE_CONFIG

echo -e "\n---- Delete ODOO system user ----"
sudo userdel -r $OE_USER

echo -e "\n---- Delete Log directory ----"
sudo rm -r /var/log/$OE_USER

echo -e "\n---- Delete server config file"
sudo rm /etc/${OE_CONFIG}.conf

#--------------------------------------------------
# Postgres db, user, ...
#--------------------------------------------------

#echo -e "\n---- Removing the ODOO PostgreSQL User  ----"
#sudo su - postgres -c "deleteuser -s $OE_USER" 2> /dev/null || true

#--------------------------------------------------
# Nginx site, certbot certificate, ...
#--------------------------------------------------

# Remove an nginx Config from Sites-Enabled

echo -e "\n---- Remove the domain config files"
cd /etc/nginx
sudo rm sites-available/$OE_USER-site
sudo rm sites-enabled/$OE_USER-site

echo -e "\n---- Check whether nginx has valid configurations and then reload the service"
sudo nginx -t
sudo service nginx restart

# Remove certificate for a domain

echo -e "\n---- Show the list of certificates"
sudo certbot certificates

echo -e "\n---- Remove certificates for a given domain"
sudo certbot delete --cert-name $OE_DOMAIN
