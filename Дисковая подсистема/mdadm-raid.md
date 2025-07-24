kas@ubserv:~$ sudo -i
[sudo] password for kas:
root@ubserv:~#
root@ubserv:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   25G  0 disk
├─sda1                      8:1    0    1G  0 part /boot/efi
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0 21,9G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   11G  0 lvm  /
sdb                         8:16   0    1G  0 disk
sdc                         8:32   0    1G  0 disk
sdd                         8:48   0    1G  0 disk
sde                         8:64   0    1G  0 disk
sdf                         8:80   0    1G  0 disk
sdg                         8:96   0    1G  0 disk
sr0                        11:0    1 1024M  0 rom
root@ubserv:~# mdadm --zero-superblock --force /dev/sd{d,c,d,e,f,g}
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf
mdadm: Unrecognised md component device - /dev/sdg
root@ubserv:~# wipefs --all --force /dev/sd{d,c,d,e,f,g}
root@ubserv:~# mdadm --create --verbose /dev/md1 -l 10 -n 4 /dev/sd{b,c,d,e}
mdadm: layout defaults to n2
mdadm: layout defaults to n2
mdadm: chunk size defaults to 512K
mdadm: size set to 1046528K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
root@ubserv:~# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Tue Mar 11 18:19:48 2025
        Raid Level : raid10
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Tue Mar 11 18:19:59 2025
             State : clean
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubserv:1  (local to host ubserv)
              UUID : 9274246b:c255eeb3:9dedad8a:ada1c149
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde
root@ubserv:~# cat /proc/mdstat
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid10 sde[3] sdd[2] sdc[1] sdb[0]
      2093056 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]

unused devices: <none>
root@ubserv:~# mkfs.ext4 -F /dev/md1
mke2fs 1.47.0 (5-Feb-2023)
/dev/md1 contains a ext4 file system
        created on Thu Mar  6 09:47:51 2025
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 6c24bced-61fa-4781-8e7b-aa6c74bba95c
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
root@ubserv:~# mkdir -p /mnt/md1
root@ubserv:~# mount /dev/md1 /mnt/md1
root@ubserv:~#
root@ubserv:~# echo "DEVICE Partitions" > /etc/mdadm/mdadm.conf
root@ubserv:~# mdadm --detail --scan --verbose
ARRAY /dev/md1 level=raid10 num-devices=4 metadata=1.2 UUID=9274246b:c255eeb3:9dedad8a:ada1c149
root@ubserv:~# mdadm --detail --scan | awk  '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
root@ubserv:~# cat /etc/mdadm/mdadm.conf
DEVICE Partitions
ARRAY /dev/md1 metadata=1.2 UUID=9274246b:c255eeb3:9dedad8a:ada1c149
root@ubserv:~#
root@ubserv:~# nano /etc/fstab
root@ubserv:~# cat /etc/fstab
/dev/md1        /mnt/md1        ext4    defaults        0       0
root@ubserv:~# mdadm /dev/md1 --fail /dev/sdb
mdadm: set /dev/sdb faulty in /dev/md1
root@ubserv:~# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Tue Mar 11 18:19:48 2025
        Raid Level : raid10
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Tue Mar 11 18:49:09 2025
             State : clean, degraded
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 1
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubserv:1  (local to host ubserv)
              UUID : 9274246b:c255eeb3:9dedad8a:ada1c149
            Events : 19

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde

       0       8       16        -      faulty   /dev/sdb
root@ubserv:~# mdadm /dev/md1 --remove /dev/sdb
mdadm: hot removed /dev/sdb from /dev/md1
root@ubserv:~# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Tue Mar 11 18:19:48 2025
        Raid Level : raid10
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 4
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Tue Mar 11 18:49:52 2025
             State : clean, degraded
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubserv:1  (local to host ubserv)
              UUID : 9274246b:c255eeb3:9dedad8a:ada1c149
            Events : 20

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde
root@ubserv:~# mdadm /dev/md1 --add /dev/sdf
mdadm: added /dev/sdf
root@ubserv:~# mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Tue Mar 11 18:19:48 2025
        Raid Level : raid10
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Tue Mar 11 18:51:01 2025
             State : clean, degraded, recovering
    Active Devices : 3
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 1

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

    Rebuild Status : 50% complete

              Name : ubserv:1  (local to host ubserv)
              UUID : 9274246b:c255eeb3:9dedad8a:ada1c149
            Events : 31

    Number   Major   Minor   RaidDevice State
       4       8       80        0      spare rebuilding   /dev/sdf
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde
root@ubserv:~# cat /proc/mdstat
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid10 sdf[4] sde[3] sdd[2] sdc[1]
      2093056 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]

root@ubserv:~# mdadm --zero-superblock --force /dev/sdb
root@ubserv:~# wipefs --all --force /dev/sdb
root@ubserv:~# mdadm --create --verbose /dev/md2 -l 1 -n 2 /dev/sd{b,g}
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 1046528K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md2 started.
root@ubserv:~# part
parted     partprobe  partx
root@ubserv:~# parted -s /dev/md2 mklabel gpt
root@ubserv:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE   MOUNTPOINTS
sda                         8:0    0   25G  0 disk
├─sda1                      8:1    0    1G  0 part   /boot/efi
├─sda2                      8:2    0    2G  0 part   /boot
└─sda3                      8:3    0 21,9G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   11G  0 lvm    /
sdb                         8:16   0    1G  0 disk
└─md2                       9:2    0 1022M  0 raid1
sdc                         8:32   0    1G  0 disk
└─md1                       9:1    0    2G  0 raid10 /mnt/md1
sdd                         8:48   0    1G  0 disk
└─md1                       9:1    0    2G  0 raid10 /mnt/md1
sde                         8:64   0    1G  0 disk
└─md1                       9:1    0    2G  0 raid10 /mnt/md1
sdf                         8:80   0    1G  0 disk
└─md1                       9:1    0    2G  0 raid10 /mnt/md1
sdg                         8:96   0    1G  0 disk
└─md2                       9:2    0 1022M  0 raid1
sr0                        11:0    1 1024M  0 rom
root@ubserv:~# parted /dev/md2 mkpart primary ext4 0% 50%
sdb                         8:16   0    1G  0 disk
└─md2                       9:2    0 1022M  0 raid1
  ├─md2p1                 259:2    0  510M  0 part
  └─md2p2                 259:3    0  510M  0 part


root@ubserv:~# parted /dev/md2 mkpart primary ext4 50% 100%
sdg                         8:96   0    1G  0 disk
└─md2                       9:2    0 1022M  0 raid1
  ├─md2p1                 259:2    0  510M  0 part
  └─md2p2                 259:3    0  510M  0 part


root@ubserv:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE   MOUNTPOINTS
sda                         8:0    0   25G  0 disk
├─sda1                      8:1    0    1G  0 part   /boot/efi
├─sda2                      8:2    0    2G  0 part   /boot
└─sda3                      8:3    0 21,9G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   11G  0 lvm    /
sdb                         8:16   0    1G  0 disk
└─md2                       9:2    0 1022M  0 raid1  /mnt/md2
sdc                         8:32   0    1G  0 disk
└─md1                       9:1    0    2G  0 raid10 /mnt/md1
sdd                         8:48   0    1G  0 disk
└─md1                       9:1    0    2G  0 raid10 /mnt/md1
sde                         8:64   0    1G  0 disk
└─md1                       9:1    0    2G  0 raid10 /mnt/md1
sdf                         8:80   0    1G  0 disk
└─md1                       9:1    0    2G  0 raid10 /mnt/md1
sdg                         8:96   0    1G  0 disk
└─md2                       9:2    0 1022M  0 raid1  /mnt/md2
sr0                        11:0    1 1024M  0 rom
root@ubserv:~# cat /etc/fstab
root@ubserv:~# nano /etc/fstab
/dev/md1        /mnt/md1        ext4    defaults        0       0
/dev/md2        /mnt/md2        ext4    defaults        0       0
root@ubserv:~# cat /proc/mdstat
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md2 : active raid1 sdg[1] sdb[0]
      1046528 blocks super 1.2 [2/2] [UU]

md1 : active raid10 sdf[4] sde[3] sdd[2] sdc[1]
      2093056 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
root@ubserv:~# update-initramfs -u
update-initramfs: Generating /boot/initrd.img-6.8.0-54-generic
