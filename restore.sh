#!/bin/bash
# Script per restaurar backup de MariaDB
# Us: ./restore.sh backup_20250105_020000.sql.gz
#     ./restore.sh /mnt/nas/backups/backup_20250105_020000.sql.gz

set -e

if [ $# -eq 0 ]; then
    echo "[ERROR] Especifica el fitxer del backup"
    echo "Us: ./restore.sh backup_YYYYMMDD_HHMMSS.sql.gz"
    echo "    ./restore.sh /ruta/completa/backup_YYYYMMDD_HHMMSS.sql.gz"
    exit 1
fi

BACKUP_FILE="$1"

# Si la ruta és absoluta o relativa amb /, usar-la directament
# Sinó, buscar a la carpeta backups/ per defecte
if [[ "$BACKUP_FILE" == /* ]] || [[ "$BACKUP_FILE" == */* ]]; then
    FULL_PATH="$BACKUP_FILE"
else
    FULL_PATH="backups/$BACKUP_FILE"
fi

if [ ! -f "$FULL_PATH" ]; then
    echo "[ERROR] No es troba el fitxer $FULL_PATH"
    exit 1
fi

echo "[ADVERTIMENT] Això sobreescriurà la base de dades actual"
echo "              Fitxer: $FULL_PATH"
read -p "¿Continuar? (S/N): " CONFIRM

if [ "$CONFIRM" != "S" ] && [ "$CONFIRM" != "s" ]; then
    echo "[INFO] Cancel·lat"
    exit 0
fi

echo "[INFO] Restaurant backup..."

# Restaurar desde el contenedor
gunzip -c "$FULL_PATH" | docker exec -i comandes_mariadb sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD" databaseapi'

if [ $? -eq 0 ]; then
    echo "[OK] Backup restaurat correctament"
else
    echo "[ERROR] Error en restaurar"
    exit 1
fi
