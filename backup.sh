#!/bin/bash
# Script per fer backups de MariaDB
# Us: ./backup.sh

set -e

# Configuració: Nombre màxim de backups a mantenir
MAX_BACKUPS=10

# Configuració: Destins de backup separats per comes
# Exemple: "backups,/mnt/disco_extern/backups,/media/usb/backups"
BACKUP_DESTINATIONS="backups"

# Anar a la carpeta on hi ha l'script
cd "$(dirname "$0")"

# Nom del fitxer amb timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.sql.gz"

echo "🔄 Creant backup: $BACKUP_FILE"

# Crear backup temporal
TEMP_BACKUP="/tmp/$BACKUP_FILE"
docker exec comandes_mariadb sh -c 'mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" databaseapi --single-transaction' | gzip > "$TEMP_BACKUP"

if [ $? -eq 0 ]; then
    SIZE=$(du -h "$TEMP_BACKUP" | cut -f1)
    echo "✅ Backup creat!"
    echo "   📊 Tamany: $SIZE"
    echo ""
    
    # Copiar a cada destí
    IFS=',' read -ra DESTINATIONS <<< "$BACKUP_DESTINATIONS"
    for dest in "${DESTINATIONS[@]}"; do
        # Eliminar espais en blanc
        dest=$(echo "$dest" | xargs)
        
        echo "📁 Copiant a: $dest"
        mkdir -p "$dest"
        cp "$TEMP_BACKUP" "$dest/$BACKUP_FILE"
        
        if [ $? -eq 0 ]; then
            echo "   ✅ Copiat correctament"
            
            # Eliminar backups antics en aquest destí
            BACKUP_COUNT=$(ls -1 "$dest"/backup_*.sql.gz 2>/dev/null | wc -l)
            if [ $BACKUP_COUNT -gt $MAX_BACKUPS ]; then
                BACKUPS_TO_DELETE=$((BACKUP_COUNT - MAX_BACKUPS))
                echo "   🗑️  Eliminant $BACKUPS_TO_DELETE backup(s) antic(s)..."
                ls -1t "$dest"/backup_*.sql.gz | tail -n $BACKUPS_TO_DELETE | while read old_backup; do
                    rm "$old_backup"
                done
                echo "   ✅ Mantenint només els $MAX_BACKUPS backups més recents"
            fi
        else
            echo "   ⚠️  Error al copiar a $dest"
        fi
        echo ""
    done
    
    # Eliminar backup temporal
    rm "$TEMP_BACKUP"
    echo "🎉 Procés completat!"
else
    echo "❌ Error en crear el backup"
    exit 1
fi
