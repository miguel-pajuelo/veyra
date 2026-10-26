# Diagnóstico

| Situación | Acción |
|---|---|
| La copia rechaza el destino | Elegir una carpeta fuera del proyecto y OneDrive; usar LOCALAPPDATA/Veyra/backups por defecto. |
| No se encuentran archivos | Comprobar que Spotify se ha utilizado en ese usuario y revisar edición/ruta; no dar por válida una copia vacía. |
| El archivo cambia durante la copia | Cerrar Spotify y repetir; la copia solo termina correctamente cuando los hashes coinciden. |
| Falla la integridad de la copia | No editar el manifiesto para ocultarlo. Buscar otra copia verificada o volver a crearla desde originales válidos. |
| El destino del ensayo ya existe | Elegir una carpeta nueva. El script evita reutilizar un ensayo anterior. |
| La restauración real detecta Spotify abierto | Cerrar el cliente y cualquier acompañante; volver a previsualizar antes de restaurar. |
| La restauración queda a medias | Revisar el error y los archivos preservados bajo LOCALAPPDATA/Veyra/pre-restore. No es una transacción de todo el conjunto. |
| Store pierde la personalización | Pendiente de P2: comprobar la advertencia de Spicetify y evaluar edición de escritorio. No automatizar reinstalaciones repetidas sin diagnóstico. |
| Se espera un tema o acompañante | Todavía no hay release instalable. Consultar ROADMAP. |

Al comunicar una incidencia, indicar sistema, versiones, pasos, resultado esperado y resultado observado. Omitir credenciales, identificadores de cuenta, preferencias completas, rutas personales y manifiestos privados.

Los futuros registros de funcionamiento deben indicar estados y errores con información suficiente para diagnosticar, conservando los datos personales fuera del contenido público.
