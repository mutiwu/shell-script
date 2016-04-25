#!/bin/bash

ttime=5
inst=$1
proto=$2
psize=$3
tfile=rs$inst$proto$psize
ndate=$(echo `date`|sed 's/[[:space:]]/\_/g')
tdir=/tmp/per_net$ndate
mkdir -p $tdir

for ((c=1; c<=5; c++))
do
    echo "start" $c
    for ((i=1; i<=$inst; i++))
    do
        taskset -c $i netperf -H 172.30.132.70 -l $ttime -C -c -t $proto -- -m $psize >>$tdir/$tfile$c &
    done
    let fst=$ttime+1
    sleep $fst
    echo "end" $c
done
sleep 2
grep -h  '^[[:space:]][[:digit:]]*' $tdir/$tfile* >> $tdir/data_$tfile
grep -c "" $tdir/data_$tfile
echo "end"
