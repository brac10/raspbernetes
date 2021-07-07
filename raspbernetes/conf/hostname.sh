#!/bin/bash
set -euo pipefail
export RPI_NETWORK_TYPE="wlan0"
export RPI_HOSTNAME="rpi-kube-worker-02"
export RPI_IP="192.168.1.111"
export RPI_GATEWAY="192.168.1.1"
export RPI_DNS="192.168.1.169"
export RPI_TIMEZONE="America/Chicago"

echo "Setting hostname to: ${RPI_HOSTNAME}"
hostnamectl --transient set-hostname "${RPI_HOSTNAME}"
hostnamectl --static set-hostname "${RPI_HOSTNAME}"
hostnamectl --pretty set-hostname "${RPI_HOSTNAME}"
sed -i "s/raspberrypi/${RPI_HOSTNAME}/g" /etc/hosts

# set timezone
timedatectl set-timezone "${RPI_TIMEZONE}"

# cron and rsyslog require a restart for timezone settings to take affect
systemctl restart cron
systemctl restart rsyslog

# restart mDNS daemon for new settings to take effect
systemctl restart avahi-daemon
