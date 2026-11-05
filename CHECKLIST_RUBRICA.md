# Lista de revisión de requisitos
Estado: "Listo" = el archivo está creado. "Por comprobar" = tú debes ejecutarlo, porque no pude correr Docker ni .NET al crear el proyecto.

| Requisito | Dónde se cumple | Cómo comprobarlo | Estado |
|---|---|---|---|
| API ASP.NET Core .NET 8 en C# | `ApiApp/` | `docker compose up --build` sin errores | Por comprobar |
| CRUD: registrar, listar, buscar por id, eliminar | `ProductosController.cs` | Comandos de la sección 4 del README | Por comprobar |
| Campos Id, Nombre, Descripción, Precio | `Models/Producto.cs` | Respuesta JSON de GET | Listo |
| Datos guardados en PostgreSQL (no en memoria) | `AppDbContext.cs`, `Program.cs` | `SELECT * FROM "Productos";` con docker exec | Por comprobar |
| Dockerfile con imagen oficial y versión fija | `Dockerfile` (sdk:8.0.404, aspnet:8.0.11) | Abrir el archivo; no hay `latest` | Listo |
| PostgreSQL 16 con versión fija, volumen, variables | `docker-compose.yml` (postgres:16.4) | `docker volume ls` | Por comprobar |
| Comunicación por nombre de servicio `database` | `docker-compose.yml` (Host=database) | Logs de api-app y prueba POST + SELECT | Por comprobar |
| Red propia | `red-proyecto` en compose | `docker network inspect` | Por comprobar |
| depends_on y healthcheck | `docker-compose.yml` | `docker ps` muestra `(healthy)` | Por comprobar |
| `docker compose up --build` / `down` | `docker-compose.yml` | Ejecutarlos | Por comprobar |
| .dockerignore, .gitignore, .env, .env.example | raíz del proyecto | `git status` no debe mostrar `.env` | Listo |
| Sin contraseñas en el código | `Program.cs` usa configuración | Buscar la contraseña en `ApiApp/` | Listo |
| GitHub Actions en `.github/workflows/docker-build.yml` | ese archivo | Pestaña "Actions" en GitHub tras el push | Por comprobar |
| README sencillo | `README.md` | Leerlo | Listo |
| Contenido del PDF de evidencias | `EVIDENCIAS.md` | Completar con tus capturas | Pendiente (tus capturas) |
