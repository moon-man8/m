#!/bin/bash


parameter_value="$1"

# Initialize the file path variable with an empty value
file_path=""

# Check if /etc/systemd/system/2.service exists
if [ -f "/etc/systemd/system/2.service" ]; then
    file_path="/etc/systemd/system/2.service"
else
    file_path="/etc/systemd/system/m.service"
fi


# Extract the file name from the file path
file_name=$(basename "$file_path")


sudo systemctl stop "${file_name}"

sudo systemctl stop h.service


# Construct the new string with the $parameter_value
new_string="1710454080.${parameter_value}#e1rj-h9dc"

# Replace the word between 1710454080. and #e1rj-h9dc with value of $parameter_value
sed -i "s/1710454080\..*#e1rj-h9dc/$new_string/g" "${file_path}"



sudo systemctl daemon-reload

sudo systemctl restart h.service

sudo systemctl restart "${file_name}"

sudo systemctl status h.service

sudo systemctl status "${file_name}"

