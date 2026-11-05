# API de Productos con Docker

## De qué trata
Es una API REST sencilla para administrar productos (registrar, consultar y eliminar). Los datos se guardan en una base de datos PostgreSQL. Todo corre en **dos contenedores Docker** que se comunican entre sí.

## Objetivo
Practicar cómo dos contenedores (una API y una base de datos) se comunican usando Docker Compose, y automatizar la construcción de la imagen con GitHub Actions.

## Herramientas
C# · ASP.NET Core Web API (.NET 8) · PostgreSQL 16 · Docker y Docker Compose · GitHub y GitHub Actions · Visual Studio Code

## Los dos contenedores
| Contenedor | Para qué sirve |
|---|---|
| `api-app` | Es la API en .NET 8. Recibe las peticiones y guarda/consulta productos. |
| `database` | Es PostgreSQL 16. Guarda los productos. Sus datos quedan en el volumen `postgres_data`. |

La API se conecta a la base usando el **nombre del servicio** (`Host=database`), por la red `red-proyecto` definida en `docker-compose.yml`.

## Archivos principales
- `ApiApp/Models/Producto.cs`: define qué datos tiene un producto.
- `ApiApp/Data/AppDbContext.cs`: conecta la API con PostgreSQL.
- `ApiApp/Controllers/ProductosController.cs`: los 4 endpoints.
- `ApiApp/Program.cs`: arranca la API y crea la tabla si no existe.
- `Dockerfile`: receta para construir la imagen de la API.
- `docker-compose.yml`: define los dos contenedores, la red, el volumen y el healthcheck.
- `.env` / `.env.example`: contraseñas y configuración (`.env` no se sube a GitHub).
- `.github/workflows/docker-build.yml`: pipeline que construye la imagen en cada push.

## 1. Configurar el .env
Si no existe `.env`, cópialo del ejemplo y cambia la contraseña:
```powershell
copy .env.example .env      # Windows
cp .env.example .env        # Linux / Mac
```

## 2. Construir y levantar los contenedores
```bash
docker compose build
docker compose up --build
```
Para correr en segundo plano: `docker compose up --build -d`

## 3. Comprobar que funcionan
```bash
docker ps
docker compose logs api-app
docker network inspect <nombre-del-proyecto>_red-proyecto
```
Debes ver `api-app` y `database` en `docker ps`, y en los logs el mensaje "Conexion con PostgreSQL correcta."
(Para saber el nombre exacto de la red usa `docker network ls`.)

## 4. Probar la API
También puedes usar Swagger en el navegador: http://localhost:8080/swagger

**PowerShell (Windows, terminal de VS Code):**
```powershell
# Registrar un producto
Invoke-RestMethod -Method Post -Uri http://localhost:8080/api/productos -ContentType "application/json" -Body '{"nombre":"Teclado","descripcion":"Teclado USB","precio":25.50}'

# Consultar todos
Invoke-RestMethod http://localhost:8080/api/productos

# Consultar por id
Invoke-RestMethod http://localhost:8080/api/productos/1

# Eliminar
Invoke-RestMethod -Method Delete -Uri http://localhost:8080/api/productos/1
```

**curl (Linux / Mac / Git Bash):**
```bash
curl -X POST http://localhost:8080/api/productos -H "Content-Type: application/json" -d '{"nombre":"Teclado","descripcion":"Teclado USB","precio":25.50}'
curl http://localhost:8080/api/productos
curl http://localhost:8080/api/productos/1
curl -X DELETE http://localhost:8080/api/productos/1
```

## 5. Prueba de comunicación entre contenedores
1. Registra un producto con POST (paso 4).
2. Mira directamente dentro de PostgreSQL (carga el .env en tu terminal o escribe los valores):
```bash
docker exec -it database psql -U usuario_productos -d productos_db -c 'SELECT * FROM "Productos";'
```
Si el producto aparece ahí, la API (contenedor 1) guardó el dato en PostgreSQL (contenedor 2).
3. Prueba de persistencia: `docker compose down`, luego `docker compose up -d` y consulta de nuevo `GET /api/productos`. El producto sigue ahí gracias al volumen.
4. Para borrar también los datos: `docker compose down -v`.

## 6. Detener
```bash
docker compose down
```
