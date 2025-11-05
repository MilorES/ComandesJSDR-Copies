# COPIES ComandesJSDR
ComandesJSDR és una plataforma centralitza la gestió de comandes, automatitzant processos que normalment són manuals. Gràcies a XML-UBL, permet interoperabilitat amb altres sistemes i compliment normatiu sense complicacions.

# Requisits
1. Nom del contenidor: comandes_mariadb
2. Nom de la base de dades: databaseapi

# WINDOWS (Powershell)

## Crear backup
```powershell
.\backup.ps1
```

## Restaurar
```powershell
.\restore.ps1 backup_20250105_020000.sql
```

## Configurar backup automàtic cada hora
1. Obrir programador de tasques
2. Programa: `powershell.exe` Argument: `-ExecutionPolicy Bypass -File "C:\ruta\al\script\backup.ps1"`
3. Configura el disparador (hora, dies, etc.).

# LINUX (Bash)

## Crear backup
```bash
./backup.sh
```

## Restaurar
```bash
./restore.sh backup_20250105_020000.sql.gz
```

## Configurar backup automàtic cada hora
```bash
crontab -e
0 * * * * /ruta/a/backup.sh >> /ruta/a/backups/backup.log 2>&1
```
