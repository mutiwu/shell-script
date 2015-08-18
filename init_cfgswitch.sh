#!/bin/sh
#add for chkconfig
#chkconfig: 2345 70 30
#description: cp this script to /etc/init.d/, then chmod +x xxx, chkconfig --add cfgswitch.sh, chkconfig --level 2345 xxx
#processname: cfgswitch
pkill dhclient
brctl addbr switch 
brctl addif switch eno1
pkill dhclient
ip link set eno1 up
dhclient switch
ifconfig eno1 0 up
