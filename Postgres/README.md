
В Ручном режиме.

vagrant@node1:~$ sudo tail -f /var/log/postgresql/postgresql-14-main.log 
2026-03-10 09:40:05.368 UTC [6463] FATAL:  could not load pg_hba.conf
2026-03-10 09:40:05.368 UTC [6463] LOG:  database system is shut down
pg_ctl: could not start server
Examine the log output.
2026-03-10 09:51:37.910 UTC [6803] LOG:  starting PostgreSQL 14.22 (Ubuntu 14.22-0ubuntu0.22.04.1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0, 64-bit
2026-03-10 09:51:37.911 UTC [6803] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2026-03-10 09:51:37.911 UTC [6803] LOG:  listening on IPv4 address "192.168.56.10", port 5432
2026-03-10 09:51:37.911 UTC [6803] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2026-03-10 09:51:37.912 UTC [6804] LOG:  database system was shut down at 2026-03-10 09:03:26 UTC
2026-03-10 09:51:38.014 UTC [6803] LOG:  database system is ready to accept connections

root@node2:~# pg_basebackup -h 192.168.56.10 -U replicator -D /tmp/pg_backup -R -P 
Password: 
26275/26275 kB (100%), 1/1 tablespace

postgres=#\l

                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
-----------+----------+----------+---------+---------+-----------------------
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 test_kas  | postgres | UTF8     | C.UTF-8 | C.UTF-8

 
 


 
 postgres=# select * from pg_stat_replication;

 pid  | usesysid |  usename   | application_name |  client_addr  | client_hostname | client_port |         backend_start         | backend_xmin |   state   | sent_lsn  | write_lsn | flush_lsn | replay_lsn | write_lag | flush_lag | replay_lag | sync_priority | sync_state |          reply_time           
-------+----------+------------+------------------+---------------+-----------------+-------------+-------------------------------+--------------+-----------+-----------+-----------+-----------+------------+-----------+-----------+------------+---------------+------------+-------------------------------
 11428 |    16384 | replicator | 14/main          | 192.168.56.20 |                 |       41184 | 2026-03-10 10:15:36.349391-03 |          737 | streaming | 0/B000148 | 0/B000148 | 0/B000148 | 0/B000148  |           |           |            |             0 | async      | 2026-03-10 10:50:42.228036-03
(1 row)



postgres=# select * from pg_stat_wal_receiver;

 pid  |  status   | receive_start_lsn | receive_start_tli | written_lsn | flushed_lsn | received_tli |      last_msg_send_time       |     last_msg_receipt_time     | latest_end_lsn |        latest_end_time        | slot_name |  sender_host  | sender_port |                                                                                                                                      conninfo                                                                                                                                       
------+-----------+-------------------+-------------------+-------------+-------------+--------------+-------------------------------+-------------------------------+----------------+-------------------------------+-----------+---------------+-------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 9077 | streaming | 0/B000000         |                 1 | 0/B000148   | 0/B000148   |            1 | 2026-03-10 10:51:42.451316-03 | 2026-03-10 10:51:42.443558-03 | 0/B000148      | 2026-03-10 10:15:36.358315-03 |           | 192.168.56.10 |        5432 | user=replicator password=******** channel_binding=prefer dbname=replication host=192.168.56.10 port=5432 fallback_application_name=14/main sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
(1 row)



Через ansible 

kas@Home:~/Crieket_lesson/Postgres$ vagrant up --provision
Bringing machine 'node1' up with 'virtualbox' provider...
Bringing machine 'node2' up with 'virtualbox' provider...
Bringing machine 'barman' up with 'virtualbox' provider...
==> node1: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> node2: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> barman: Checking if box 'ubuntu/22.04' version '1.0.0' is up to date...
==> barman: Running provisioner: ansible...
    barman: Running ansible-playbook...

PLAY [postgres] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [barman]
ok: [node2]
ok: [node1]

TASK [postgres_install : TTL] **************************************************
changed: [node2]
changed: [barman]
changed: [node1]

TASK [postgres_install : ttl output] *******************************************
ok: [node1] => {
    "ttl_default.stdout_lines": [
        "64"
    ]
}
ok: [node2] => {
    "ttl_default.stdout_lines": [
        "64"
    ]
}
ok: [barman] => {
    "ttl_default.stdout_lines": [
        "64"
    ]
}

TASK [postgres_install : install postgresql-server] ****************************
ok: [barman]
ok: [node2]
ok: [node1]

TASK [postgres_install : enable and start service] *****************************
ok: [barman]
ok: [node2]
ok: [node1]

PLAY [postgres_master] *********************************************************

TASK [Gathering Facts] *********************************************************
ok: [node1]

TASK [postgres_master : install base tools] ************************************
ok: [node1]

TASK [postgres_master : Create replicator user] ********************************
[WARNING]: Using world-readable permissions for temporary files Ansible needs to create when becoming an unprivileged user. This may be insecure. For information on securing this, see https://docs.ansible.com/ansible-core/2.20/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-an-unprivileged-user
ok: [node1]

TASK [postgres_master : stop postgresql-server on node2] ***********************
skipping: [node1]

TASK [postgres_master : copy postgresql.conf] **********************************
changed: [node1]

TASK [postgres_master : copy pg_hba.conf] **************************************
changed: [node1]

TASK [postgres_master : restart postgresql-server on node1] ********************
changed: [node1]

TASK [postgres_master : Remove files from data catalog] ************************
changed: [node1 -> node2(192.168.56.20)]

TASK [postgres_master : copy files from master to slave] ***********************
changed: [node1 -> node2(192.168.56.20)]

PLAY [postgres_replication] ****************************************************

TASK [Gathering Facts] *********************************************************
ok: [node2]

TASK [postgres_replication : copy postgresql.conf] *****************************
ok: [node2]

TASK [postgres_replication : copy pg_hba.conf] *********************************
ok: [node2]

TASK [postgres_replication : start postgresql-server on node2] *****************
ok: [node2]

PLAY [barmen] ******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [barman]

TASK [barman : install base tools] *********************************************
ok: [barman]

TASK [barman : install barman and postgresql packages on barman] ***************
ok: [barman]

TASK [barman : install barman-cli and postgresql packages on nodes] ************
skipping: [barman]

TASK [barman : generate SSH key for postgres] **********************************
[WARNING]: Found existing ssh key private file "/var/lib/postgresql/.ssh/id_rsa", no force, so skipping ssh-keygen generation
ok: [barman -> node1(192.168.56.10)]

TASK [barman : fetch public ssh key from node1] ********************************
changed: [barman -> node1(192.168.56.10)]

TASK [barman : add postgres key to barman authorized_keys] *********************
ok: [barman]

TASK [barman : generate SSH key for barman] ************************************
[WARNING]: Found existing ssh key private file "/var/lib/barman/.ssh/id_rsa", no force, so skipping ssh-keygen generation
ok: [barman]

TASK [barman : fetch public ssh key from barman] *******************************
changed: [barman]

TASK [barman : add barman key to postgres authorized_keys on node1] ************
ok: [barman -> node1(192.168.56.10)]

TASK [barman : Create barman user] *********************************************
ok: [barman -> node1(192.168.56.10)]

TASK [barman : Add permission for barman] **************************************
changed: [barman -> node1(192.168.56.10)]

TASK [barman : restart postgresql-server on node1] *****************************
changed: [barman -> node1(192.168.56.10)]

TASK [barman : Create DB for backup] *******************************************
ok: [barman -> node1(192.168.56.10)]

TASK [barman : Add tables to otus_backup] **************************************
ok: [barman -> node1(192.168.56.10)]

TASK [barman : copy .pgpass] ***************************************************
ok: [barman]

TASK [barman : copy barman.conf] ***********************************************
ok: [barman]

TASK [barman : copy node1.conf] ************************************************
ok: [barman]

TASK [barman : barman switch-wal node1] ****************************************
changed: [barman]

TASK [barman : barman cron] ****************************************************
changed: [barman]

PLAY RECAP *********************************************************************
barman                     : ok=24   changed=7    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
node1                      : ok=13   changed=6    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
node2                      : ok=9    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

Проверка

barman@barman:~$ barman status node1 
2026-03-11 19:33:35,834 [80917] barman.utils WARNING: Failed opening the requested log file. Using standard error instead.
Server node1:
        Description: PostgreSQL Master node1
        Active: True
        Disabled: False
        PostgreSQL version: 14.22
        Cluster state: in production
        pgespresso extension: Not available
        Current data size: 42.2 MiB
        PostgreSQL Data directory: /var/lib/postgresql/14/main
        Current WAL segment: 000000010000000000000090
        Passive node: False
        Retention policies: enforced (mode: auto, retention: RECOVERY WINDOW OF 3 DAYS, WAL retention: MAIN)
        No. of available backups: 1
        First available backup: 20260311T192841
        Last available backup: 20260311T192841
        Minimum redundancy requirements: satisfied (1/1)

barman@barman:~$ barman check node1 
2026-03-11 19:32:59,182 [80904] barman.utils WARNING: Failed opening the requested log file. Using standard error instead.
Server node1:
2026-03-11 19:32:59,188 [80904] barman.server ERROR: Check 'empty incoming directory' failed for server 'node1'
        empty incoming directory: FAILED ('/var/lib/barman/node1/incoming' must be empty when archiver=off)
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: OK (interval provided: 4 days, latest backup age: 4 minutes, 5 seconds)
        backup minimum size: OK (41.8 MiB)
        wal maximum age: OK (no last_wal_maximum_age provided)
        wal size: OK (16.1 KiB)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: OK (have 1 backups, expected at least 1)
        pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK


barman@barman:~$ barman list-backups node1 
2026-03-11 19:31:16,037 [80890] barman.utils WARNING: Failed opening the requested log file. Using standard error instead.
node1 20260311T192841 - Wed Mar 11 19:28:53 2026 - Size: 41.9 MiB - WAL Size: 16.1 KiB

                              List of databases
    Name     |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
-------------+----------+----------+---------+---------+-----------------------
 otus        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 otus_backup | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 postgres    | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 template0   | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
             |          |          |         |         | postgres=CTc/postgres
 template1   | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
             |          |          |         |         | postgres=CTc/postgres
(5 rows)

postgres=# DROP DATABASE otus;
DROP DATABASE
postgres=# DROP DATABASE otus_backup;
DROP DATABASE


ostgres=# \l
                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
-----------+----------+----------+---------+---------+-----------------------
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
(3 rows)

barman@barman:~$ barman recover node1 20260311T192841 /var/lib/postgresql/14/main/ --remote-ssh-comman "ssh postgres@192.
168.56.10"
2026-03-11 19:37:47,840 [81017] barman.utils WARNING: Failed opening the requested log file. Using standard error instead.
2026-03-11 19:37:47,846 [81017] barman.wal_archiver INFO: No xlog segments found from streaming for node1.
Starting remote restore for server node1 using backup 20260311T192841
2026-03-11 19:37:48,320 [81017] barman.recovery_executor INFO: Starting remote restore for server node1 using backup 20260311T192841
Destination directory: /var/lib/postgresql/14/main/
2026-03-11 19:37:48,322 [81017] barman.recovery_executor INFO: Destination directory: /var/lib/postgresql/14/main/
Remote command: ssh postgres@192.168.56.10
2026-03-11 19:37:48,325 [81017] barman.recovery_executor INFO: Remote command: ssh postgres@192.168.56.10
2026-03-11 19:37:48,555 [81017] barman.recovery_executor WARNING: Unable to retrieve safe horizon time for smart rsync copy: The /var/lib/postgresql/14/main/.barman-recover.info file does not exist
Copying the base backup.
2026-03-11 19:37:49,080 [81017] barman.recovery_executor INFO: Copying the base backup.
2026-03-11 19:37:49,090 [81017] barman.copy_controller INFO: Copy started (safe before None)
2026-03-11 19:37:49,091 [81017] barman.copy_controller INFO: Copy step 1 of 4: [global] analyze PGDATA directory: /var/lib/barman/node1/base/20260311T192841/data/
2026-03-11 19:37:49,490 [81017] barman.copy_controller INFO: Copy step 2 of 4: [global] create destination directories and delete unknown files for PGDATA directory: /var/lib/barman/node1/base/20260311T192841/data/
2026-03-11 19:37:49,914 [81034] barman.copy_controller INFO: Copy step 3 of 4: [bucket 0] starting copy safe files from PGDATA directory: /var/lib/barman/node1/base/20260311T192841/data/
2026-03-11 19:37:50,400 [81034] barman.copy_controller INFO: Copy step 3 of 4: [bucket 0] finished (duration: less than one second) copy safe files from PGDATA directory: /var/lib/barman/node1/base/20260311T192841/data/
2026-03-11 19:37:50,415 [81034] barman.copy_controller INFO: Copy step 4 of 4: [bucket 0] starting copy files with checksum from PGDATA directory: /var/lib/barman/node1/base/20260311T192841/data/
2026-03-11 19:37:50,691 [81034] barman.copy_controller INFO: Copy step 4 of 4: [bucket 0] finished (duration: less than one second) copy files with checksum from PGDATA directory: /var/lib/barman/node1/base/20260311T192841/data/
2026-03-11 19:37:50,698 [81017] barman.copy_controller INFO: Copy finished (safe before None)
Copying required WAL segments.
2026-03-11 19:37:50,983 [81017] barman.recovery_executor INFO: Copying required WAL segments.
2026-03-11 19:37:50,986 [81017] barman.recovery_executor INFO: Starting copy of 4 WAL files 4/4 from WalFileInfo(compression='gzip', name='00000001000000000000008D', size=16462, time=1773257322.3022835) to WalFileInfo(compression='gzip', name='000000010000000000000090', size=16472, time=1773257647.159768)
2026-03-11 19:37:51,755 [81017] barman.recovery_executor INFO: Finished copying 4 WAL files.
Generating archive status files
2026-03-11 19:37:51,757 [81017] barman.recovery_executor INFO: Generating archive status files
Identify dangerous settings in destination directory.
2026-03-11 19:37:52,572 [81017] barman.recovery_executor INFO: Identify dangerous settings in destination directory.

WARNING
The following configuration files have not been saved during backup, hence they have not been restored.
You need to manually restore them in order to start the recovered PostgreSQL instance:

    postgresql.conf
    pg_hba.conf
    pg_ident.conf

Recovery completed (start time: 2026-03-11 19:37:47.848087, elapsed time: 5 seconds)

Your PostgreSQL server has been successfully prepared for recovery!
barman@barman:~$ 

    Name     |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
-------------+----------+----------+---------+---------+-----------------------
 otus        | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 otus_backup | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 postgres    | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
 template0   | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
             |          |          |         |         | postgres=CTc/postgres
 template1   | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
             |          |          |         |         | postgres=CTc/postgres
(5 rows)
