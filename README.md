# Nutserver-Mikrotik
How to turn off the Mikrotik router from the Raspberry Pi if the battery level state is low.

First run the ```lsusb``` command. It will allow you to find out what device is connected through the USB port.

Then perform the below command to update repositories:

```sudo apt update```

Then we are going to install the NUT, NUT client and NUT server

```sudo apt install nut nut-client nut-server```

Next you can use a utility called a nut scanner to actually probe the UPS device and get some information from it so you can configure it a little bit easier.

```sudo nut-scanner -U```

You can see the result, so you can just copy and paste it into the notepad or make a note of it and you can use some of these values in your configuration.

The configuration is stored in /etc/nut/ups.conf
So let's edit this file

```nano /etc/nut/ups.conf```

and add at the end of the file:
```
pollinterval = 1
maxretry = 3

[blazer]
	driver = "blazer_usb"
	port = "auto"
	vendorid = "0665"
	productid = "5161"
	product = "USB to Serial"
	vendor = "INNO TECH"
	bus = "001"
        desc = "Blazer Room UPS"
        pollinterval = 5
        override.battery.voltage.low = 20.80
        override.battery.voltage.high = 26.00
        runtimecal = 390,100,780,50
        chargetime = 21600
        idleload = 10
        offdelay = 120
```

You can make a backup of this file or modify it.

I had to test some of these settings and read a NUT documentation that you can find it here: [NUT manual](https://networkupstools.org/docs/man/)

I had to change a little bit the ups.conf to be able to work with the mentioned UPS.

Then you have to edit the /etc/nut/upsmon.conf
```
nano /etc/nut/upsmon.conf
```
Add at the end of the file:
```
RUN_AS_USER root

MONITOR blazer@localhost 1 upsmon password master

MINSUPPLIES 1
SHUTDOWNCMD "/sbin/shutdown -h +0"
NOTIFYCMD /usr/sbin/upssched
POLLFREQ 2
POLLFREQALERT 1
HOSTSYNC 15
DEADTIME 15
POWERDOWNFLAG /etc/killpower

NOTIFYMSG ONLINE    "UPS %s on line power"
NOTIFYMSG ONBATT    "UPS %s on battery"
NOTIFYMSG LOWBATT   "UPS %s battery is low"
NOTIFYMSG FSD       "UPS %s: forced shutdown in progress"
NOTIFYMSG COMMOK    "Communications with UPS %s established"
NOTIFYMSG COMMBAD   "Communications with UPS %s lost"
NOTIFYMSG SHUTDOWN  "Auto logout and shutdown proceeding"
NOTIFYMSG REPLBATT  "UPS %s battery needs to be replaced"
NOTIFYMSG NOCOMM    "UPS %s is unavailable"
NOTIFYMSG NOPARENT  "upsmon parent process died - shutdown impossible"

NOTIFYFLAG ONLINE   SYSLOG+WALL+EXEC
NOTIFYFLAG ONBATT   SYSLOG+WALL+EXEC
NOTIFYFLAG LOWBATT  SYSLOG+WALL
NOTIFYFLAG FSD      SYSLOG+WALL+EXEC
NOTIFYFLAG COMMOK   SYSLOG+WALL+EXEC
NOTIFYFLAG COMMBAD  SYSLOG+WALL+EXEC
NOTIFYFLAG SHUTDOWN SYSLOG+WALL+EXEC
NOTIFYFLAG REPLBATT SYSLOG+WALL
NOTIFYFLAG NOCOMM   SYSLOG+WALL+EXEC
NOTIFYFLAG NOPARENT SYSLOG+WALL

RBWARNTIME 43200

NOCOMMWARNTIME 600

FINALDELAY 5
```

Edit /etc/nut/upsd.conf
```
nano /etc/nut/upsd.conf
```
Delete everything in the file and add this
```
# Network UPS Tools: example upsd configuration file
#
# This file contains access control data, you should keep it secure.
#
# It should only be readable by the user that upsd becomes.  See the FAQ.
#
# Each entry below provides usage and default value.

# =======================================================================
# MAXAGE <seconds>
MAXAGE 15
#
# This defaults to 15 seconds.  After a UPS driver has stopped updating
# the data for this many seconds, upsd marks it stale and stops making
# that information available to clients.  After all, the only thing worse
# than no data is bad data.
#
# You should only use this if your driver has difficulties keeping
# the data fresh within the normal 15 second interval.  Watch the syslog
# for notifications from upsd about staleness.

# =======================================================================
# STATEPATH <path>
# STATEPATH /var/run/nut
#
# Tell upsd to look for the driver state sockets in 'path' rather
# than the default that was compiled into the program.

# =======================================================================
# LISTEN <address> [<port>]
# LISTEN 127.0.0.1 3493
# LISTEN ::1 3493
LISTEN 0.0.0.0 3493
#
# This defaults to the localhost listening addresses and port 3493.
# In case of IP v4 or v6 disabled kernel, only the available one will be used.
#
# You may specify each interface you want upsd to listen on for connections,
# optionally with a port number.
#
# You may need this if you have multiple interfaces on your machine and
# you don't want upsd to listen to all interfaces (for instance on a
# firewall, you may not want to listen to the external interface).
#
# This will only be read at startup of upsd.  If you make changes here,
# you'll need to restart upsd, reload will have no effect.

# =======================================================================
# MAXCONN <connections>
# MAXCONN 1024
#
# This defaults to maximum number allowed on your system.  Each UPS, each
# LISTEN address and each client count as one connection.  If the server
# runs out of connections, it will no longer accept new incoming client
# connections.  Only set this if you know exactly what you're doing.

# =======================================================================
# CERTFILE <certificate file>
# CERTFILE /usr/local/ups/etc/upsd.pem
#
# When compiled with SSL support with OpenSSL backend,
# you can enter the certificate file here.
# The certificates must be in PEM format and must be sorted starting with
# the subject's certificate (server certificate), followed by intermediate
# CA certificates (if applicable_ and the highest level (root) CA. It should
# end with the server key. See 'docs/security.txt' or the Security chapter of
# NUT user manual for more information on the SSL support in NUT.
#
# See 'docs/security.txt' or the Security chapter of NUT user manual
# for more information on the SSL support in NUT.

# =======================================================================
# CERTPATH <certificate file or directory>
# CERTPATH /usr/local/ups/etc/cert/upsd
#
# When compiled with SSL support with NSS backend,
# you can enter the certificate path here.
# Certificates are stored in a dedicated database (splitted in 3 files).
# Specify the path of the database directory.
# 
# See 'docs/security.txt' or the Security chapter of NUT user manual
# for more information on the SSL support in NUT.

# =======================================================================
# CERTIDENT <certificate name> <database password>
# CERTIDENT "my nut server" "MyPasSw0rD"
#
# When compiled with SSL support with NSS backend,
# you can specify the certificate name to retrieve from database to
# authenticate itself and the password
# required to access certificate related private key.
# 
# See 'docs/security.txt' or the Security chapter of NUT user manual
# for more information on the SSL support in NUT.

# =======================================================================
# CERTREQUEST <certificate request level>
# CERTREQUEST REQUIRE
#
# When compiled with SSL support with NSS backend and client certificate
# validation (disabled by default, see 'docs/security.txt'),
# you can specify if upsd requests or requires client's' certificates.
# Possible values are :
#  - 0 to not request to clients to provide any certificate
#  - 1 to require to all clients a certificate
#  - 2 to require to all clients a valid certificate
# 
# See 'docs/security.txt' or the Security chapter of NUT user manual
# for more information on the SSL support in NUT.
```
Edit /etc/nut/nut.conf

``` nano /etc/nut/nut.conf ```

Add
```
MODE=netserver
```
Edit /etc/nut/upsd.users

``` nano /etc/nut/upsd.users ```

Add at the end of the file and change the password to what you like.
```
[upsmon]
   password = password
   upsmon master
```

Next steps for Mikrotik shutdown.
Generate the RSA Key using this command

``ssh-keygen -t rsa -b 2048``
Copy the id_rsa to /etc/nut or where ever you like the file to be. Make sure to change the path in the mikrotik.sh file. 

Copy the ```mikrotik.sh``` file to ```/etc/nut/``` folder.

Make it excutable using this command.
```
chmod +x /etc/nut/mikrotik.sh
```
Edit the mikrotik.sh file and put the right IP address of the mikrotik and id_rsa file location. Save the file. 
```
nano /etc/nut/mikrotik.sh
```
Edit file /etc/nut/upssched.conf and add the following.
```
CMDSCRIPT /etc/nut/upssched-cmd
PIPEFN /etc/nut/upssched.pipe
LOCKFN /etc/nut/upssched.lock

AT ONLINE * EXECUTE online
AT ONBATT * START-TIMER onbatt 30
AT ONLINE * CANCEL-TIMER onbatt online
AT ONBATT * START-TIMER mikrotik 3
AT ONLINE * CANCEL-TIMER mikrotik online
AT ONBATT * START-TIMER earlyshutdown 60
AT ONLINE * CANCEL-TIMER earlyshutdown
AT LOWBATT * START-TIMER shutdowncritical 300
AT ONLINE * CANCEL-TIMER shutdowncritical
AT LOWBATT * EXECUTE onbatt
AT COMMBAD * START-TIMER commbad 30
AT COMMOK * CANCEL-TIMER commbad commok
AT NOCOMM * EXECUTE commbad
AT REPLBATT * EXECUTE replacebatt
AT SHUTDOWN * EXECUTE powerdown
```
Create file named upssched-cmd under /etc/nut 
```
touch /etc/nut/upssched-cmd
```
Make it excutable using this command.
```
chmod +x /etc/nut/upssched-cmd
```
Edit file /etc/nut/upssched-cmd and add the following.
```
#!/bin/sh
#
# This script should be called by upssched via the CMDSCRIPT directive.
#
# This script may be replaced with another program without harm.
#
# The first argument passed to your CMDSCRIPT is the name of the timer
# from your AT lines.
#
# N.B. The $NOTIFYTYPE can be misleading so best to stick to AT event names

 case $1 in
       onbatt)
          logger -t upssched-cmd "UPS running on battery"
          ;;
       mikrotik)
          logger -t upssched-cmd "Shutting down Mikrotik"
          bash /etc/nut/mikrotik.sh
          ;;
       online)
          logger -t upssched-cmd "The UPS is back on power"
          ;;
       commbad)
       logger -t upssched-cmd "The server lost communication with UPS"
          ;;
       commok)
          logger -t upssched-cmd "The server re-establish communication with UPS"
          ;;
       earlyshutdown)
          logger -t upssched-cmd "UPS on battery too long, early shutdown"
          /usr/sbin/upsmon -c fsd
          ;;
       shutdowncritical)
          logger -t upssched-cmd "UPS on battery critical, forced shutdown"
          /usr/sbin/upsmon -c fsd
          ;;
       upsgone)
          logger -t upssched-cmd "UPS has been gone too long, can't reach"
          ;;
       replacebatt)
          logger -t upssched-cmd "The UPS needs new battery"
          ;;
       *)
          logger -t upssched-cmd "Unrecognized command: $1"
          ;;
 esac
```
Restart all the service and test
```
sudo service nut-server restart
sudo service nut-client restart
sudo systemctl restart nut-monitor
sudo upsdrvctl stop
sudo upsdrvctl start
```
Tail the syslog file.
```
tail /var/log/syslog

```
# Let's set up notification. 
I want to get a email when UPS losses power. I'll be using msmtp package. To install run

```
sudo apt-get install msmtp msmtp-mta mailutils
```
Create a file called msmtprc in /etc/
```
nano /etc/msmtprc
```
I will be using Office 365 for this. You can change few bits to use Outlook or gmail. Google and find the right info. 
```
account          default
host             smtp.office365.com
port             587
tls              on
tls_starttls     on
auth             on
user             ups@domain.com
password         password
from             ups@domain.com
logfile          /var/log/msmtp

```
The log file will fail so run this commands.
```
sudo touch /var/log/msmtp
sudo chown msmtp:msmtp /var/log/msmtp
sudo chmod 660 /var/log/msmtp
```
Let's test if email works. Run this replacing your email address.
```
echo "Subject: Test from the nut-server" | msmtp recipient@domain.com
```
If everything works we can do the next part in NUT config.

Edit your upssched.conf under /etc/nut and add the below.

```nano /etc/nut/upssched.conf```

```
CMDSCRIPT /etc/nut/upssched-cmd
PIPEFN /etc/nut/upssched.pipe
LOCKFN /etc/nut/upssched.lock

AT ONLINE * EXECUTE notifyonline
AT ONBATT * EXECUTE notifyoffline
AT ONLINE * EXECUTE online
AT ONBATT * START-TIMER onbatt 30
AT ONLINE * CANCEL-TIMER onbatt online
AT ONBATT * START-TIMER mikrotik 50
AT ONLINE * CANCEL-TIMER mikrotik online
AT ONBATT * START-TIMER earlyshutdown 60
AT ONLINE * CANCEL-TIMER earlyshutdown
AT LOWBATT * START-TIMER shutdowncritical 300
AT ONLINE * CANCEL-TIMER shutdowncritical
AT LOWBATT * EXECUTE onbatt
AT COMMBAD * START-TIMER commbad 30
AT COMMOK * CANCEL-TIMER commbad commok
AT NOCOMM * EXECUTE commbad
AT REPLBATT * EXECUTE replacebatt
AT SHUTDOWN * EXECUTE powerdown
```
Let's create file called notifycmd.sh under /etc/nut/. 
```
nano /etc/nut/notifycmd.sh
```
Add this to the file. Change the ups@domain.com to your proper email.
```
#!/bin/bash
EMAIL='ups@domain.com'
echo -e "Subject: UPS ALERT: $NOTIFYTYPE\n\nUPS: $UPSNAME\r\nAlert type: $NOTIFYTYPE\n\n\nUPS: Blazer Room UPS" | msmtp $EMAIL
```
Change the group and add execution to the file notifycmd.sh.

```
# Change group to nut
sudo chown :nut /etc/nut/notifycmd.sh
# Add execution
sudo chmod 774 /etc/nut/notifycmd.sh
```

Edit file upssched-cmd under /etc/nut

```nano /etc/nut/upssched-cmd```

```
#!/bin/sh
#
# This script should be called by upssched via the CMDSCRIPT directive.
#
# This script may be replaced with another program without harm.
#
# The first argument passed to your CMDSCRIPT is the name of the timer
# from your AT lines.
#
# N.B. The $NOTIFYTYPE can be misleading so best to stick to AT event names

 case $1 in
       notifyonline)
          logger -t upssched-cmd "Notify UPS running online power"
          bash /etc/nut/notifycmd.sh
          ;;
       notifyoffline)
          logger -t upssched-cmd "Notify UPS running on battery"
          bash /etc/nut/notifycmd.sh
          ;;
       onbatt)
          logger -t upssched-cmd "UPS running on battery"
          ;;
       mikrotik)
          logger -t upssched-cmd "Shutting down Mikrotik"
          bash /etc/nut/mikrotik.sh
          ;;
       online)
          logger -t upssched-cmd "The UPS is back on power"
          ;;
       commbad)
       logger -t upssched-cmd "The server lost communication with UPS"
          ;;
       commok)
          logger -t upssched-cmd "The server re-establish communication with UPS"
          ;;
       earlyshutdown)
          logger -t upssched-cmd "UPS on battery too long, early shutdown"
          /usr/sbin/upsmon -c fsd
          ;;
       shutdowncritical)
          logger -t upssched-cmd "UPS on battery critical, forced shutdown"
          /usr/sbin/upsmon -c fsd
          ;;
       upsgone)
          logger -t upssched-cmd "UPS has been gone too long, can't reach"
          ;;
       replacebatt)
          logger -t upssched-cmd "The UPS needs new battery"
          ;;
       powerdown)
          logger -t upssched-cmd "Shutting down Machine"
          bash /etc/nut/notifycmd.sh
          ;;
       *)
          logger -t upssched-cmd "Unrecognized command: $1"
          ;;
 esac
```

Restart the NUT services
```
sudo systemctl restart nut-server.service
sudo systemctl restart nut-driver.service
sudo systemctl restart nut-monitor.service
```
Test by switching off the power and you should get emails about it. 

Enjoy. 



