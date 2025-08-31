

1.Настроить VPN между двумя ВМ в tun/tap режимах, замерить скорость в туннелях, сделать вывод об отличающихся показателях
2.Поднять RAS на базе OpenVPN с клиентскими сертификатами, 
подключиться с локальной машины на ВМ


1.

root@server:~# [  5]  39.00-40.00  sec  30.2 MBytes   253 Mbits/sec                  
[  5]  40.00-40.04  sec  1.19 MBytes   229 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-40.04  sec  1.34 GBytes   287 Mbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
^C

root@client:~# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  5] local 10.10.10.2 port 41792 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec   177 MBytes   296 Mbits/sec  355    755 KBytes       
[  5]   5.00-10.00  sec   175 MBytes   294 Mbits/sec  486    224 KBytes       
[  5]  10.00-15.00  sec   174 MBytes   292 Mbits/sec  134    307 KBytes       
[  5]  15.00-20.00  sec   175 MBytes   294 Mbits/sec    0    583 KBytes       
[  5]  20.00-25.00  sec   175 MBytes   294 Mbits/sec    0    765 KBytes       
[  5]  25.00-30.00  sec   174 MBytes   292 Mbits/sec   73    543 KBytes       
[  5]  30.00-35.00  sec   171 MBytes   287 Mbits/sec   62    381 KBytes       
[  5]  35.00-40.00  sec   154 MBytes   258 Mbits/sec  263    313 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec  1.34 GBytes   288 Mbits/sec  1373             sender
[  5]   0.00-40.04  sec  1.34 GBytes   287 Mbits/sec      


2.
 RAS на базе OpenVPN

root@server:/etc/openvpn/pki/private# ping -c 4 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.007 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.022 ms

root@Home:/etc/openvpn# netstat -rn
Таблица маршутизации ядра протокола IP
Destination Gateway Genmask Flags MSS Window irtt Iface
0.0.0.0         172.20.10.1     0.0.0.0         UG        0 0          0 enx2232c67017d7
172.20.10.0     0.0.0.0         255.255.255.240 U         0 0          0 enx2232c67017d7
192.168.56.0    0.0.0.0         255.255.255.0   U         0 0          0 vboxnet0
root@Home:/etc/openvpn# 