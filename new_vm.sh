#!/bin/bash
name=$1
vnc=$2
mac=$3
img=/home/$name
isport=`netstat -anp |grep 59$vnc`
if [ ! -d "img" ]
then
    cp /home/RF71_base.qcow2 $img
fi

