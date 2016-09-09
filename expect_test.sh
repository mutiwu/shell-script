#!/bin/bash
expect <<!
spawn ssh root@172.16.236.152
expect "*password*"
send "teamsun\r"
expect "#"
send "/usr/local/bin/netperf -H 172.16.236.153 -l 10 >>sdf 2>&1\r" 

expect eof
!
