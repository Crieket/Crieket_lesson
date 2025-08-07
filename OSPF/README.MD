
Описание домашнего задания
1. Развернуть 3 виртуальные машины
Vagrant UP

 ---настроить OSPF между машинами на базе frr


root@router1:~# vtysh 

Hello, this is FRRouting (version 8.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router1# show interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
enp0s3          up      default         10.0.2.15/24
enp0s8          up      default         10.0.10.1/30
enp0s9          up      default         10.0.12.1/30
enp0s10         up      default         192.168.10.1/24
lo              up      default         


router2# show interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
enp0s3          up      default         10.0.2.15/24
enp0s8          up      default         10.0.10.2/30
enp0s9          up      default         10.0.11.2/30
enp0s10         up      default         192.168.20.1/24
lo              up      default         

router3# show interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
enp0s3          up      default         10.0.2.15/24
enp0s8          up      default         10.0.11.1/30
enp0s9          up      default         10.0.12.2/30
enp0s10         up      default         192.168.30.1/24
lo              up      default         

R1
root@router1:~# tcpdump -i enp0s8 
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:39:20.378409 IP 10.0.10.2 > ospf-all.mcast.net: OSPFv2, Hello, length 44
18:39:23.616371 IP router1 > ospf-all.mcast.net: OSPFv2, Hello, length 44

R2
oot@router2:~# tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:38:30.261011 IP router2 > ospf-all.mcast.net: OSPFv2, Hello, length 44
18:38:33.626578 IP 10.0.10.1 > ospf-all.mcast.net: OSPFv2, Hello, length 44
18:38:40.275312 IP router2 > ospf-all.mcast.net: OSPFv2, Hello, 

R3
oot@router3:~# tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:39:02.757353 IP router3 > ospf-all.mcast.net: OSPFv2, Hello, length 44
18:39:10.396920 IP 10.0.11.2 > ospf-all.mcast.net: OSPFv2, Hello, length 44
18:39:12.757501 IP router3 > ospf-all.mcast.net: OSPFv2, Hello, length 44

 


Ассиметричый роутинг

Конфигурация ассимитричной маршрутизации выполняется параметром ip ospf cost 1000 (файл /etc/frr/frr.conf) на router1 в направлении router2.

oot@router2:~# tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:46:44.603231 IP router2 > 192.168.10.1: ICMP echo reply, id 13, seq 72, length 64
19:46:44.723992 IP 10.0.10.1 > ospf-all.mcast.net: OSPFv2, Hello, length 48
19:46:45.626898 IP router2 > 192.168.10.1: ICMP echo reply, id 13, seq 73, length 64


root@router2:~# tcpdump -i enp0s9
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s9, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:45:39.066832 IP 192.168.10.1 > router2: ICMP echo request, id 13, seq 8, length 64
19:45:40.090947 IP 192.168.10.1 > router2: ICMP echo request, id 13, seq 9, length 64
19:45:41.114748 IP 192.168.10.1 > router2: ICMP echo request, id 13, seq 10, length 64




root@router1:~# vtysh 

Hello, this is FRRouting (version 8.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router1# show ip route ospf 
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

O   10.0.10.0/30 [110/300] via 10.0.12.2, enp0s9, weight 1, 00:00:45
O>* 10.0.11.0/30 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:00:52
O   10.0.12.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:32:37
O   192.168.10.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:32:37
O>* 192.168.20.0/24 [110/300] via 10.0.12.2, enp0s9, weight 1, 00:00:45
O>* 192.168.30.0/24 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:00:52

router2# show ip  route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

C>* 10.0.2.0/24 [0/100] is directly connected, enp0s3, 00:03:03
K>* 10.0.2.3/32 [0/100] is directly connected, enp0s3, 00:03:03
O   10.0.10.0/30 [110/100] is directly connected, enp0s8, weight 1, 00:03:00
C>* 10.0.10.0/30 is directly connected, enp0s8, 00:03:03
O   10.0.11.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:03:03
C>* 10.0.11.0/30 is directly connected, enp0s9, 00:03:03
O>* 10.0.12.0/30 [110/200] via 10.0.10.1, enp0s8, weight 1, 00:02:08
  *                        via 10.0.11.1, enp0s9, weight 1, 00:02:08
O>* 192.168.10.0/24 [110/200] via 10.0.10.1, enp0s8, weight 1, 00:02:50
O   192.168.20.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:03:03
C>* 192.168.20.0/24 is directly connected, enp0s10, 00:03:03
O>* 192.168.30.0/24 [110/200] via 10.0.11.1, enp0s9, weight 1, 00:02:08





Симметричный роутинг
Конфигурация симметричной маршрутизации выполняется параметром ip ospf cost 1000 (файл /etc/frr/frr.conf) на router2 в направлении router1.

outer2# show ip route ospf 
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

O   10.0.10.0/30 [110/1000] is directly connected, enp0s8, weight 1, 00:09:39
O   10.0.11.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:21:23
O>* 10.0.12.0/30 [110/200] via 10.0.11.1, enp0s9, weight 1, 00:09:39
O>* 192.168.10.0/24 [110/300] via 10.0.11.1, enp0s9, weight 1, 00:09:39
O   192.168.20.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:21:23
O>* 192.168.30.0/24 [110/200] via 10.0.11.1, enp0s9, weight 1, 00:20:28

router2# exit
root@router2:~# tcpdump -i enp0s9
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s9, link-type EN10MB (Ethernet), snapshot length 262144 bytes
20:01:11.933278 IP 192.168.10.1 > router2: ICMP echo request, id 14, seq 247, length 64
20:01:11.933295 IP router2 > 192.168.10.1: ICMP echo reply, id 14, seq 247, length 64
20:01:12.957519 IP 192.168.10.1 > router2: ICMP echo request, id 14, seq 248, length 64
20:01:12.957535 IP router2 > 192.168.10.1: ICMP echo reply, id 14, seq 248, length 64
20:01:13.981374 IP 192.168.10.1 > router2: ICMP echo request, id 14, seq 249, length 64
20:01:13.981390 IP router2 > 192.168.10.1: ICMP echo reply, id 14, seq 249, length 64
20:01:14.355537 IP 10.0.11.1 > ospf-all.mcast.net: OSPFv2, Hello, length 48
20:01:14.355930 IP router2 > ospf-all.mcast.net: OSPFv2, Hello, length 48
20:01:15.005500 IP 192.168.10.1 > router2: ICMP echo request, id 14, seq 250, length 64
20:01:15.005514 IP router2 > 192.168.10.1: ICMP echo reply, id 14, seq 250, length 64
