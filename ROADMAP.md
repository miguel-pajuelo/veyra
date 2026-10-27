# Roadmap de Veyra

Estado a 26 de octubre de 2026. Referencia: [documento original](Veyra_Roadmap_y_Contexto_del_Proyecto.html).

| Fase | Estado | Entregable y puerta de aceptación |
|---|---|---|
| P0 Entorno y preservación | Completada | Sistema y Spotify identificados, preferencias copiadas fuera de OneDrive, hashes verificados y recuperación ensayada en destino aislado. [Evidencia](docs/environment.md). |
| P1 Base pública | Completada | Repositorio público, documentación, MIT para código original, avisos de terceros, estructura y exclusiones de datos privados. |
| P2 Validar combinación | Evaluación técnica realizada; aceptación pendiente | Versiones fijadas, compilación, carga, reinicios y reproducción comprobados. Falta un evento real de publicidad y la elección funcional definitiva. [Resultados](docs/p2-validation.md). |
| P3 Integrar | Pendiente | Ejecutable configurable, rutas detectadas, controles dirigidos, límites de recuperación, bandeja, registros e inicio automático configurable. |
| P4 Personalizar | Pendiente | Tema adaptado, colores y densidad definidos, navegación y controles legibles, persistencia comprobada. |
| P5 Validar uso habitual | Pendiente | T01–T10, mediciones reales, matriz de compatibilidad y segunda instalación Windows. |
| P6 Publicar release | Pendiente | Paquete reproducible, instrucciones, restauración, resultados, versiones e incidencias conocidas. |

## P0: trabajo realizado

- Identificación de Windows, edición/origen/versión del cliente y herramientas.
- Localización de configuración sin publicar contenido de preferencias.
- Copia privada de cinco archivos de ajustes; verificación SHA-256 y reconstrucción con el script de restauración en un destino nuevo.
- Estrategia: conservar Store como referencia y probar persistencia en P2 antes de cambiar la edición.
- La observación manual de reinicio recogida en el documento permanece como antecedente del promotor, sin prueba funcional nueva.

## P1: trabajo realizado

- Base Git con README, roadmap, licencia, atribuciones y changelog.
- Documentación de arquitectura, instalación, restauración, compatibilidad, diagnóstico y validación.
- Directorios de integración, tema, scripts, pruebas y CI.
- Exclusiones para credenciales, sesiones, copias, registros y soporte privado.
- Cuenta de publicación identificada: `miguel-pajuelo`. Repositorio: [miguel-pajuelo/veyra](https://github.com/miguel-pajuelo/veyra).

## Siguiente hito: P2

La evaluación de candidatos está registrada en [P2](docs/p2-validation.md). Store funciona con el arranque de Spicetify y rutas físicas; Skipify compila pero presenta tres falsos positivos reproducidos; Adblockify carga y permite reproducción en su ensayo separado.

Quedan observar publicidad real, validar el ciclo ante ese evento y elegir el mecanismo. No se ha superado todavía la puerta funcional de P2 y no se presenta P3 como iniciado.

## Cierre del proyecto

Un tercero puede instalar, utilizar y retirar una release documentada. R01–R12 deben tener evidencia explícita; publicar esta base no acredita la integración. La estimación inicial de 20–40 horas efectivas sigue condicionada al resultado de P2 y a la disponibilidad de sesiones reales y una segunda instalación Windows.
