# P2 — Evaluación técnica de candidatos

Fecha: 26 de octubre de 2026. Resultado: evaluación de carga, compilación, persistencia y reproducción realizada; puerta de aceptación funcional de P2 pendiente.

No se ha observado un anuncio real en la muestra registrada y no se ha completado un ciclo automático sobre publicidad real. Por ello, ninguna combinación se declara todavía aprobada como mecanismo por defecto.

## Versiones fijadas

Las fuentes, commits y hashes se registran en [components.lock.json](../integration/components.lock.json). Las fuentes de terceros, herramientas, binarios, copias y registros permanecen fuera del contenido público.

| Componente | Versión / commit | Resultado |
|---|---|---|
| Spotify Store | Ejecutable 1.3.6.1921; paquete 1.306.1921.0 | Cliente utilizado; sesión conservada |
| Spicetify | 2.46.4 / c3fd98f6fbf922ae944d1ecd64f97c380d04368e | ZIP Windows x64 verificado frente al SHA-256 del asset oficial; aplicado sobre una copia local AppX |
| Skipify | d1a8e6aee5715174cb373519d08ed0c95e171cd1 | Publicación original net6.0, win-x64 autocontenida, completada con advertencias |
| Adblockify | 5da6cf1bb723f9efd0177f5fa4f4673b9e0c0936 | Código original cargado por separado; inicialización y reproducción observadas |

## Hallazgo principal: rutas físicas y Store

El primer arranque con una ruta lógica bajo LOCALAPPDATA no cargó la personalización. Windows estaba redirigiendo esos archivos a la caché privada del anfitrión empaquetado. La aplicación Spotify no veía la misma ubicación al recibir la ruta lógica.

Tras resolver la ruta física del archivo de configuración y usar su directorio AppX en el argumento `--app-directory`, Spotify cargó la extensión de diagnóstico. La línea de comandos del proceso confirmó el argumento y la interfaz mostró el marcador de prueba.

La personalización volvió a cargar en los reinicios de prueba sin ejecutar `apply` de nuevo. También se repitió con Adblockify y se verificó que su hash seguía siendo el original. La muestra no demuestra persistencia tras una actualización ni al usar un acceso directo normal que omite ese argumento.

Se conserva Microsoft Store. Se descargó un instalador oficial de escritorio con firma válida de Spotify AB, pero la instalación silenciosa terminó con código 29 y no apareció una instalación de escritorio. No se desinstaló Store. El intento posterior de extracción se canceló sin archivos extraídos. El problema de rutas se resolvió sin migrar.

El script de copias devuelve ahora una ruta física verificable mediante `GetFinalPathNameByHandle`, para que la copia pueda abrirse desde otra aplicación o desde PowerShell fuera del anfitrión. [Procedimiento](restoration.md).

## Skipify: compilación y defectos reproducidos

La compilación original terminó correctamente. El SDK advirtió que net6.0 carece de soporte; también produjo advertencias de nulabilidad y de llamadas Windows en un destino genérico.

La [sonda de candidatos](../tests/p2/README.md) ejecutó el método original de clasificación sin llamar a Main, constructor ni monitor:

| Entrada sintética | Resultado original | Evaluación |
|---|---|---|
| Vacía | No anuncio | Correcto |
| Spotify Free / Spotify Premium | No anuncio | Correcto |
| Artist - Song | No anuncio | Correcto |
| Advertisement | Anuncio | Correcto para el marcador explícito |
| Spotify | Anuncio | Falso positivo de estado genérico/carga |
| Artist - Sponsored | Anuncio | Falso positivo de canción |
| Loading | Anuncio | Falso positivo de estado desconocido |

Resultado: tres desacuerdos en ocho entradas. La revisión también confirma que guarda el título ya actualizado al detectar el anuncio, registra inicio automático al ejecutar Main y utiliza teclas multimedia globales.

Se compiló una adaptación privada de ensayo en net10.0-windows10.0.19041.0 con Hosting 10.0.0, cero errores y seis advertencias. Se acotó a un único ciclo, sin registro de inicio, sin teclas globales, con marcadores explícitos de publicidad, ruta/argumentos configurables y reanudación dirigida a la sesión Spotify. Se observó durante reproducción, pero no recibió un anuncio real ni completó el ciclo. No se incorpora como implementación de P3 ni se distribuye ese ejecutable.

## Adblockify: prueba independiente

Se detuvo el monitor antes de activar Adblockify. Se copió el archivo original fijado por hash, sin modificar su algoritmo. Una extensión de diagnóstico independiente registró estados, presencia del estilo de Adblockify, llamadas a los gestores y errores con prefijo propio.

La muestra con Adblockify contiene 334 lecturas. Se observó su estilo de inicialización, hasta 49 llamadas instrumentadas a `disable()` y cero errores propios registrados por la sonda. Se observó reproducción y carga después de un reinicio sin reaplicar archivos.

Esas llamadas describen ejecución de código; no equivalen a 49 anuncios bloqueados. La ausencia de anuncios en la muestra tampoco permite atribuirle eficacia. El detector por ventanas estaba detenido durante esta comparación.

## Repetición de reproducción solicitada por el promotor

Windows expuso exactamente una sesión multimedia Spotify. `TryPlayAsync` devolvió true y el estado pasó a Playing. En dos lecturas del mismo tema y la misma carga, el progreso pasó de 77.495 a 122.428 ms: avance de 44.933 ms. La telemetría dejó de indicar buffering. La segunda lectura estaba pausada; no se presenta como una reproducción ininterrumpida durante todo el intervalo.

Se repitió también el reinicio y la reanudación dirigida: nueva carga de la extensión, Adblockify presente, hash conservado y `TryPlayAsync` true. Se observó buffering inicial de carga; no se infiere audio audible únicamente a partir del estado Playing.

## Alcance de la evidencia

- 751 lecturas locales en total, distribuidas entre cuatro cargas y cinco identificadores de tema anonimizados.
- Cero muestras identificadas como publicidad real. Los intervalos incluyen pausas y huecos; no constituyen una escucha continua de toda la duración entre la primera y última fecha.
- La sonda registró estados y hashes de identificadores, sin publicar títulos, artistas, cuenta, sesiones ni registros privados.
- La carga del marcador es evidencia de Spicetify activo; no es un tema Veyra aprobado.
- Los ensayos no sustituyen T02/T03 ni las pruebas de uso habitual de P5.

## Puerta pendiente y siguiente decisión

La revisión automática rechazó el comando que retiraba Adblockify y volvía a arrancar el monitor de ensayo. El motivo devuelto fue únicamente `blocked by policy`. La acción no se repitió. Se retiraron las extensiones activas de prueba, se detuvo el servidor local y se volvió a abrir Spotify por su arranque normal.

Antes de cerrar P2:

1. Observar y registrar una señal real de anuncio en la versión objetivo.
2. Completar un ensayo autorizado del ciclo y medir reanudación e intervención, o demostrar el comportamiento alternativo ante un evento real.
3. Elegir un único mecanismo por resultados funcionales.

Decisión técnica vigente: conservar Store con arranque explícito y rutas físicas para las pruebas; descartar Skipify original como componente listo para activar; mantener ambos candidatos para la comparación funcional pendiente. Adblockify carga y permite una experiencia sin reinicios en esta muestra, pero todavía no se aprueba como mecanismo por defecto.

Después de superar esa puerta, P3 debe incorporar configuración, estados desconocidos, controles dirigidos, límites, diagnóstico e inicio configurable. No hace falta reabrir la investigación general ni migrar de edición por el fallo inicial de rutas.

## Auditoría de cierre — 27 de octubre de 2026

Se ha revisado el expediente existente y se ha vuelto a identificar el cliente instalado: Store 1.3.6.1921, sin cambio de versión respecto al ensayo. No hay una captura nueva de publicidad real ni un ciclo de recuperación completado que permita cambiar el resultado funcional. No se ha relanzado el monitor cuyo arranque fue rechazado.

| Condición de salida de P2 | Evidencia disponible | Dictamen |
|---|---|---|
| Versiones y fuentes fijadas | Lock con commits y hashes | Cumplida |
| Compilación del candidato inicial | Publicación original y adaptación de ensayo registradas | Cumplida |
| Carga y persistencia de personalización | Marcador, arranques específicos y hashes de la muestra | Cumplida en el alcance ensayado |
| Comparación independiente | Skipify y Adblockify no actuaron simultáneamente | Realizada, con alcance funcional limitado |
| Detección ante publicidad real | Cero muestras de anuncios en los registros | No demostrada |
| Recuperación o tratamiento del evento real | No existe un ciclo registrado ante publicidad real | No demostrado |
| Mecanismo por defecto respaldado por prueba funcional | Ambos candidatos sin superar la condición anterior | Sin aprobar |

El resultado de esta auditoría es **P2 pendiente de aceptación funcional**. La revisión de documentación y las pruebas de la base no sustituyen las tres condiciones finales. P3 no queda habilitada por esta auditoría. No se descarta la viabilidad del proyecto a partir de la ausencia de anuncios en una muestra.
