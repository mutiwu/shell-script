#!/bin/bash

ip=$1
while [ $? -eq 0 ]
do
    ping $ip -c 1 >> /tmp/pinglog.log
done
echo "*******************************"
echo "*                             *"
echo "* ping failed at time:        *"
echo "* "`date|tee /tmp/pingdate.txt`" *"
echo "*                             *"
echo "*******************************"
