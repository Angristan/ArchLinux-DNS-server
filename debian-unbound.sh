#!/bin/bash

if [ "$UID" -ne "0" ]; then
	echo "Use this script as root."
	exit 1
fi

# Install unbound
apt install -y unbound

# Set conf location
unbound -c /etc/unbound/unbound.conf

# Set root key location (for DNSSEC)
unbound-anchor -a "/var/lib/unbound/root.key"

# Get root servers list
wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /var/lib/unbound/root.hints

# Configuration
mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.old

echo "server:
root-hints: \"/var/lib/unbound/root.hints\"
auto-trust-anchor-file: \"/var/lib/unbound/root.key\"
interface: 127.0.0.1
access-control: 127.0.0.1 allow
port: 53
do-daemonize: yes
num-threads: 2
use-caps-for-id: yes
harden-glue: yes
hide-identity: yes
hide-version: yes" > /etc/unbound/unbound.conf

# Restart unbound
service unbound restart

# Allow the modification of the file
chmod 664 /etc/resolv.conf
# Disable previous DNS servers
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf
# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
# Disallow the modification to prevent the file from being overwritten by the system
chmod 444 /etc/resolv.conf

echo "The installation is done."
