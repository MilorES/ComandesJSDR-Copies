# Script per restaurar backup de MariaDB
# Us: .\restore.ps1 backup_20250105_020000.sql
#     .\restore.ps1 D:\Backups\backup_20250105_020000.sql

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile
)

$ErrorActionPreference = "Stop"

# Si la ruta conté : o \ o /, usar-la directament
# Sinó, buscar a la carpeta backups/ per defecte
if ($BackupFile -match '[:\\]' -or (Test-Path $BackupFile)) {
    $fullPath = $BackupFile
} else {
    $fullPath = "backups/$BackupFile"
}

if (-not (Test-Path $fullPath)) {
    Write-Host "[ERROR] No es troba el fitxer $fullPath" -ForegroundColor Red
    exit 1
}

Write-Host "[ADVERTIMENT] Això sobreescriurà la base de dades actual" -ForegroundColor Yellow
Write-Host "              Fitxer: $fullPath"
$confirm = Read-Host "¿Continuar? (S/N)"

if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "[INFO] Cancel·lat" -ForegroundColor Red
    exit 0
}

Write-Host "[INFO] Restaurant backup..." -ForegroundColor Cyan

# Restaurar des del contenidor
Get-Content $fullPath | docker exec -i comandes_mariadb sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD" databaseapi'

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Backup restaurat correctament" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Error en restaurar" -ForegroundColor Red
    exit 1
}
