# Instalación y preparación

## Lo disponible hoy

La base P0/P1 permite consultar el proyecto, ejecutar sus comprobaciones y preservar preferencias. No hay instalador, acompañante ni tema Veyra para activar todavía.

Requisitos de los scripts: Windows, PowerShell 5.1 o 7, acceso a la configuración del propio usuario. Git se utiliza para desarrollo y comprobaciones de contenido. No se necesitan claves API de Spotify para los scripts actuales.

```powershell
git clone https://github.com/miguel-pajuelo/veyra.git
Set-Location veyra
& ./tests/Test-Repository.ps1
& ./tests/Test-Restoration.ps1
```

Si Windows señala que un archivo descargado está bloqueado, revisar su origen y usar `Unblock-File` sobre ese archivo concreto si corresponde. No cambiar la política de ejecución de todo el equipo como parte de esta preparación.

## Preservar antes de modificar

```powershell
$snapshot = & ./scripts/Backup-VeyraEnvironment.ps1
$snapshot
```

Guardar el valor `BackupPath` en un lugar privado. El manifiesto contiene rutas personales. [Ensayar y restaurar](restoration.md).

## Secuencia prevista para P2

1. Registrar cliente sin modificaciones y copia verificable.
2. Elegir edición y versiones, y comprobar Spicetify por separado.
3. Verificar persistencia antes de combinarlo con reinicios.
4. Compilar y revisar el acompañante antes de ejecutarlo.
5. Probar una única combinación por vez y registrar resultados.

Las órdenes de instalación de esos componentes se documentarán cuando se fijen y prueben las versiones. Este documento no presenta esa instalación futura como completada.

## Retirada actual

P0/P1 no instalan servicios, tareas ni entradas de inicio. Las copias y ensayos son archivos privados bajo `%LOCALAPPDATA%/Veyra`; conservarlos mientras puedan ser necesarios. La restauración de preferencias es independiente de retirar la carpeta del repositorio. La desinstalación de una integración futura se añadirá con su implementación.
