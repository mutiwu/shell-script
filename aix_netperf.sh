#!/bin/sh
host_ip=$1
#timest=30
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
    if [ "$proto" = "UDP_STREAM" ]
    then
        echo -e "Protocal\t\tSize\t\tTXThroughput\t\tRemoteRXThroughput\n" >>$rt
    else
        echo -e "Protocal\t\tSize\t\tThroughput\n" >>$rt
    fi
    for psize in $psize1
    do
        tfile=rs$proto$psize
        echo "test $proto with $psize (*kill PID $$ if you want*)"
        for i in $(seq 5)
        do
    	    $netperfpath -H $host_ip -l $timest -C -c -t $proto -- -m $psize>>$tdir/$tfile$breakc$i
            if [ "$proto" = "UDP_STREAM" ]
            then
                awk 'NR==6{print $6}' $tdir/$tfile$breakc$i >>$tdir/datau_$tfile
                awk 'NR==7{print $4}' $tdir/$tfile$breakc$i >>$tdir/data_$tfile
            else
                awk 'NR==7{print $5}' $tdir/$tfile$breakc$i >>$tdir/data_$tfile
            fi
	    sleep 1
        done
        dataall=`awk '{a=a+$1}END{print a}' $tdir/data_$tfile` 
        res=`echo "scale=2;$dataall/5"|bc`
        if [ "$proto" = "UDP_STREAM" ]
        then
            datau=`awk '{a=a+$1}END{print a}' $tdir/datau_$tfile`
            resu=`echo "scale=2;$datau/5"|bc`
            echo -e "$proto\t\t$psize\t\t$resu\t\t$res" >>$rt
        else
            echo -e "$proto\t\t$psize\t\t$res" >>$rt
        fi
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

