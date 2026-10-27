# Copia y restauración

Los scripts requieren Windows PowerShell 5.1 o PowerShell 7 en Windows. No requieren ejecutar Veyra ni instalar modificaciones en Spotify.

## Crear una copia

```powershell
$snapshot = & ./scripts/Backup-VeyraEnvironment.ps1
$snapshot.BackupPath
```

El destino predeterminado es `%LOCALAPPDATA%/Veyra/backups/<identificador>`. El script rechaza destinos dentro del proyecto o las raíces de OneDrive conocidas. Conserva preferencias Spotify y, si existen, configuración y carpetas Themes/Extensions/CustomApps de Spicetify en las ubicaciones revisadas.

En un proceso empaquetado, Windows puede redirigir esa ubicación a la caché privada del anfitrión. `BackupPath` devuelve ahora la ruta física mediante un identificador de archivo de Windows. Se debe utilizar ese valor cuando otra aplicación o una sesión normal de PowerShell acceda a la copia; la ruta lógica puede apuntar a otro lugar fuera del anfitrión.

Cada archivo se compara antes y después de copiar con SHA-256. Si cambia repetidamente, el script falla: cerrar Spotify y repetir. Una copia fallida sin manifiesto válido no debe usarse. El registro de inicio se guarda únicamente como referencia privada; no se modifica ni restaura automáticamente.

## Previsualizar sin modificar

```powershell
& ./scripts/Restore-VeyraEnvironment.ps1 -BackupPath $snapshot.BackupPath -WhatIf
```

Se comprueban el manifiesto, los destinos y todos los hashes antes de escribir. `-WhatIf` muestra las operaciones y no copia archivos a sus destinos.

## Ensayar en una carpeta aislada

```powershell
$drillPath = Join-Path $env:LOCALAPPDATA ('Veyra/restore-drills/' + [guid]::NewGuid().ToString('N'))
& ./scripts/Restore-VeyraEnvironment.ps1 -BackupPath $snapshot.BackupPath -DestinationDirectory $drillPath
```

El destino debe ser nuevo, y no puede estar dentro de la copia ni de una fuente original. El script conserva la estructura y verifica los archivos reconstruidos. No abre ni cierra Spotify.

## Restaurar las preferencias originales

1. Cerrar Spotify y cualquier acompañante que pueda abrirlo o cambiar ajustes.
2. Identificar una copia verificada correspondiente a esa instalación.
3. Previsualizar con `-WhatIf` y comprobar los destinos.
4. Ejecutar sin `-DestinationDirectory` ni `-WhatIf`:

```powershell
& ./scripts/Restore-VeyraEnvironment.ps1 -BackupPath $snapshot.BackupPath
```

La restauración real se rechaza si Spotify sigue abierto. Antes de sobrescribir un archivo existente, se copia su estado actual a `%LOCALAPPDATA%/Veyra/pre-restore/<identificador>` y se verifica. La operación no es una transacción de todo el conjunto: un error puede dejar archivos ya restaurados, y los anteriores quedan preservados para revisión.

No se eliminan cachés ni se prometen credenciales o reproducción recuperadas. Este script restaura archivos de preferencias; la retirada de una futura instalación de Spicetify o del acompañante tendrá su procedimiento específico tras P2/P3. No hay esas modificaciones instaladas por P0/P1.

## Resultado del ensayo P0

Se restauraron 5 de 5 archivos y coincidieron sus hashes. Los originales no se sobrescribieron. La ruta privada concreta está registrada localmente, fuera del contenido público. Guarda el valor de `BackupPath`: el script no elige automáticamente una copia por fecha.
