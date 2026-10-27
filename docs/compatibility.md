# Compatibilidad

Fecha de referencia: 26 de octubre de 2026. Identificar una versión o leer sus notas no prueba una combinación.

| Componente | Referencia | Evidencia |
|---|---|---|
| Windows 11 Pro 25H2 x64 | 26200.9711 | Inventariado; scripts de preservación ejecutados |
| Spotify Microsoft Store | Ejecutable 1.3.6.1921; paquete 1.306.1921.0 | Utilizado para pruebas de carga, reinicio y reproducción |
| Spicetify | [2.46.4](https://github.com/spicetify/cli/releases/tag/v2.46.4) | Asset verificado; copia AppX cargada con rutas físicas; persistencia de ensayo comprobada |
| Skipify | Commit d1a8e6aee5715174cb373519d08ed0c95e171cd1 | Publicación original completada; tres falsos positivos reproducidos; ciclo real pendiente |
| Adblockify | Commit 5da6cf1bb723f9efd0177f5fa4f4673b9e0c0936 | Carga y reproducción probadas por separado; eficacia ante publicidad no demostrada |
| .NET | SDK 10.0.401 | Sondas ejecutadas; adaptación privada net10.0-windows compilada; original net6.0 publicado con advertencias |

Spicetify 2.46.4 declara un intervalo Windows/Store de Spotify 1.2.14 a 1.3.7. Advierte que Store puede necesitar reaplicar la personalización al cerrar. La versión local está dentro del intervalo declarado; la persistencia sigue pendiente.

## Matriz funcional

| Combinación | Instalación | Persistencia | Detección/recuperación | Estado |
|---|---|---|---|---|
| Store + Spicetify + acompañante | Ensayo privado | Marcador vuelve a cargar con arranque específico | Sin evento real observado | Aceptación pendiente |
| Escritorio + Spicetify + acompañante | Pendiente | Pendiente | Pendiente | No validada |
| Store + Spicetify + Adblockify | Ensayo separado | Recarga sin reaplicar en la muestra | Reproducción observada; no publicidad real | Aceptación pendiente |

Las referencias se fijan en [components.lock.json](../integration/components.lock.json), con resultados en [P2](p2-validation.md). El fallo inicial de carga se debió a rutas lógicas virtualizadas; no justifica por sí solo migrar de Store. La segunda instalación Windows de T08 sigue pendiente. Cada release declarará su propia matriz; no se promete compatibilidad con futuras actualizaciones.
