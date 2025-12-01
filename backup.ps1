# Script per fer backups de MariaDB
# Us: .\backup.ps1

$ErrorActionPreference = "Stop"

# Configuració: Nombre màxim de backups a mantenir
$MAX_BACKUPS = 10

# Configuració: Destins de backup separats per comes
# Exemple: "backups,D:\Backups,\\servidor\backups"
$BACKUP_DESTINATIONS = "backups"

# Obtenir la ruta actual
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Nom del fitxer amb timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "backup_$timestamp.sql"

Write-Host "[INFO] Creant backup: $backupFile" -ForegroundColor Cyan

# Crear backup temporal
$tempBackup = Join-Path $env:TEMP $backupFile
docker exec comandes_mariadb sh -c 'mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" databaseapi --single-transaction' > $tempBackup

if ($LASTEXITCODE -eq 0) {
    $size = (Get-Item $tempBackup).Length / 1MB
    Write-Host "[OK] Backup creat correctament" -ForegroundColor Green
    Write-Host "     Tamany: $([math]::Round($size, 2)) MB"
    Write-Host ""
    
    # Copiar a cada destí
    $destinations = $BACKUP_DESTINATIONS -split ',' | ForEach-Object { $_.Trim() }
    
    foreach ($dest in $destinations) {
        # Convertir a ruta absoluta si és relativa
        if (-not [System.IO.Path]::IsPathRooted($dest)) {
            $dest = Join-Path $scriptDir $dest
        }
        
        Write-Host "[INFO] Copiant a: $dest" -ForegroundColor Cyan
        
        # Crear carpeta si no existeix
        if (-not (Test-Path $dest)) {
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
        }
        
        $destFile = Join-Path $dest $backupFile
        
        try {
            Copy-Item $tempBackup -Destination $destFile -Force
            Write-Host "       Copiat correctament" -ForegroundColor Green
            
            # Eliminar backups antics en aquest destí
            $allBackups = Get-ChildItem -Path $dest -Filter "backup_*.sql" | Sort-Object LastWriteTime -Descending
            $backupCount = $allBackups.Count
            
            if ($backupCount -gt $MAX_BACKUPS) {
                $backupsToDelete = $backupCount - $MAX_BACKUPS
                Write-Host "       Eliminant $backupsToDelete backup(s) antic(s)..." -ForegroundColor Yellow
                $allBackups | Select-Object -Skip $MAX_BACKUPS | ForEach-Object {
                    Remove-Item $_.FullName -Force
                }
                Write-Host "       Mantenint només els $MAX_BACKUPS backups més recents" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "       [ERROR] Error al copiar a $dest : $_" -ForegroundColor Yellow
        }
        
        Write-Host ""
    }
    
    # Eliminar backup temporal
    Remove-Item $tempBackup -Force
    Write-Host "[OK] Procés completat correctament" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Error en crear el backup" -ForegroundColor Red
    exit 1
}
