#!/bin/sh

#802.1ad hack
board=$(cat /tmp/sysinfo/board_name)
if [ "$board" = "nanostation-m-xw" ]; then
  ip link add link eth0.1 eth0ad_1_12 type vlan proto 802.1ad id 12
  ip link add link eth0.2 eth0ad_2_12 type vlan proto 802.1ad id 12
  ip link set dev eth0ad_1_12 up
  ip link set dev eth0ad_2_12 up
  bmx6 -c -i
else
  ip link add link eth0 eth0ad_12 type vlan proto 802.1ad id 12
  ip link add link eth1 eth1ad_12 type vlan proto 802.1ad id 12
  ip link set dev eth0ad_12 up
  ip link set dev eth1ad_12 up
fi

#tinc
#tincd -n meshtodon
