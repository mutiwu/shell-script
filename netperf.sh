#!/bin/sh
host_ip=$1
times=3
protos="TCP_RR TCP_CRR UDP_RR TCP_STREAM TCP_MAERTS TCP_SENDFILE UDP_STREAM"

if [ $# -eq 0 ]
then
    echo "please provide the netserver_ip. e.g. `basename $0` 10.66.9.130 "
    exit 1
fi
for proto in $protos
do
    echo "test $proto"
    netperf -H $host_ip -l $times -t $proto
    sleep 3
done
