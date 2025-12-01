# COPIES ComandesJSDR

ComandesJSDR és una plataforma que centralitza la gestió de comandes, automatitzant processos que normalment són manuals. Gràcies a XML-UBL, permet interoperabilitat amb altres sistemes i compliment normatiu sense complicacions.

Aquest repositori conté scripts per fer còpies de seguretat automàtiques de la base de dades MariaDB.

## Requisits

1. Nom del contenidor: `comandes_mariadb`
2. Nom de la base de dades: `databaseapi`
3. Docker en execució amb el contenidor MariaDB actiu

## Configuració

Edita les variables al principi de cada script segons les teves necessitats:

- **`MAX_BACKUPS`**: Nombre màxim de còpies a mantenir en cada destí (per defecte: 10)
- **`BACKUP_DESTINATIONS`**: Llista de destins separats per comes on es guardaran les còpies

### Exemple de configuració de destins:

**Windows (PowerShell):**
```powershell
$MAX_BACKUPS = 10
$BACKUP_DESTINATIONS = "backups,D:\Backups,\\servidor\backups"
```

**Linux/Mac (Bash):**
```bash
MAX_BACKUPS=10
BACKUP_DESTINATIONS="backups,/mnt/nas/backups,/media/usb/backups"
```

## WINDOWS (PowerShell)

### Crear backup
```powershell
.\backup.ps1
```

El script:
- Crea una còpia de la base de dades
- La guarda en tots els destins configurats
- Elimina automàticament les còpies més antigues si se supera `MAX_BACKUPS`
- Mostra informació detallada del procés

### Restaurar

**Des de la carpeta per defecte (backups/):**
```powershell
.\restore.ps1 backup_20250105_020000.sql
```

**Des d'un altre destí (ruta completa):**
```powershell
.\restore.ps1 D:\Backups\backup_20250105_020000.sql
.\restore.ps1 \\servidor\backups\backup_20250105_020000.sql
```

### Configurar backup automàtic

1. Obrir el **Programador de tasques** de Windows
2. Crear una tasca nova:
   - **Programa**: `powershell.exe`
   - **Argument**: `-ExecutionPolicy Bypass -File "C:\ruta\al\script\backup.ps1"`
3. Configura el disparador (hora, dies, etc.)

## LINUX (Bash)

### Crear backup
```bash
./backup.sh
```

El script:
- Crea una còpia comprimida (.gz) de la base de dades
- La guarda en tots els destins configurats
- Elimina automàticament les còpies més antigues si se supera `MAX_BACKUPS`
- Mostra informació detallada del procés

### Restaurar

**Des de la carpeta per defecte (backups/):**
```bash
./restore.sh backup_20250105_020000.sql.gz
```

**Des d'un altre destí (ruta completa):**
```bash
./restore.sh /mnt/nas/backups/backup_20250105_020000.sql.gz
./restore.sh ../altres_backups/backup_20250105_020000.sql.gz
```

### Configurar backup automàtic

Per programar còpies diàries a les 2:00 AM:

```bash
crontab -e
```

Afegeix la línia següent:
```
0 2 * * * /ruta/completa/a/backup.sh >> /ruta/a/backups/backup.log 2>&1
```

## Característiques

- **Múltiples destins**: Guarda còpies en diverses ubicacions simultàniament
- **Rotació automàtica**: Manté només les N còpies més recents en cada destí
- **Manejo d'errors**: Continua amb altres destins si un falla
- **Feedback visual**: Mostra el progrés de cada operació
- **Compressió**: Les còpies en Linux es comprimeixen automàticament (gzip)
- **Timestamps**: Cada còpia té la data i hora de creació
- **Restauració flexible**: Accepta tant noms de fitxer (busca a `backups/`) com rutes completes

## Exemples de sortida

```
[INFO] Creant backup: backup_20250201_140530.sql.gz
[OK] Backup creat correctament
     Tamany: 2.5 MB

[INFO] Copiant a: backups
       Copiat correctament

[INFO] Copiant a: /mnt/nas/backups
       Copiat correctament
       Eliminant 2 backup(s) antic(s)...
       Mantenint només els 10 backups més recents

[OK] Procés completat correctament
```

## Notes importants

- Les còpies es creen amb el format: `backup_YYYYMMDD_HHMMSS.sql[.gz]`
- Cada destí manté la seva pròpia rotació de còpies
- Les rutes poden ser relatives (a la carpeta de l'script) o absolutes
- Es recomana provar la restauració periòdicament per verificar les còpies
