#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:-labdb}"
BASE_DIR="/var/backups/mysql"
TS="$(date +%F_%H-%M-%S)"
OUT_DIR="${BASE_DIR}/${DB_NAME}/${TS}"

mkdir -p "${OUT_DIR}"

# Берём позицию, до которой slave применил события master
STATUS="$(mysql -e "SHOW SLAVE STATUS\G" || true)"

if [[ -z "${STATUS}" ]]; then
  echo "ERROR: Can't read slave status. Is this server configured as a MySQL slave?"
  exit 1
fi

RELAY_LOG_FILE="$(echo "${STATUS}" | awk -F': ' '/Relay_Master_Log_File/{print $2; exit}')"
EXEC_POS="$(echo "${STATUS}" | awk -F': ' '/Exec_Master_Log_Pos/{print $2; exit}')"

if [[ -z "${RELAY_LOG_FILE}" || -z "${EXEC_POS}" ]]; then
  echo "ERROR: Couldn't parse Relay_Master_Log_File / Exec_Master_Log_Pos from SHOW SLAVE STATUS."
  exit 1
fi

# Проверим, что база существует
if ! mysql -N -e "SHOW DATABASES LIKE '${DB_NAME}';" | grep -qx "${DB_NAME}"; then
  echo "ERROR: Database '${DB_NAME}' not found."
  exit 1
fi

# META с бинлог-позицией
cat > "${OUT_DIR}/META.txt" <<EOF
db=${DB_NAME}
timestamp=${TS}
relay_master_log_file=${RELAY_LOG_FILE}
exec_master_log_pos=${EXEC_POS}
EOF

# Потабличный дамп
TABLES="$(mysql -N -e "SHOW TABLES FROM \`${DB_NAME}\`;" )"
if [[ -z "${TABLES}" ]]; then
  echo "ERROR: No tables found in database '${DB_NAME}'."
  exit 1
fi

for t in ${TABLES}; do
  mysqldump --single-transaction --quick "${DB_NAME}" "${t}" | gzip -9 > "${OUT_DIR}/${t}.sql.gz"
done

echo "OK: Backup created at ${OUT_DIR}"
echo "Binlog position: ${RELAY_LOG_FILE}:${EXEC_POS}"
