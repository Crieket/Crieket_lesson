#!/bin/bash

#разбор логов:
#переменные

LOG_FILE="/home/kas/wget-log"
LOCK_FILE="/tmp/bash_parse.lock"
LAST_RUN_FILE="/tmp/last_run_timestamp"
CURRENT_TIME=$(date +%s)

if [ -f "$LOCK_FILE" ]; then #  проверка существования файла

         echo "Parslog запущен, выключаем..."
         exit 1
else
         touch  "$LOCK_FILE"  # Создаем
fi

echo "$CURRENT_TIME" > "$LAST_RUN_FILE"

if [ ! -f "$LAST_RUN_FILE" ]; then

LAST_RUN_TIMESTAMP=0
else

LAST_RUN_TIMESTAMP=$(cat "$LAST_RUN_FILE")

fi

START_TIME=$(date -d @$LAST_RUN_TIMESTAMP "+%d/%b/%Y:%H:%M:%S")

REPORT="ОТЧЕТ ($START_TIME):\n\n"

IP=$(grep -E "^\S+.*" $LOG_FILE | awk '{print $1}' | sort | uniq -c | sort -n)

REPORT+="$IP\n"

URL=$(grep -E "^\S+.*" $LOG_FILE | awk '{print $7}' | sort | uniq -c | sort -n)

REPORT+="$URL\n"

ERR=$(grep -E "^\S+.*" $LOG_FILE | grep -E '404|500|502|503' | awk '{print $9}' |sort |  uniq -c | sort -n);

REPORT+="$ERR\n"

HTTP=$(grep -E "^\S+.*" $LOG_FILE | awk '{print $11}' | sort | uniq -c | sort -n)

REPORT+="$HTTP\n"

echo  "$REPORT" > FIN_LOG
