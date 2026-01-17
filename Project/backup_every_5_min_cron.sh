#!/bin/bash
export PATH="/usr/local/bin:/usr/bin:/bin"
cd /home/kas/Рабочий\ стол/Crieket_lesson/Project
ansible-playbook -i hosts.ini roles/backup/backup_db_wp.yml >> /var/log/ansible-backup.log 2>&1