#!/bin/bash
set -euo pipefail

export KUBE_MASTER_IP_01="192.168.1.101"
export KUBE_MASTER_IP_02="192.168.1.102"
export KUBE_MASTER_IP_03="192.168.1.103"

haproxy_version="1.8.19-1+rpi1"

echo "Installing haproxy ${haproxy_version}..."
apt-get install -y --no-install-recommends "haproxy=${haproxy_version}"
apt-mark hold haproxy

# create a configuration file for all other master hosts
cat << EOF >> /etc/haproxy/haproxy.cfg

frontend kube-api
  bind 0.0.0.0:8443
  bind 127.0.0.1:8443
  mode tcp
  option tcplog
  timeout client 4h
  default_backend kube-api-be

backend kube-api-be
  mode tcp
  option tcp-check
  timeout server 4h
  balance roundrobin
  default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
  server kube-master-01 192.168.1.101:6443 check
  server kube-master-02 192.168.1.102:6443 check
  server kube-master-03 192.168.1.103:6443 check
EOF

# reload after new configuration file has been updated
systemctl reload haproxy
