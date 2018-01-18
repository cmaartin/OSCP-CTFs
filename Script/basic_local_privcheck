#!/usr/env python

###############################################################################################################
## [Author]: Mike Czumak (T_v3rn1x) -- @SecuritySift
## MODIFIED BY cmaartin to make it basic


# conditional import for older versions of python not compatible with subprocess
try:
    import subprocess as sub
    compatmode = 0 # newer version of python, no need for compatibility mode
except ImportError:
    import os # older version of python, need to use os instead
    compatmode = 1

# title / formatting
bigline = "================================================================================================="
smlline = "-------------------------------------------------------------------------------------------------"

print bigline 
print "LINUX PRIVILEGE ESCALATION CHECKER"
print bigline
print

# loop through dictionary, execute the commands, store the results, return updated dict
def execCmd(cmdDict):
    for item in cmdDict:
        cmd = cmdDict[item]["cmd"]
	if compatmode == 0: # newer version of python, use preferred subprocess
            out, error = sub.Popen([cmd], stdout=sub.PIPE, stderr=sub.PIPE, shell=True).communicate()
            results = out.split('\n')
	else: # older version of python, use os.popen
	    echo_stdout = os.popen(cmd, 'r')  
            results = echo_stdout.read().split('\n')
        cmdDict[item]["results"]=results
    return cmdDict

# print results for each previously executed command, no return value
def printResults(cmdDict):
    for item in cmdDict:
	msg = cmdDict[item]["msg"]
	results = cmdDict[item]["results"]
        print "[+] " + msg
        for result in results:
	    if result.strip() != "":
	        print "    " + result.strip()
	print
    return

def writeResults(msg, results):
    f = open("privcheckout.txt", "a");
    f.write("[+] " + str(len(results)-1) + " " + msg)
    for result in results:
        if result.strip() != "":
            f.write("    " + result.strip())
    f.close()
    return

# Basic system info
print "[*] GETTING BASIC SYSTEM INFO...\n"

results=[]

sysInfo = {"OS":{"cmd":"cat /etc/issue","msg":"Operating System","results":results}, 
	   "KERNEL":{"cmd":"cat /proc/version","msg":"Kernel","results":results}, 
	   "HOSTNAME":{"cmd":"hostname", "msg":"Hostname", "results":results}
	  }

sysInfo = execCmd(sysInfo)
printResults(sysInfo)

# Networking Info

print "[*] GETTING NETWORKING INFO...\n"

netInfo = {"NETINFO":{"cmd":"/sbin/ifconfig -a", "msg":"Interfaces", "results":results},
	   "ROUTE":{"cmd":"route", "msg":"Route", "results":results},
	   "NETSTAT":{"cmd":"netstat -antup | grep -v 'TIME_WAIT'", "msg":"Netstat", "results":results}
	  }

netInfo = execCmd(netInfo)
printResults(netInfo)

# File System Info
print "[*] GETTING FILESYSTEM INFO...\n"

driveInfo = {"MOUNT":{"cmd":"mount","msg":"Mount results", "results":results},
	     "FSTAB":{"cmd":"cat /etc/fstab 2>/dev/null", "msg":"fstab entries", "results":results}
	    }

driveInfo = execCmd(driveInfo)
printResults(driveInfo)

# Scheduled Cron Jobs
cronInfo = {"CRON":{"cmd":"ls -la /etc/cron* 2>/dev/null", "msg":"Scheduled cron jobs", "results":results},
	    "CRONW": {"cmd":"ls -aRl /etc/cron* 2>/dev/null | awk '$1 ~ /w.$/' 2>/dev/null", "msg":"Writable cron dirs", "results":results}
	   }

cronInfo = execCmd(cronInfo)
printResults(cronInfo)

# User Info
print "\n[*] ENUMERATING USER AND ENVIRONMENTAL INFO...\n"

userInfo = {"WHOAMI":{"cmd":"whoami", "msg":"Current User", "results":results},
	    "ID":{"cmd":"id","msg":"Current User ID", "results":results},
	    "ALLUSERS":{"cmd":"cat /etc/passwd", "msg":"All users", "results":results},
	    "SUPUSERS":{"cmd":"grep -v -E '^#' /etc/passwd | awk -F: '$3 == 0{print $1}'", "msg":"Super Users Found:", "results":results},
	    "HISTORY":{"cmd":"ls -la ~/.*_history; ls -la /root/.*_history 2>/dev/null", "msg":"Root and current user history (depends on privs)", "results":results},
	    "ENV":{"cmd":"env 2>/dev/null | grep -v 'LS_COLORS'", "msg":"Environment", "results":results},
	    "SUDOERS":{"cmd":"cat /etc/sudoers 2>/dev/null | grep -v '#' 2>/dev/null", "msg":"Sudoers (privileged)", "results":results},
	    "LOGGEDIN":{"cmd":"w 2>/dev/null", "msg":"Logged in User Activity", "results":results}
	   }

userInfo = execCmd(userInfo)
printResults(userInfo)

if "root" in userInfo["ID"]["results"][0]:
    print "[!] ARE YOU SURE YOU'RE NOT ROOT ALREADY?\n"

# File/Directory Privs
print "[*] ENUMERATING FILE AND DIRECTORY PERMISSIONS/CONTENTS...\n"

fdPerms = {"WWDIRSROOT":{"cmd":"find / \( -wholename '/home/homedir*' -prune \) -o \( -type d -perm -0002 \) -exec ls -ld '{}' ';' 2>/dev/null | grep root", "msg":"World Writeable Directories for User/Group 'Root'", "results":results},
	   "WWDIRS":{"cmd":"find / \( -wholename '/home/homedir*' -prune \) -o \( -type d -perm -0002 \) -exec ls -ld '{}' ';' 2>/dev/null | grep -v root", "msg":"World Writeable Directories for Users other than Root", "results":results},
	   "WWFILES":{"cmd":"find / \( -wholename '/home/homedir/*' -prune -o -wholename '/proc/*' -prune \) -o \( -type f -perm -0002 \) -exec ls -l '{}' ';' 2>/dev/null", "msg":"World Writable Files", "results":results},
	   "SUID":{"cmd":"find / \( -perm -2000 -o -perm -4000 \) -exec ls -ld {} \; 2>/dev/null", "msg":"SUID/SGID Files and Directories", "results":results},
	   "ROOTHOME":{"cmd":"ls -ahlR /root 2>/dev/null", "msg":"Checking if root's home folder is accessible", "results":results}
	  }

fdPerms = execCmd(fdPerms) 
printResults(fdPerms)

pwdFiles = {"LOGPWDS":{"cmd":"find /var/log -name '*.log' 2>/dev/null | xargs -l10 egrep 'pwd|password' 2>/dev/null", "msg":"Logs containing keyword 'password'", "results":results},
	    "CONFPWDS":{"cmd":"find /etc -name '*.c*' 2>/dev/null | xargs -l10 egrep 'pwd|password' 2>/dev/null", "msg":"Config files containing keyword 'password'", "results":results},
	    "SHADOW":{"cmd":"cat /etc/shadow 2>/dev/null", "msg":"Shadow File (Privileged)", "results":results}
	   }

pwdFiles = execCmd(pwdFiles)
printResults(pwdFiles)

# First discover the avaialable tools 
print
print "[*] ENUMERATING INSTALLED LANGUAGES/TOOLS FOR SPLOIT BUILDING...\n"

devTools = {"TOOLS":{"cmd":"which awk perl python ruby gcc cc vi vim nmap find netcat nc wget tftp ftp 2>/dev/null", "msg":"Installed Tools", "results":results}}
devTools = execCmd(devTools)
printResults(devTools)


print 	
print "Finished"
print bigline
