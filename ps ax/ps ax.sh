#!/bin/bash
echo " PID | TTY | STAT | COMM"

for pid in $(ls -l /proc | awk '{print $9}' | grep "^[0-9]*[0-9]$"| sort -n );
do

tty=$(cat 2>/dev/null /proc/$pid/stat | awk '{print $7}')
stat=$(cat 2>/dev/null /proc/$pid/stat | awk '{print $3}')
comm=$(cat 2>/dev/null /proc/$pid/comm | tr -d '\0' | awk '{print $0}')


printf "$pid | $tty | $stat | $comm" | column -t -s '|'
done
