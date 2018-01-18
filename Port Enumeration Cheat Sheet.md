
# NMAP Scan

**Single Host TCP Scan**
```
nmap -Pn -sS --stats-every 3m --max-retries 1 --max-scan-delay 20 --defeat-rst-ratelimit -T4 -p1-65535 -oA <$IP>T <$IP>
```
**Detailed Single Host Intense TCP Port Scan**
```
nmap -T1 -Pn -nvv -sSV --version-intensity 9 -p$(cat <$IP>T.xml | grep portid | grep protocol=\"tcp\" | cut -d'"' -f4 | paste -sd "," -)  -A -oA <$IP>T_DETAILED <$IP>
```


**Hidden Scan [Top 1000 Ports] - IF You think some ports are not showing up
```
nmap -sT -Pn <$IP> -vv -o hiddenscan.txt
```
Hidden - All Port Scan
```
nmap -sT -Pn <$IP> -vv  -p1-65535
```
Fast All Ports Scan
```
nmap -Pn -sS --stats-every 3m --max-retries 1 --max-scan-delay 20 --defeat-rst-ratelimit -T4 -p1-65535 -o fastportScan.txt <$IP>
```
Accurate Port Scan
```
nmap -Pn -n -sT -sV -O -vv <$IP> -p0-65535 
```
UDP Scan [Top 1000 Ports]
```
nmap -Pn  -sU -p1-65535 -o udpScan.txt --max-retries 1 --max-scan-delay 20 -T4 <$IP>
```

