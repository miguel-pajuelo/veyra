# Veyra

Tu música. A tu manera.

Integración experimental para personalizar Spotify de escritorio en Windows, reutilizando Spicetify y un acompañante externo basado inicialmente en Skipify. Adblockify es una alternativa que se evaluará por separado.

## Estado del proyecto

26 de octubre de 2026: P0 (inventario y preservación) y P1 (base del proyecto) completados. Este repositorio contiene documentación, scripts de copia/restauración y comprobaciones de esa base. La integración de anuncios, el acompañante de bandeja y el tema Veyra todavía no están implementados ni validados. No hay una release instalable de Veyra.

El documento [Roadmap y contexto original](Veyra_Roadmap_y_Contexto_del_Proyecto.html), de 19 de octubre de 2026, se conserva sin editar como referencia histórica. El estado vigente se mantiene en [ROADMAP.md](ROADMAP.md) y [CHANGELOG.md](CHANGELOG.md).

## Objetivo de la primera versión

- Conservar Spotify oficial como reproductor y mantener su biblioteca y sesión.
- Personalizar la interfaz mediante Spicetify y un tema adaptado.
- Evaluar detección de publicidad y cierre, reapertura y recuperación mediante un acompañante externo.
- Respetar pausas y cierres voluntarios, dirigir los controles a Spotify y acotar esperas y reintentos.
- Ofrecer configuración, diagnóstico, instalación reproducible y retirada reversible.
- Publicar únicamente combinaciones de versiones probadas y sus limitaciones.

La recuperación exacta de canción, posición y cola es una hipótesis pendiente de medición. Un reinicio puede interrumpir el audio y hacer desaparecer la ventana temporalmente.

DJ, Mix, descargas, calidad reservada, soporte móvil, sustitución del motor de audio y un clon completo quedan fuera de la primera versión.

## Documentación

| Documento | Contenido |
|---|---|
| [Roadmap](ROADMAP.md) | Fases, dependencias y entregables |
| [Entorno y preservación](docs/environment.md) | Inventario público, alcance de la copia y evidencia P0 |
| [Instalación](docs/installation.md) | Requisitos y preparación disponible hoy |
| [Restauración](docs/restoration.md) | Verificación, ensayo y recuperación de preferencias |
| [Arquitectura](docs/architecture.md) | Responsabilidades y decisiones |
| [Compatibilidad](docs/compatibility.md) | Versiones identificadas y pruebas pendientes |
| [Validación](docs/validation.md) | Requisitos R01–R12 y pruebas T01–T10 |
| [Diagnóstico](docs/troubleshooting.md) | Incidencias conocidas y pasos concretos |
| [Terceros](THIRD_PARTY_NOTICES.md) | Componentes candidatos, licencias y atribuciones |

## Preparación disponible

En PowerShell para Windows, desde la raíz del repositorio:

```powershell
# Ejecutar las comprobaciones de la base, sin instalar ni controlar Spotify.
& ./tests/Test-Repository.ps1
& ./tests/Test-Restoration.ps1

# Copiar preferencias a LOCALAPPDATA/Veyra/backups, fuera de OneDrive.
$snapshot = & ./scripts/Backup-VeyraEnvironment.ps1
$snapshot

# Previsualizar la restauración sin escribir en la configuración original.
& ./scripts/Restore-VeyraEnvironment.ps1 -BackupPath $snapshot.BackupPath -WhatIf
```

La copia contiene preferencias y personalizaciones localizadas; no es una copia de sesión autenticada, caché, descargas, cola ni posición. No se deben adjuntar copias o manifiestos privados a incidencias. Consulta [restauración](docs/restoration.md) antes de recuperar archivos reales.

## Estructura

```text
docs/                  Documentación y evidencia pública sin datos privados
integration/           Alcance del acompañante futuro
theme/                 Alcance de la personalización futura
scripts/               Copia y restauración de configuración
tests/                 Integridad de la base y ensayo de restauración
.github/workflows/     Comprobaciones automáticas en Windows
```

## Desarrollo y distribución

Se prioriza reutilizar y corregir solo lo necesario. La elección final del mecanismo depende de P2; dos mecanismos de anuncios no se ejecutarán a la vez. La edición Microsoft Store se conserva como referencia inicial, y la persistencia de Spicetify se comprobará antes de decidir si conviene pasar a la edición de escritorio.

Las restricciones de Spotify registradas en el documento base forman parte de los riesgos del proyecto. La licencia del código no concede autorización del servicio ni prestaciones Premium. Veyra no está afiliado a Spotify.

Código original bajo [MIT](LICENSE). Los componentes de terceros conservan sus propias licencias y no se incluyen todavía en este repositorio.
