#!/bin/bash
# Script per fer backups de MariaDB
# Us: ./backup.sh

set -e

# Configuració: Nombre màxim de backups a mantenir
MAX_BACKUPS=10

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
    
    # Eliminar backups antics si se supera el límit
    BACKUP_COUNT=$(ls -1 backups/backup_*.sql.gz 2>/dev/null | wc -l)
    if [ $BACKUP_COUNT -gt $MAX_BACKUPS ]; then
        BACKUPS_TO_DELETE=$((BACKUP_COUNT - MAX_BACKUPS))
        echo ""
        echo "🗑️  Eliminant $BACKUPS_TO_DELETE backup(s) antic(s)..."
        ls -1t backups/backup_*.sql.gz | tail -n $BACKUPS_TO_DELETE | while read old_backup; do
            echo "   Eliminant: $old_backup"
            rm "$old_backup"
        done
        echo "✅ Mantenint només els $MAX_BACKUPS backups més recents"
    fi
else
    echo "❌ Error en crear el backup"
    exit 1
fi
