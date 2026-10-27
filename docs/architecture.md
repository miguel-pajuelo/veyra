# Arquitectura y decisiones

## Responsabilidades

| Pieza | Responsabilidad | Estado |
|---|---|---|
| Spotify oficial | Audio, biblioteca, navegación y sesión | Instalación existente identificada |
| Spicetify y tema Veyra | Personalización y ajustes dentro del cliente | Copia Spicetify de ensayo verificada en P2; tema pendiente |
| Acompañante Windows | Observación, coordinación y diagnóstico fuera del cliente | Skipify fijado y compilado; sin integración distribuida |
| Extensión de integración | Comunicar señales y ajustes si resulta necesaria | Opcional, requiere necesidad demostrada |
| Scripts de preservación | Copiar y restaurar ajustes seleccionados | Disponibles y comprobados |

El acompañante debe permanecer fuera de Spotify para seguir activo mientras el cliente se cierra. Se ejecutará en la sesión del usuario con controles de activar, pausar, abrir Spotify, incidencias y salir.

## Decisiones vigentes

- Reutilizar antes de reescribir. Toda corrección debe responder a un requisito o un fallo demostrado.
- Mantener un único mecanismo de anuncios activo. Adblockify se compara por separado.
- Preferir configuración y detección de rutas frente a constantes de usuario o versión.
- Evaluar controles de sesión dirigidos a Spotify; no depender de teclas multimedia globales.
- No interpretar ausencia de datos, carga o títulos desconocidos como anuncio confirmado.
- Respetar pausas y cierres del usuario. Reabrir automáticamente solo como parte de un ciclo iniciado por el acompañante.
- Definir un único ciclo activo, cancelación y límites de recuperación.
- Añadir comunicación con una extensión únicamente cuando aporte una mejora comprobable.
- Guardar ajustes y diagnóstico en el equipo, excluidos del repositorio.

## Flujo objetivo

Esperando Spotify → reproducción normal → anuncio confirmado → cierre/reapertura → recuperación → reproducción normal.

Pausa, cierre manual y estado desconocido deben diferenciarse. Un fallo o un límite agotado detiene el ciclo y genera diagnóstico. Este flujo describe el comportamiento que debe implementarse y probarse en P3, no código disponible hoy.

## Interfaz

Se parte de un tema existente y se ajustan acento, contraste, densidad, paneles y navegación. El esquema del HTML es conceptual; todavía no hay diseño visual aprobado ni tema implementado. Una ventana externa persistente y un rediseño completo son ampliaciones de alcance.
