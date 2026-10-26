# Compatibilidad

Fecha de referencia: 26 de octubre de 2026. Identificar una versión o leer sus notas no prueba una combinación.

| Componente | Referencia | Evidencia |
|---|---|---|
| Windows 11 Pro 25H2 x64 | 26200.9711 | Inventariado; scripts de preservación ejecutados |
| Spotify Microsoft Store | Ejecutable 1.3.6.1921; paquete 1.306.1921.0 | Instalación y configuración identificadas; integración no probada |
| Spicetify | [2.46.4](https://github.com/spicetify/cli/releases/tag/v2.46.4) | Notas consultadas; no instalado |
| Skipify | [Repositorio candidato](https://github.com/adhityanadooli/Skipify) | Código revisado; commit todavía no fijado ni compilación comprobada |
| Adblockify | [Repositorio candidato](https://github.com/rxri/spicetify-extensions/tree/main/adblock) | Documentación consultada; no instalado ni probado |
| .NET | SDK 10.0.401 | Disponible; Skipify apunta a net6.0 y su adaptación/publicación se evaluará en P2 |

Spicetify 2.46.4 declara un intervalo Windows/Store de Spotify 1.2.14 a 1.3.7. Advierte que Store puede necesitar reaplicar la personalización al cerrar. La versión local está dentro del intervalo declarado; la persistencia sigue pendiente.

## Matriz funcional

| Combinación | Instalación | Persistencia | Detección/recuperación | Estado |
|---|---|---|---|---|
| Store + Spicetify + acompañante | Pendiente | Pendiente | Pendiente | No validada |
| Escritorio + Spicetify + acompañante | Pendiente | Pendiente | Pendiente | No validada |
| Spotify + Spicetify + Adblockify | Pendiente | Pendiente | Pendiente | No validada |

En P2 se fijarán versión/commit, edición de Spotify y resultados. La segunda instalación Windows de T08 no está disponible todavía como evidencia. Cada release declarará su propia matriz; no se promete compatibilidad con futuras actualizaciones.
