#!/bin/bash
expect <<!
spawn ssh root@172.16.136.28
expect "*password*"
send "teamsun\r"
expect "#"
send "ls\r"
expect eof
!
