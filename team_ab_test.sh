#!/bin/sh
#parameters
host_ip=$1
ping_cnt=100
iface="eth0 eth1"

#functions
team_add() {
    for itf  in $iface;do
        ip addr flush $itf
        ip link set $itf down
        teamdctl team0 port add $itf
        if [ $? -ne 0 ]
        then
            echo "port $itf added failed"
            exit 11
        fi
        ip link set $itf up
    done
}
team_ab() {
    sleep 1
    while true;do
        if [ -z `pidof ping` ]
        then
            echo 'ping test is finished'
            echo 'Stop the ActiveBackup loop'
            break
        fi
        for itf in $iface;do
            ip link set $itf down
            teamnl team0 port
            sleep 1
            ip link set $itf up
        done
    done
}

#main ----
if [ -z $host_ip ]
then
    echo "please provide the host ip address, e.g. `basename $0` 10.66.10.63"
    exit 0
else
    echo "your host ip address is $host_ip"
fi
modprobe team
if [ `pidof teamd` ]
then
    teamd -t team0 -k
fi
teamd -t team0 -d -c \
    '{"runner" : {"name": "activebackup"}, "link_watch" : {"name": "ethtool"}}'
if [ $? -ne 0 ]
then
    echo "team0 is not created well"
    exit 12
fi
if [ `pidof dhclient` ]
then
    kill -9 `pidof dhclient`
fi
team_add
dhclient -v team0
ip -d link show 
teamdctl team0 state dump
team_ab &
ping_result=`ping $host_ip -c $ping_cnt |tail -2|head -1`
sleep 0.5
echo $ping_result
lost_ping=$(echo ${ping_result}|awk '{print $6}')
if [ $lost_ping = "0%" ];then
    echo "----***----"
    echo "No packets lost, the case is completed perfect!"
    echo "----***----"
else
    echo "!!!Current packet loss is $lost_ping,can not accept rather than 5% "
    exit 0
fi
sleep 3
if [ 'pidof teamd' ]
then
    teamd -t team0 -k
    echo "delete the team0"
fi
if [ 'pidof dhclient' ]
then
    kill -9 `pidof dhclient`
    dhclient -v eth0
fi

    

