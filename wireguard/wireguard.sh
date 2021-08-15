#!/bin/bash
set -x
add-apt-repository -y ppa:wireguard/wireguard
apt-get update -y
apt-get install wireguard-dkms wireguard-tools linux-headers-$(uname -r) -y
umask 077
wg genkey | tee server_private_key | wg pubkey > server_public_key
wg genkey | tee client_private_key | wg pubkey > client_public_key

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.200.200.1
SaveConfig = true
PrivateKey = $(cat server_private_key)
ListenPort = 51820

[Peer]
PublicKey = $(cat client_public_key)
AllowedIPs = 10.200.200.2/32
EOF

cat <<EOF > wg0-client.conf
[Interface]
Address = 10.200.200.2
PrivateKey = $(cat client_private_key)
DNS = 10.200.200.1

[Peer]
PublicKey = $(cat server_public_key)
Endpoint = $(curl ifconfig.co):51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21
EOF

chown -v root:root /etc/wireguard/wg0.conf
chmod -v 600 /etc/wireguard/wg0.conf
wg-quick up wg0
systemctl enable wg-quick@wg0.service
systemctl restart wg-quick@wg0.service

# networking
grep -q "^net.ipv4.ip_forward=1$" /etc/sysctl.conf | echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
echo 1 > /proc/sys/net/ipv4/ip_forward

# firewall
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 51820 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s 10.200.200.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s 10.200.200.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o eth0 -j MASQUERADE
apt-get install -y iptables-persistent
systemctl enable netfilter-persistent
netfilter-persistent save

apt-get install -y unbound unbound-host
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache

cat <<EOF > /etc/unbound/unbound.conf
server:

  num-threads: 4

  #Enable logs
  verbosity: 1

  #list of Root DNS Server
  root-hints: "/var/lib/unbound/root.hints"

  #Use the root servers key for DNSSEC
  auto-trust-anchor-file: "/var/lib/unbound/root.key"

  #Respond to DNS requests on all interfaces
  interface: 0.0.0.0
  max-udp-size: 3072

  #Authorized IPs to access the DNS Server
  access-control: 0.0.0.0/0                 refuse
  access-control: 127.0.0.1                 allow
  access-control: 10.200.200.0/24         allow

  #not allowed to be returned for public internet  names
  private-address: 10.200.200.0/24

  # Hide DNS Server info
  hide-identity: yes
  hide-version: yes

  #Limit DNS Fraud and use DNSSEC
  harden-glue: yes
  harden-dnssec-stripped: yes
  harden-referral-path: yes

  #Add an unwanted reply threshold to clean the cache and avoid when possible a DNS Poisoning
  unwanted-reply-threshold: 10000000

  #Have the validator print validation failures to the log.
  val-log-level: 1

  #Minimum lifetime of cache entries in seconds
  cache-min-ttl: 1800

  #Maximum lifetime of cached entries
  cache-max-ttl: 14400
  prefetch: yes
  prefetch-key: yes
EOF

chown -R unbound:unbound /var/lib/unbound
systemctl enable unbound
systemctl restart unbound
