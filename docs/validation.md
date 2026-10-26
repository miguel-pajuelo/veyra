# Validación y trazabilidad

## Evidencia actual

P0: copia verificada de 5 archivos, 18.017 bytes; ensayo aislado de restauración 5/5 con SHA-256. P1: comprobaciones de estructura, enlaces, privacidad, sintaxis y restauración incluidas en `tests/` y CI. El registro de cada ejecución CI está vinculado a su commit.

Estas comprobaciones no prueban audio, anuncios, persistencia de Spicetify ni recuperación del cliente. T01–T10 siguen pendientes para la integración.

## Requisitos

| ID | Condición de cumplimiento | Evidencia prevista | Estado |
|---|---|---|---|
| R01 | Tema y ajustes Veyra utilizables | T01, T06 | Pendiente |
| R02 | Detección y ciclo previstos en anuncios observados | T02, T03 | Pendiente |
| R03 | Música recuperada sin intervención en los escenarios probados | T02, T06, medidas de estado | Pendiente |
| R04 | Pausa y cierre voluntario respetados | T04 | Pendiente |
| R05 | Controles destinados solo a Spotify | T05 | Pendiente |
| R06 | Instalación reproducible por terceros | T08 | Pendiente para integración |
| R07 | Retirada conservando datos personales | T09 | Base de copia disponible; retirada de integración pendiente |
| R08 | Repositorio público, licencia y atribuciones | T10 y repositorio | Base disponible; revisión de release pendiente |
| R09 | Diagnóstico accionable sin datos sensibles públicos | T07, T10 | Base documental; ejecución pendiente |
| R10 | Versiones comprobadas identificadas | T08, matriz de compatibilidad | Inventario disponible; integración pendiente |
| R11 | Inicio y segundo plano configurables sin duplicados | Prueba adicional de activación | Pendiente |
| R12 | Esperas/reintentos limitados y sin bucles | T03, T07, pruebas de estados | Pendiente |

## Pruebas de aceptación

| ID | Prueba | Criterio |
|---|---|---|
| T01 | Personalización | Tema, navegación y controles utilizables |
| T02 | Ciclos reales | Al menos 20 eventos en dos o más sesiones, anotando resultado e intervención |
| T03 | Falsos positivos | Al menos dos horas de contenido sin reinicios incorrectos en condiciones probadas |
| T04 | Acciones manuales | Pausar, reanudar y cerrar sin actuaciones indebidas |
| T05 | Convivencia | Navegador/otro reproductor no reciben órdenes destinadas a Spotify |
| T06 | Persistencia | Tema, ajustes y estado tras cierres/reaperturas |
| T07 | Fallos | Ausencia de cliente, ruta inválida, reapertura fallida y pérdida de señales |
| T08 | Instalación nueva | Segunda instalación Windows siguiendo documentación |
| T09 | Restauración | Retirar integración conservando datos personales |
| T10 | Publicación | Licencias, atribuciones, contenido público y ausencia de secretos |

Añadir comprobación de R11 al activar/desactivar inicio automático y repetir la preparación. Registrar canción, posición, cola y tiempo desde detección hasta regreso efectivo de música. No anunciar conservación exacta de esos datos antes de comprobarla.

## Registro de una prueba futura

Para cada ejecución: fecha, commit Veyra, edición/versión Spotify, versiones/commits de componentes, configuración, pasos, resultado, duración, intervención y evidencia privada o pública según corresponda. Separar hechos observados, afirmaciones de terceros y cuestiones pendientes. Una muestra superada no demuestra compatibilidad universal.

## Automatización de la base

```powershell
& ./tests/Test-Repository.ps1
& ./tests/Test-Restoration.ps1
```

La primera comprobación revisa contenido versionado; la segunda restaura datos sintéticos en una carpeta temporal, compara bytes y verifica rechazo de una copia alterada y de rutas que salen del destino. No toca la instalación de Spotify.
