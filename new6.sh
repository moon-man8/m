#!/bin/bash

parameter_value="$1"

# Construct the new string with the parameter value
new_string="1710454080.${parameter_value}#e1rj-h9dc"

# Replace the line containing the placeholder with the new string
# sed -i "s/1710454080\..*#e1rj-h9dc/$new_string/g" 2.txt
sed "s/1710454080\..*#e1rj-h9dc/$new_string/g" 2.txt

echo "Parameter value updated successfully in the file."
