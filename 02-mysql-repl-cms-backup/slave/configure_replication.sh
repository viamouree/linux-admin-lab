#!/usr/bin/env bash
set -euo pipefail

MASTER_HOST="${MASTER_HOST:-192.168.118.129}"
REPL_USER="${REPL_USER:-repl}"
REPL_PASS="${REPL_PASS:-replpass}"

MASTER_STATUS="$(mysql -h "${MASTER_HOST}" -u"${REPL_USER}" -p"${REPL_PASS}" -e "SHOW MASTER STATUS\G" 2>/dev/null || true)"
FILE="$(echo "${MASTER_STATUS}" | awk -F': ' '/File:/{print $2; exit}')"
POS="$(echo "${MASTER_STATUS}"  | awk -F': ' '/Position:/{print $2; exit}')"

if [[ -z "${FILE}" || -z "${POS}" ]]; then
  echo "ERROR: Cannot read master status. Check mysql, user repl, password, network."
  exit 1
fi

sudo mysql -e "STOP SLAVE;" || true
sudo mysql -e "RESET SLAVE ALL;" || true

sudo mysql -e "CHANGE MASTER TO \
MASTER_HOST='${MASTER_HOST}', \
MASTER_USER='${REPL_USER}', \
MASTER_PASSWORD='${REPL_PASS}', \
MASTER_LOG_FILE='${FILE}', \
MASTER_LOG_POS=${POS};"

sudo mysql -e "START SLAVE;"

sudo mysql -e "SHOW SLAVE STATUS\G" | egrep "Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master|Last_IO_Error|Last_SQL_Error" || true
