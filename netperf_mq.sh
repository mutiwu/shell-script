#!/bin/sh 
ins=$1
server=$2
ntime=$3
if [ $# -eq 0 ]
then
    echo "please provide the netperf instance numbers, \
    netserver_ip, and netperf last times\
    e.g. `basename $0` 12 10.66.9.130 120"
    exit 1
fi

for i in `seq $ins`
do
    netperf -H $server -l $ntime &
    echo "start netperf: $i"
done
