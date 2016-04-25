#!/bin/bash

ostate=up
iface=$1
r_ostate=up
while [ $r_ostate = $ostate ]
do
    r_ostate=$(cat /sys/class/net/$iface/operstate)
echo $r_ostate >>/tmp/state
done
echo "!!!warning:"
echo "********************************************************"
echo "* Interface $iface unpluged, the time be unpluged is:"
echo "* "`date |tee /tmp/date_state`
echo "********************************************************"
