После создания Vagrantfile запустим нашу ВМ командой vagrant up. Будет создана одна виртуальная машина. 

1


root@Home:/home/kas/Рабочий стол/Crieket_lesson/PAM# vagrant up
Bringing machine 'pam' up with 'virtualbox' provider...
==> pam: Box 'ubuntu/22.04' could not be found. Attempting to find and install...
    pam: Box Provider: virtualbox
    pam: Box Version: >= 0
==> pam: Loading metadata for box 'ubuntu/22.04'
    pam: URL: https://vagrant.elab.pro/api/v2/vagrant/ubuntu/22.04
==> pam: Adding box 'ubuntu/22.04' (v1.0.0) for provider: virtualbox
    pam: Downloading: http://vagrant.elab.pro:80/ubuntu/22.04/1.0.0/virtualbox
==> pam: Successfully added box 'ubuntu/22.04' (v1.0.0) for 'virtualbox'!
==> pam: Importing base box 'ubuntu/22.04'...
==> pam: Matching MAC address for NAT networking...
==> pam: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> pam: Setting the name of the VM: PAM_pam_1749390062273_63893
==> pam: Clearing any previously set network interfaces...
==> pam: Preparing network interfaces based on configuration...
    pam: Adapter 1: nat
    pam: Adapter 2: hostonly
==> pam: Forwarding ports...
    pam: 22 (guest) => 2222 (host) (adapter 1)
==> pam: Running 'pre-boot' VM customizations...
==> pam: Booting VM...
==> pam: Waiting for machine to boot. This may take a few minutes...
    pam: SSH address: 127.0.0.1:2222
    pam: SSH username: vagrant
    pam: SSH auth method: private key
    pam: 
    pam: Vagrant insecure key detected. Vagrant will automatically replace
    pam: this with a newly generated keypair for better security.
    pam: 
    pam: Inserting generated public key within guest...
    pam: Removing insecure key from the guest if it's present...
    pam: Key inserted! Disconnecting and reconnecting using new SSH key...
==> pam: Machine booted and ready!
==> pam: Checking for guest additions in VM...
    pam: The guest additions on this VM do not match the installed version of
    pam: VirtualBox! In most cases this is fine, but in rare cases it can
    pam: prevent things such as shared folders from working properly. If you see
    pam: shared folder errors, please make sure the guest additions within the
    pam: virtual machine match the version of VirtualBox you have installed on
    pam: your host and reload your VM.
    pam: 
    pam: Guest Additions Version: 6.0.0 r127566
    pam: VirtualBox Version: 7.0
==> pam: Setting hostname...
==> pam: Configuring and enabling network interfaces...
==> pam: Running provisioner: shell...
    pam: Running: inline script

root@Home:/home/kas/Рабочий стол/Crieket_lesson/PAM# vagrant status
Current machine states:

pam                       running (virtualbox)

root@pam:~# echo "otusadm:Otus2025!" | chpasswd && echo "otus:Otus2025!" | chpasswd



root@pam:~# usermod otusadm -a -G admin && usermod root -a -G admin && usermod  vagrant -a -G admin

root@Home:/home/kas/Рабочий стол/Crieket_lesson/PAM# ssh otusadm@192.168.57.10
$ whoami
otusadm
$ pwd
/
$ 
root@pam:~# cat  /etc/group | grep admin
admin:x:118:otusadm,root,vagrant

root@pam:~# cat  /etc/group | awk '{print $1}'

vagrant:x:1000:
ubuntu:x:1001:
otusadm:x:1002:
otus:x:1003:

Под user: otus не заходит в выходные дни

Last login: Sun Jun  8 15:25:11 2025 
root@Home:/home/kas/Рабочий стол/Crieket_lesson/PAM# ssh otus@192.168.57.10
otus@192.168.57.10's password: 
Permission denied, please try again.
otus@192.168.57.10's password: 

root@Home:/home/kas/Рабочий стол/Crieket_lesson/PAM# ssh otusadm@192.168.57.10
otusadm@192.168.57.10's password: 
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-71-generic x86_64)

Меняем дату на понедельник (останавливаем службу)

vagrant@pam:~$ timedatectl 
               Local time: Sun 2025-06-08 15:53:17 UTC
           Universal time: Sun 2025-06-08 15:53:17 UTC
                 RTC time: Sun 2025-06-08 15:53:16
                Time zone: Etc/UTC (UTC, +0000)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
vagrant@pam:~$ systemctl stop systemd-timesyncd.service 
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===

vagrant@pam:~$ sudo date --set "Jun 9 15:53:50 MSK 2025"
vagrant@pam:~$ date
Mon Jun  9 15:54:01 UTC 2025
 
root@Home:/home/kas/Рабочий стол/Crieket_lesson/PAM# ssh otus@192.168.57.10
otus@192.168.57.10's password: 
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-71-generic x86_64)

root@Home:/home/kas/Рабочий стол/Crieket_lesson/PAM# ssh otusadm@192.168.57.10
otusadm@192.168.57.10's password: 
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-71-generic x86_64)

В будни зашел.

Подтверждаю , что скрипт в  /etc/pam.d/sshd -  pam_exec.so /usr/local/bin/login.sh работает.
