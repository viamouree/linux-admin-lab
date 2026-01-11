#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:-labdb}"
OUT_DIR="/var/backups/mysql-tables"
TS="$(date +%F_%H-%M-%S)"

sudo mkdir -p "${OUT_DIR}"

# (не обязательно по ТЗ, но полезно) фиксируем позицию реплики
STATUS="$(mysql -e "SHOW SLAVE STATUS\G" || true)"
RELAY_FILE="$(echo "${STATUS}" | awk -F': ' '/Relay_Master_Log_File/{print $2; exit}')"
EXEC_POS="$(echo "${STATUS}"  | awk -F': ' '/Exec_Master_Log_Pos/{print $2; exit}')"

# Проверка существования БД (на slave она появится через репликацию)
if ! mysql -N -e "SHOW DATABASES LIKE '${DB_NAME}';" | grep -qx "${DB_NAME}"; then
  echo "ERROR: Database '${DB_NAME}' not found on slave yet."
  exit 1
fi

TABLES="$(mysql -N -e "SHOW TABLES FROM \`${DB_NAME}\`;" )"
if [[ -z "${TABLES}" ]]; then
  echo "ERROR: No tables in '${DB_NAME}'."
  exit 1
fi

# META на каждый запуск (в тот же каталог)
META="${OUT_DIR}/${DB_NAME}_${TS}_META.txt"
echo "db=${DB_NAME}" > "${META}"
echo "timestamp=${TS}" >> "${META}"
echo "relay_master_log_file=${RELAY_FILE}" >> "${META}"
echo "exec_master_log_pos=${EXEC_POS}" >> "${META}"

# Потабличные дампы (в тот же каталог)
for t in ${TABLES}; do
  OUT_FILE="${OUT_DIR}/${DB_NAME}_${t}_${TS}.sql.gz"
  mysqldump --single-transaction --quick "${DB_NAME}" "${t}" | gzip -9 | sudo tee "${OUT_FILE}" >/dev/null
done

echo "OK: ${DB_NAME} backup at ${TS} -> ${OUT_DIR}"
