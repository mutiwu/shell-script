#!/bin/bash
ndate=$(echo `date`|sed 's/[[:space:]]/\_/g')
tdir=/tmp/fio_$ndate
mkdir -p $tdir
printf "RW\tbs\tiodepth\tBW\t\tIOPS\t\t\n">>$tdir/FINAL_DATA
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
	    bw_rs=`cut -d ':' $tdir/$f/merg_$f$b$d -f 2 | cut -d ',' -f 2 |cut -d '=' -f 2 |awk -F K '{print $1}' |awk '{sum += $1};END {print sum/5}'`
	    iops_rs=`cut -d ':' $tdir/$f/merg_$f$b$d -f 2 | cut -d ',' -f 3 |cut -d '=' -f 2 |awk -F K '{print $1}' |awk '{sum += $1};END {print sum/5}'`
	    printf "$f\t$b\t$d\t$bw_rs\t\t$iops_rs\t\t\n">>$tdir/FINAL_DATA
        done
    done
done
