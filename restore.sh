#!/bin/bash
# Script per restaurar backup de MariaDB
# Us: ./restore.sh backup_20250105_020000.sql.gz

set -e

if [ $# -eq 0 ]; then
    echo "❌ Error: Especifica el fitxer del backup"
    echo "Us: ./restore.sh backup_YYYYMMDD_HHMMSS.sql.gz"
    exit 1
fi

BACKUP_FILE="$1"
FULL_PATH="backups/$BACKUP_FILE"

if [ ! -f "$FULL_PATH" ]; then
    echo "❌ Error: No es troba el fitxer $FULL_PATH"
    exit 1
fi

echo "⚠️  ADVERTIMENT: Això sobreescriurà la base de dades actual"
echo "   Fitxer: $BACKUP_FILE"
read -p "¿Continuar? (S/N): " CONFIRM

if [ "$CONFIRM" != "S" ] && [ "$CONFIRM" != "s" ]; then
    echo "❌ Cancel·lat"
    exit 0
fi

echo "🔄 Restaurant backup..."

# Restaurar desde el contenedor
gunzip -c "$FULL_PATH" | docker exec -i comandes_mariadb sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD" databaseapi'

if [ $? -eq 0 ]; then
    echo "✅ Backup restaurat correctament!"
else
    echo "❌ Error en restaurar"
    exit 1
fi
