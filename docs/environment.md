# Entorno y preservación — P0

Inspección y copia iniciales de P0 realizadas el 26 de octubre de 2026. Esta ficha pública omite identificadores de cuenta y rutas personales. Las pruebas posteriores de Spicetify y candidatos se registran en [P2](p2-validation.md).

| Elemento | Resultado |
|---|---|
| Windows | Windows 11 Pro 25H2, x64, compilación 26200.9711 |
| Spotify | Microsoft Store; ejecutable 1.3.6.1921; paquete 1.306.1921.0 |
| Git | 2.55.0.windows.3 |
| Node | 24.21.0 |
| SDK .NET | 10.0.401 |
| Spicetify | No encontrado en PATH ni ubicaciones habituales comprobadas |
| Modificaciones iniciales | No se identificó personalización Spicetify en las rutas revisadas |

## Qué se ha preservado

Cinco archivos, 18.017 bytes en total: preferencias globales, preferencias de usuario y los archivos `content_settings`, `device_settings` y `user_settings` localizados en los datos de Spotify Store.

La copia se guarda en `%LOCALAPPDATA%/Veyra/backups/<identificador>`, fuera de OneDrive y del repositorio. Su manifiesto privado contiene rutas y hashes SHA-256. El procedimiento comparó el archivo de origen antes y después de copiar con los bytes preservados.

El script [Restore-VeyraEnvironment.ps1](../scripts/Restore-VeyraEnvironment.ps1) reconstruyó los cinco archivos en una carpeta nueva bajo `%LOCALAPPDATA%/Veyra/restore-drills/` y verificó sus hashes. No se sobrescribieron preferencias reales. No había entradas Spotify/Skipify/Spicetify/Veyra en la clave Run del usuario consultada.

La copia cubre los archivos seleccionados, no una imagen completa del cliente, ni sesión autenticada, caché, descargas, cola o posición. El ensayo acredita integridad y reconstrucción de archivos; no acredita recuperación musical. [Procedimiento de restauración](restoration.md).

## Decisión de entorno

Store se conserva como referencia inicial; P0/P1 no necesitan migrar el cliente. P2 comprobará si la personalización persiste tras cierres. Si Store exige reaplicación, se preferirá la edición de escritorio, preparando conservación y recuperación antes de cambiar la instalación.

## Antecedente manual

El promotor indicó en el documento original que cerrar Spotify durante publicidad y volver a abrirlo permite continuar escuchando. Ese antecedente no se ha reproducido en P0/P1 y no se presenta como una prueba de Veyra.

## Puerta de salida

P0 completada: componentes identificados, copia privada verificada, ensayo aislado y estrategia de edición documentada. La instalación de Spicetify y los ciclos reales pertenecen a P2.
