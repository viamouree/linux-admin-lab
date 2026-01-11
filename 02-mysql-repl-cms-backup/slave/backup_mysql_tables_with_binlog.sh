#!/usr/bin/env bash
set -e

DB="wordpress"
DIR="/var/backups/mysql"
TS=$(date +%F_%H-%M-%S)

mkdir -p $DIR/$TS

STATUS=$(mysql -e "SHOW SLAVE STATUS\G")
LOG_FILE=$(echo "$STATUS" | awk -F': ' '/Relay_Master_Log_File/{print $2}')
LOG_POS=$(echo "$STATUS" | awk -F': ' '/Exec_Master_Log_Pos/{print $2}')

echo "log_file=$LOG_FILE" > $DIR/$TS/META.txt
echo "log_pos=$LOG_POS" >> $DIR/$TS/META.txt

for t in $(mysql -N -e "SHOW TABLES FROM $DB"); do
  mysqldump $DB $t | gzip > $DIR/$TS/$t.sql.gz
done
