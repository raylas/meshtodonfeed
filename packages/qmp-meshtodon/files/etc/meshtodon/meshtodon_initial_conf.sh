#!/bin/sh

#10.a-b.c-d.1

#hack to change default password
cat <<"EOL" > /etc/shadow
root:$1$SCqxKOZ9$NX1sMkFze4bUDXu93sQQH.:17382:0:99999:7:::
daemon:*:0:0:99999:7:::
ftp:*:0:0:99999:7:::
network:*:0:0:99999:7:::
nobody:*:0:0:99999:7:::
EOL

#set ip ranges
a=31
b=254
c=0
d=254

randa=$(tr -cd 1-9 </dev/urandom | head -c 6)
randb=$(tr -cd 1-9 </dev/urandom | head -c 6)

x=$(($randa % (($b+1-$a))+$a))
y=$(($randb % (($d+1-$c))+$c))

ip="10.$x.$y.1"

mac=$(ip link show eth0 | awk '/ether/ {print $2}' | sed s/://g)
node=${mac:8}
devname="sbmesh"
hostname="$devname-$node"
ssid="sbmesh-$node"

touch /etc/config/meshtodon
echo "config meshtodon 'main'" > /etc/config/meshtodon
uci set meshtodon.main.hostname="$hostname"
uci set meshtodon.main.ssid="$ssid"

uci set system.@system[0].hostname="$hostname"
uci set qmp.node.community_id="$devname"

channel=$(uci get wireless.radio0.channel)
#default to 6
newchannel=6
if [ "$channel" -le 14 ]; then
	newchannel=6
elif [ "$channel" -ge 36 ]; then
	newchannel=165
fi

#this needs to be fixed to allow for dual band units
uci set qmp.@wireless[0].channel="$newchannel"
uci set wireless.radio0.channel="$newchannel"

uci set qmp.networks.bmx6_ipv4_address="$ip/24"
uci set qmp.roaming.ignore='1'
uci set qmp.networks.lan_address="$ip"
uci set qmp.networks.lan_netmask='255.255.255.0'
uci set qmp.networks.bmx6_ipv4_address="$ip/24"
uci set qmp.@wireless[0].mode='adhoc_ap'

uci set bmx6.general.tun4Address="$ip/24"
uci set bmx6.tmain.tun4Address="$ip/24"

uci set network.lan.ipaddr="$ip"
uci set network.lan.netmask='255.255.255.0'

#nodog settings
uci set nodogsplash.@instance[0].enabled='1'
uci set nodogsplash.@instance[0].gatewayname='SB Mesh'
uci del_list nodogsplash.@instance[0].authenticated_users='block to 10.0.0.0/8'
uci add_list nodogsplash.@instance[0].authenticated_users='block to 172.16.0.0/12'
uci add_list nodogsplash.@instance[0].authenticated_users='allow all to 10.0.0.0/8'
uci set nodogsplash.@instance[0].redirecturl='http://sb.mesh/'
#one hour
uci set nodogsplash.@instance[0].clientidletimeout='60'
#one day
uci set nodogsplash.@instance[0].clientforcetimeout='1440'

#temporary until we decide what ports
uci add_list nodogsplash.@instance[0].authenticated_users='allow all'

uci commit
qmpcontrol configure_wifi

uci set wireless.wlan0ap.ssid="$ssid"
#this doesn't seem to be working as intended
uci set gateways.inet4.ignore='0'
uci commit

#fix for nsm5 vlan issue
board=$(cat /tmp/sysinfo/board_name)
if [ "$board" = "nanostation-m-xw" ]; then
uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='2'
uci set network.@switch_vlan[-1].ports='0t 1'
uci set network.@switch_vlan[-1].vid='2'
fi

#dropbear
uci set dropbear.@dropbear[0].RootPasswordAuth='off'
uci set dropbear.@dropbear[0].Port='22'
uci set dropbear.@dropbear[0].PasswordAuth='off'
uci commit

/etc/init.d/network restart

echo "qmp mesh" > /etc/mdns/domain4
echo "qm6 mesh6" > /etc/mdns/domain6

#libremap
uci del_list libremap.settings.api_url='http://libremap.berlin.freifunk.net/api'
uci del_list libremap.settings.api_url='http://libremap.net/api/'
uci add_list libremap.settings.api_url='http://map.mesh/api'
uci set libremap.settings.community='Santa Barbara Mesh'
uci set libremap.location.latitude='34.419275'
uci set libremap.location.longitude='-119.699334'
uci commit
/etc/init.d/libremap-agent disable

#configure tinc
#/etc/meshtodon/tinc_conf.sh

#add cron for tunnel check
#(crontab -l ; echo "* * * * * /etc/meshtodon/check_tunnel.sh")| crontab -
#add cron to push key
#(crontab -l ; echo "* * * * * /etc/meshtodon/tinc_putkey.sh")| crontab -

#firewall rules
echo "#block access to private address space" >> /etc/firewall.user
echo "iptables -I FORWARD -d 192.168.0.0/16 -j DROP" >> /etc/firewall.user
echo "iptables -I FORWARD -d 172.16.0.0/12 -j DROP" >> /etc/firewall.user
echo "iptables -I FORWARD -o eth+ -d 10.0.0.0/8 -j DROP" >> /etc/firewall.user

echo "#allow only SSH (rate limit) and (tinc) on WAN" >> /etc/firewall.user
echo 'wan=$(uci get qmp.interfaces.wan_devices)' >> /etc/firewall.user
echo 'iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT' >> /etc/firewall.user
echo 'iptables -A INPUT -p tcp --dport 22 -j ACCEPT -i $wan' >> /etc/firewall.user
echo '#iptables -A INPUT -p tcp --dport 655 -j ACCEPT -i $wan' >> /etc/firewall.user
echo '#iptables -A INPUT -p udp --dport 655 -j ACCEPT -i $wan' >> /etc/firewall.user
echo 'iptables -I INPUT -p tcp --dport 22 -i $wan -m state --state NEW -m recent --set' >> /etc/firewall.user
echo 'iptables -I INPUT -p tcp --dport 22 -i $wan -m state --state NEW -m recent  --update --seconds 60 --hitcount 4 -j DROP' >> /etc/firewall.user
echo 'iptables -A INPUT -j DROP -i $wan' >> /etc/firewall.user

#keep /etc/meshtodon during upgrades
echo "/meshtodon_configured" >> /etc/sysupgrade.conf
echo "/qmp_configured" >> /etc/sysupgrade.conf
echo "/etc/mdns" >> /etc/sysupgrade.conf

#set banner
#moved to uci-defaults
#cat /etc/meshtodon/meshtodon.banner >> /etc/banner
