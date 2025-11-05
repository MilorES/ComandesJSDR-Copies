#!/bin/bash
# Script per fer backups de MariaDB
# Us: ./backup.sh

set -e

# Anar a la carpeta on hi ha l'script
cd "$(dirname "$0")"

mkdir -p backups

# Nom del fitxer amb timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.sql.gz"

echo "🔄 Creant backup: $BACKUP_FILE"

# Executar mysqldump dins del contenidor
docker exec comandes_mariadb sh -c 'mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" databaseapi --single-transaction' | gzip > "backups/$BACKUP_FILE"

if [ $? -eq 0 ]; then
    SIZE=$(du -h "backups/$BACKUP_FILE" | cut -f1)
    echo "✅ Backup completat!"
    echo "   📄 Fitxer: backups/$BACKUP_FILE"
    echo "   📊 Tamany: $SIZE"
else
    echo "❌ Error en crear el backup"
    exit 1
fi
