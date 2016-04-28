#!/bin/sh
ndate=$(echo `date`|sed 's/[[:space:]]/\_/g')
backup_dir=/var/crm_backup
bkfile=$backup_dir/mysql_backup_$ndate.sql
mysqldump -uroot -pteamsun --event --all-databases >$bkfile
