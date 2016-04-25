#!/bin/bash
ndate=$(echo `date`|sed 's/[[:space:]]/\_/g')
tdir=/tmp/fio_$ndate
mkdir -p $tdir
for f in seq_r seq_w rand_r rand_w
do
rdir=$tdir/$f/crs

    for b in 4k 16k 64k 256k
    do
        for d in 1 8 64
        do
	    crsdir=$rdir/$b$d
	    mkdir -p $crsdir
            for ((i=1; i<=5; i++))
            do
                fio $f\.ini --bs=$b --iodepth=$d --output=$crsdir/fio_rs_$f$b$d$i
            done
	    grep -h '^[[:space:]].*io\=.*bw\=.*iops\=' $crsdir/fio_rs_$f$b$d* >>$tdir/$f/merg_$f$b$d
        done
    done
done
