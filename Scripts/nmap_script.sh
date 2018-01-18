#!/bin/bash

function usage(){
  echo "Usage: $0 <ip> <menu number>"
  echo "        1. Single Host TCP Scan [T] " #Appends file with T, H, HA etc
  echo "        2. Hidden Scan [Top 1000 Ports] - IF You think some ports are not showing up [H]"
  echo "        3. Hidden - All Port Scan [HA]"
  echo "        4. Fast All Ports Scan [FA]"
  echo "        5. Accurate Port Scan [AC]"
  echo "        6. UDP Scan [Top 1000 Ports] [U]"

}

if [ $# -ne 2 ]; then
  	usage
	exit;
fi

ipaddress=$1

shift

menu=$1
if [ $menu = "1" ]; 
then
	nmap -Pn -sS --stats-every 3m --max-retries 1 --max-scan-delay 20 --defeat-rst-ratelimit -T4 -p1-65535 -oA $ipaddress"T" $ipaddress
	exit;	
elif [ $menu = "2" ]
then
	nmap -sT -Pn $ipaddress -oA $ipaddress"H" $ipaddress
	exit 0;

elif [ $menu = "3" ]
then
	nmap -sT -Pn -oA $ipaddress"HA" $ipaddress -vv  -p1-65535
	exit 0;

elif [ $menu = "4" ]
then
        nmap -Pn -sS --stats-every 3m --max-retries 1 --max-scan-delay 20 --defeat-rst-ratelimit -T4 -p1-65535 -oA $ipaddress"FA" $ipaddress
	exit 0;

elif [ $menu = "5" ]
then
        
	nmap -Pn -n -sT -sV -O -vv -oA $ipaddress"AC" $ipaddress -p0-65535 
	exit 0;

elif [ $menu = "6" ]
then

        nmap -Pn  -sU -p1-65535 -oA $ipaddress"U" --max-retries 1 --max-scan-delay 20 -T4 $ipaddress
	exit 0;


else
	usage
	exit 0;
fi

exit;
