# Sonda de candidatos P2

`SkipifyProbe` ejecuta el clasificador privado del código original de Skipify sin llamar a su `Main`, constructor ni bucle de monitorización. No registra inicio automático ni controla procesos. Requiere Windows y SDK .NET 10; la restauración de paquetes necesita conexión.

Desde la raíz de Veyra, con una copia externa de [Skipify](https://github.com/adhityanadooli/Skipify) situada en una carpeta de trabajo:

```powershell
git -C <carpeta-Skipify> checkout d1a8e6aee5715174cb373519d08ed0c95e171cd1
dotnet run --project ./tests/p2/SkipifyProbe.csproj -c Release -p:SkipifySource=<carpeta-Skipify>
```

La propiedad `SkipifySource` debe apuntar a una ruta absoluta al clon. El proyecto enlaza `Program.cs` desde esa ubicación; no incluye una copia de código de terceros en Veyra. Conserva la licencia MIT del clon al usar o modificar sus fuentes.

Se muestran resultados diagnósticos para ocho entradas. Los tres desacuerdos observados con el requisito de no tratar estados desconocidos o canciones como anuncios se registran como hallazgos; el programa no transforma esos defectos del candidato en una aprobación funcional.

`SessionProbe` consulta exclusivamente las sesiones multimedia cuyo identificador de aplicación contiene Spotify. No lee títulos ni artistas. El modo de consulta no cambia la reproducción:

```powershell
dotnet run --project ./tests/p2/SessionProbe.csproj -c Release
```

Para un ensayo de reanudación dirigido a Spotify, `--play` exige exactamente una sesión coincidente y utiliza `TryPlayAsync`, sin enviar teclas globales:

```powershell
dotnet run --project ./tests/p2/SessionProbe.csproj -c Release -- --play
```
