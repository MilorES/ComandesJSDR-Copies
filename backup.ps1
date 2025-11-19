# Script per fer backups de MariaDB
# Us: .\backup.ps1

$ErrorActionPreference = "Stop"

# Configuració: Nombre màxim de backups a mantenir
$MAX_BACKUPS = 10

# Obtenir la ruta actual
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Crear la carpeta 'backups' dins aquesta ruta
$backupPath = Join-Path $scriptDir "backups"

# Crear la carpeta si no existeix (sense errors ni esborrats)
mkdir $backupPath -Force | Out-Null

# Nom del fitxer amb timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "backup_$timestamp.sql"

Write-Host "🔄 Creant backup: $backupFile" -ForegroundColor Cyan

# Executar mysqldump dins del contenidor
docker exec comandes_mariadb sh -c 'mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" databaseapi --single-transaction' > "backups/$backupFile"

if ($LASTEXITCODE -eq 0) {
    $size = (Get-Item "backups/$backupFile").Length / 1MB
    Write-Host "✅ Backup completat!" -ForegroundColor Green
    Write-Host "   📄 Fitxer: backups/$backupFile"
    Write-Host "   📊 Tamany: $([math]::Round($size, 2)) MB"
    
    # Eliminar backups antics si se supera el límit
    $allBackups = Get-ChildItem -Path "backups" -Filter "backup_*.sql" | Sort-Object LastWriteTime -Descending
    $backupCount = $allBackups.Count
    
    if ($backupCount -gt $MAX_BACKUPS) {
        $backupsToDelete = $backupCount - $MAX_BACKUPS
        Write-Host ""
        Write-Host "🗑️  Eliminant $backupsToDelete backup(s) antic(s)..." -ForegroundColor Yellow
        $allBackups | Select-Object -Skip $MAX_BACKUPS | ForEach-Object {
            Write-Host "   Eliminant: $($_.Name)"
            Remove-Item $_.FullName -Force
        }
        Write-Host "✅ Mantenint només els $MAX_BACKUPS backups més recents" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Error en crear el backup" -ForegroundColor Red
    exit 1
}
