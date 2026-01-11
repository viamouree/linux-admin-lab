#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:-labdb}"
OUT_DIR="/var/backups/mysql-tables"
TS="$(date +%F_%H-%M-%S)"

sudo mkdir -p "${OUT_DIR}"

# Wait for DB to appear via replication (up to 60 seconds)
for i in {1..30}; do
  if mysql -N -e "SHOW DATABASES LIKE '${DB_NAME}';" | grep -qx "${DB_NAME}"; then
    break
  fi
  sleep 2
done

if ! mysql -N -e "SHOW DATABASES LIKE '${DB_NAME}';" | grep -qx "${DB_NAME}"; then
  echo "ERROR: Database '${DB_NAME}' not found on slave yet."
  exit 1
fi

# (not required by TZ, but useful) capture replication position
STATUS="$(mysql -e "SHOW SLAVE STATUS\G" || true)"
RELAY_FILE="$(echo "${STATUS}" | awk -F': ' '/Relay_Master_Log_File/{print $2; exit}')"
EXEC_POS="$(echo "${STATUS}"  | awk -F': ' '/Exec_Master_Log_Pos/{print $2; exit}')"

TABLES="$(mysql -N -e "SHOW TABLES FROM \`${DB_NAME}\`;" )"
if [[ -z "${TABLES}" ]]; then
  echo "ERROR: No tables in '${DB_NAME}'."
  exit 1
fi

# META per run (same directory)
META="${OUT_DIR}/${DB_NAME}_${TS}_META.txt"
sudo tee "${META}" >/dev/null <<EOF
db=${DB_NAME}
timestamp=${TS}
relay_master_log_file=${RELAY_FILE}
exec_master_log_pos=${EXEC_POS}
EOF

# Table-by-table dumps (same directory)
for t in ${TABLES}; do
  OUT_FILE="${OUT_DIR}/${DB_NAME}_${t}_${TS}.sql.gz"
  mysqldump --single-transaction --quick "${DB_NAME}" "${t}" | gzip -9 | sudo tee "${OUT_FILE}" >/dev/null
done

echo "OK: ${DB_NAME} backup at ${TS} -> ${OUT_DIR}"

# keep only last 1 day (optional)
sudo find "${OUT_DIR}" -type f -name "*.sql.gz" -mmin +1440 -delete || true
sudo find "${OUT_DIR}" -type f -name "*_META.txt" -mmin +1440 -delete || true
