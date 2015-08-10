#!/bin/sh
pkill dhclient
brctl addbr switch 
brctl addif switch $1
pkill dhclient
ip link set $1 up
dhclient switch
ifconfig $1 0 up
