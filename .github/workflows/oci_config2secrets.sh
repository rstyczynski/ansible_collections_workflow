#!/bin/bash

SECTION="${1:-DEFAULT}"

function get_config() {
    local SECTION=$1
    awk -v section="[$SECTION]" '$0 == section { f=1; print; next } /^\[/ { f=0 } f ' ~/.oci/config
}

echo 
echo OCI_CONFIG_BASE64
echo ==================
get_config $SECTION | grep -v key_file= | base64

echo
echo OCI_API_KEY_BASE64
echo ==================
key_file=$(get_config $SECTION | grep key_file= | cut -d= -f2)
base64 -i $key_file

