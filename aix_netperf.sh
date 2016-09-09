#!/bin/sh
host_ip=$1
#times=30
timest=1
ndate=$(echo `date`|sed 's/[[:space:]]/\_/g')
tdir=/tmp/per_net$ndate
rdata=$tdir/rdata
rt=$rdata/rdata_final
mkdir -p $tdir
mkdir -p $rdata

#protos="TCP_RR TCP_CRR UDP_RR TCP_STREAM TCP_MAERTS TCP_SENDFILE UDP_STREAM"
protos1="TCP_STREAM TCP_MAERTS UDP_STREAM"
protos2="TCP_RR TCP_CRR UDP_RR"
psize1="64 256 1024 4096 16384 65507"
rrsize="1 4 8 32 64 128 256 512 1024"
breakc='inst'
bline=">.............................."

if [ $# -eq 0 ]
then
    echo "please provide the netserver_ip. e.g. `basename $0` 10.66.9.130 "
    exit 1
fi
platf=`uname -p`
if [ "$platf" = "x86_64" ]
then
    netperfpath=netperf
elif [ "$platf" = "powerpc" ]
then
    netperfpath=/usr/local/bin/netperf
fi

echo -e $bline
echo -e "After the script finished, get the result file as:\n$rt\n"
echo -e "PID of this script: $$"
echo -e "if want to interrupt the test, kill the pid $$, and kill all the netperf process\n"
echo -e "Script starting..."
echo -e $bline
for proto in $protos1
do
    echo $bline >>$rt
    echo -e "The final performance of $proto result is(Mbps):\n " >>$rt
    echo -e "Protocal\t\tSize\t\tThroughput\n" >>$rt
    for psize in $psize1
    do
        tfile=rs$proto$psize
        echo "test $proto with $psize (*kill PID $$ if you want*)"
        for i in $(seq 5)
        do
    	    $netperfpath -H $host_ip -l $timest -C -c -t $proto -- -m $psize>>$tdir/$tfile$breakc$i
            awk 'NR==7{print $5}' $tdir/$tfile$breakc$i >>$tdir/data_$tfile
	    sleep 1
        done
        dataall=`awk '{a=a+$1}END{print a}' $tdir/data_$tfile` 
        res=`echo "scale=2;$dataall/5"|bc`
        echo -e "$proto\t\t$psize\t\t$res" >>$rt
    done
done
for proto in $protos2
do 
    echo $bline >>$rt
    echo -e "The final performance of $proto result is(times/second)\n" >>$rt
    echo -e "Proto\t\tSize\t\tRsize\t\tTransRate\n" >>$rt
    for psize in $psize1
    do
        for rsize in $rrsize
        do
            tfile=rs$proto$psize$rsize
            echo "test $proto with $psize and RR size $rsize (*kill PID $$ if you want.)"
            for i in $(seq 5)
            do
                $netperfpath -H $host_ip -l $timest -C -c -t $proto -- -m $psize -r $rsize>>$tdir/$tfile$breakc$i
                awk 'NR==7{print $6}' $tdir/$tfile$breakc$i >>$tdir/data_$tfile
            done
            dataall=`awk '{a=a+$1}END{print a}' $tdir/data_$tfile`
            res=`echo "scale=2;$dataall/5"|bc`
            echo -e "$proto\t\t$psize\t\t$rsize\t\t$res" >>$rt
        done
    done
done
