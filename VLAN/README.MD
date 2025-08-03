Описание домашнего задания
в Office1 в тестовой подсети появляется сервера с доп интерфейсами и адресами
в internal сети testLAN: 
- testClient1 - 192.168.1.254
- testClient2 - 192.168.2.254
- testServer1-  192.168.1.1
- testServer2-  192.168.2.1

Равести вланами:

testClient1 <-> testServer1

![alt text](vlan1,2/image.png)

![alt text](vlan1,2/image-1.png)

![alt text](vlan1,2/image-2.png)


testClient2 <-> testServer2

![alt text](vlan1,2/image-3.png)

![alt text](vlan1,2/image-4.png)

![alt text](vlan1,2/image-5.png)




Между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд, проверить работу c отключением интерфейсов

Проверка bonding  на 
inetRouter

![alt text](Bonding/image.png)

centalRouter

![alt text](Bonding/image-1.png)


Статик агригирование -active-backup 
InetRouter

![alt text](Bonding/image-2.png)

centralRouter
![alt text](Bonding/image-3.png)

Отключение\Падение eth1 centralRouter

![alt text](Bonding/image-4.png)
