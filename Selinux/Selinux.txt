selinux

установил утилиты для работы с selinux

yum install policycoreutils-python setroubleshoot

ЗАДАНИЕ 1.

Запуск nginx на нестандартном порту 3-мя разными способам

1. способ

[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@selinux ~]# getenforce
Enforcing

[root@selinux ~]# systemctl start nginx
Job for nginx.service failed because the control process exited with error code.     
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.

[root@selinux ~]# grep 1748006296.523:356 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1748006296.523:356): avc:  denied  { name_bind } for  pid=2086 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly.
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
[root@selinux ~]# setsebool -P nis_enabled 1
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Fri 2025-05-23 13:30:15 UTC; 7s ago
    Process: 2128 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2129 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 2130 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 2132 (nginx)
      Tasks: 3 (limit: 12026)
     Memory: 2.9M
        CPU: 26ms
     CGroup: /system.slice/nginx.service
             ├─2132 "nginx: master process /usr/sbin/nginx"
             ├─2133 "nginx: worker process"
             └─2134 "nginx: worker process"

May 23 13:30:15 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
May 23 13:30:15 selinux nginx[2129]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
May 23 13:30:15 selinux nginx[2129]: nginx: configuration file /etc/nginx/nginx.conf test is successful
May 23 13:30:15 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
[root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> on


clear2 способ.
Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:


× nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: failed (Result: exit-code) since Fri 2025-05-23 13:46:06 UTC; 2s ago
   Duration: 15min 50.939s
    Process: 2154 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2156 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
        CPU: 14ms

May 23 13:46:06 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
May 23 13:46:06 selinux nginx[2156]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
May 23 13:46:06 selinux nginx[2156]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)      
May 23 13:46:06 selinux nginx[2156]: nginx: configuration file /etc/nginx/nginx.conf test failed
May 23 13:46:06 selinux systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE       
May 23 13:46:06 selinux systemd[1]: nginx.service: Failed with result 'exit-code'.
May 23 13:46:06 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
[root@selinux ~]# 
[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http_port_t
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988

[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Fri 2025-05-23 13:55:42 UTC; 7s ago
    Process: 2185 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2186 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 2188 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 2189 (nginx)
      Tasks: 3 (limit: 12026)
     Memory: 2.9M
        CPU: 23ms
     CGroup: /system.slice/nginx.service
             ├─2189 "nginx: master process /usr/sbin/nginx"
             ├─2190 "nginx: worker process"
             └─2191 "nginx: worker process"

May 23 13:55:42 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
May 23 13:55:42 selinux nginx[2186]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
May 23 13:55:42 selinux nginx[2186]: nginx: configuration file /etc/nginx/nginx.conf test is successful        
May 23 13:55:42 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.

[root@selinux ~]# semanage port -d -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988


3 способ

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:

[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
[root@selinux ~]# systemctl status nginx
× nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: failed (Result: exit-code) since Fri 2025-05-23 14:18:49 UTC; 3s ago
   Duration: 23min 7.136s
    Process: 2229 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2232 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
        CPU: 14ms

May 23 14:18:49 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
May 23 14:18:49 selinux nginx[2232]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
May 23 14:18:49 selinux nginx[2232]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)      
May 23 14:18:49 selinux nginx[2232]: nginx: configuration file /etc/nginx/nginx.conf test failed
May 23 14:18:49 selinux systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE       
May 23 14:18:49 selinux systemd[1]: nginx.service: Failed with result 'exit-code'.
May 23 14:18:49 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.

ype=AVC msg=audit(1748009929.614:385): avc:  denied  { name_bind } for  pid=2232 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0  
type=SYSCALL msg=audit(1748009929.614:385): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=55a8a586fff0 a2=10 a3=7ffe42f80990 items=0 ppid=1 pid=2232 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null
ARCH=x86_64 SYSCALL=bind AUID="unset" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
type=SERVICE_START msg=audit(1748009929.619:386): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'UID="root" AUID="unset"
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp

[root@selinux ~]# semodule -i nginx.pp 
[root@selinux ~]# systemctl start nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Fri 2025-05-23 14:24:56 UTC; 6s ago
    Process: 2263 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2264 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 2265 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 2267 (nginx)
      Tasks: 3 (limit: 12026)
     Memory: 2.9M
        CPU: 22ms
     CGroup: /system.slice/nginx.service
             ├─2267 "nginx: master process /usr/sbin/nginx"
             ├─2268 "nginx: worker process"
             └─2269 "nginx: worker process"

May 23 14:24:56 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
May 23 14:24:56 selinux nginx[2264]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
May 23 14:24:56 selinux nginx[2264]: nginx: configuration file /etc/nginx/nginx.conf test is successful      M
May 23 14:24:56 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.

[root@selinux ~]# semodule -l
...
nginx
...

ЗАДАНИЕ 2.

[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
server 192.168.50.10
zone ddns.lab
update add www.ddns.lab. 60 A 192.168.50.15
send
update failed: SERVFAIL
quit

[vagrant@client ~]$ sudo grep denied /var/log/audit/audit.log
[vagrant@client ~]$ sudo iptables -L -n -v
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
[vagrant@client ~]$

[vagrant@ns01 ~]$ sudo iptables -vnL
Chain INPUT (policy ACCEPT 969 packets, 88081 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 706 packets, 82590 bytes)
 pkts bytes target     prot opt in     out     source               destination


[vagrant@ns01 ~]$ sudo grep denied /var/log/audit/audit.log
type=AVC msg=audit(1708973761.804:1959): avc:  denied  { create } for  pid=5326 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

[root@ns01 vagrant]# chcon -R -t named_zone_t /etc/named
[root@ns01 vagrant]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:named_zone_t:s0 .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
[root@ns01 vagrant]#

[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
server 192.168.50.10
zone ddns.lab
update add www.ddns.lab. 60 A 192.168.50.15
send
quit
[vagrant@client ~]$ nslookup www.ddns.lab
Server:192.168.50.10
Address:192.168.50.10#53

Name:	www.ddns.lab
Address: 192.168.50.15

[vagrant@client ~]$ nslookup www.ddns.lab
Server:10.0.2.3
Address:10.0.2.3#53

** server can't find www.ddns.lab: NXDOMAIN
[vagrant@client ~]$ cat /etc/resolv.conf
# Generated by NetworkManager
search mshome.net
nameserver 10.0.2.3

[vagrant@client ~]$ sudo  vi /etc/resolv.conf
[vagrant@client ~]$ cat /etc/resolv.conf
# Generated by NetworkManager
search mshome.net
nameserver 192.168.50.10
[vagrant@client ~]$ nslookup www.ddns.lab
Server:192.168.50.10
Address:192.168.50.10#53

Name:www.ddns.lab
Address: 192.168.50.1
