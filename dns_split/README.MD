1.
Взять стенд 
добавить еще один сервер client2
завести в зоне dns.lab имена:
web1 - смотрит на клиент1
web2  смотрит на клиент2
завести еще одну зону newdns.lab
завести в ней запись
www - смотрит на обоих клиентов

2. 
Настроить split-dns

клиент1 - видит обе зоны, но в зоне dns.lab только web1

[vagrant@client1 ~]$ ping www.newdns.lab
PING www.newdns.lab (192.168.56.15) 56(84) bytes of data.
64 bytes from client1 (192.168.56.15): icmp_seq=1 ttl=64 time=0.035 ms
64 bytes from client1 (192.168.56.15): icmp_seq=2 ttl=64 time=0.090 ms
64 bytes from client1 (192.168.56.15): icmp_seq=3 ttl=64 time=0.090 ms
64 bytes from client1 (192.168.56.15): icmp_seq=4 ttl=64 time=0.091 ms
^C
--- www.newdns.lab ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 0.035/0.076/0.091/0.023 ms
[vagrant@client1 ~]$ ping web1.dns.lab
PING web1.dns.lab (192.168.56.15) 56(84) bytes of data.
64 bytes from client1 (192.168.56.15): icmp_seq=1 ttl=64 time=0.007 ms
64 bytes from client1 (192.168.56.15): icmp_seq=2 ttl=64 time=0.091 ms
64 bytes from client1 (192.168.56.15): icmp_seq=3 ttl=64 time=0.079 ms
64 bytes from client1 (192.168.56.15): icmp_seq=4 ttl=64 time=0.089 ms
^C
--- web1.dns.lab ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 0.007/0.066/0.091/0.034 ms
[vagrant@client1 ~]$ ping web2.dns.lab
ping: web2.dns.lab: Name or service not known
[vagrant@client1 ~]$ 


клиент2 видит только dns.lab
[vagrant@client2 ~]$ ping www.newdns.lab
ping: www.newdns.lab: Name or service not known

[vagrant@client2 ~]$ ping web1.dns.lab
PING web1.dns.lab (192.168.56.15) 56(84) bytes of data.
64 bytes from 192.168.56.15 (192.168.56.15): icmp_seq=1 ttl=64 time=1.40 ms
64 bytes from 192.168.56.15 (192.168.56.15): icmp_seq=2 ttl=64 time=1.29 ms
64 bytes from 192.168.56.15 (192.168.56.15): icmp_seq=3 ttl=64 time=0.805 ms
64 bytes from 192.168.56.15 (192.168.56.15): icmp_seq=4 ttl=64 time=1.26 ms
^C
--- web1.dns.lab ping statistics ---



Сплит  DNS настроен.




  * zones: dns.lab, reverse dns.lab and ddns.lab
  * ns01 (192.168.50.10)
    * master, recursive, allows update to ddns.lab
  * ns02 (192.168.50.11)
    * slave, recursive
  * client1 (192.168.50.15)
    * used to test the env, runs rndc and nsupdate
  * client2 (192.168.50.16)
    * used to test the env, runs rndc and nsupdate
  * zone transfer: TSIG key
