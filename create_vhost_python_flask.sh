#!/bin/bash

# Function to prompt user for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local value
    read -p "$prompt [$default]: " value
    echo "${value:-$default}"
}

# Prompt user for domain name
domainname=$(prompt_with_default "Enter Domain Name" "example.com")

# Prompt user for Python Flask Port
pythonport=$(prompt_with_default "Enter Python Flask Port" "5000")

# Confirm with the user
read -p "Proceed with Domain Name: $domainname and Python Flask Port: $pythonport? [Y/n]: " confirmation
confirmation=${confirmation:-Y}  # Default to Y if Enter key is pressed

if [[ $confirmation != "Y" && $confirmation != "y" ]]; then
    echo "Exiting script."
    exit 0
fi

# Copy vhost_template_conf to domainname.conf and replace placeholders
cp vhost_template_conf "/etc/httpd/conf.d/$domainname.conf"
sed -i "s/domainname/$domainname/g; s/pythonport/$pythonport/g" "/etc/httpd/conf.d/$domainname.conf"

# Create directory for public_html
mkdir -p "/var/www/$domainname/public_html"

# Perform Apache config test
if ! httpd -t; then
    echo "Apache configuration test failed. Exiting."
    exit 1
fi

# Reload Apache
systemctl reload httpd

# Run certbot command
certbot --apache -d $domainname
