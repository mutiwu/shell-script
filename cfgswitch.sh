#!/bin/sh
brctl addbr switch 
brctl addif switch $1
pkill dhclient
dhclient switch
ifconfig $1 0 up
