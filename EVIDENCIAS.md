# Contenido para el documento PDF de evidencias
Redáctalo con tus palabras. Los textos son una base. Las capturas las tomas tú; no hay capturas inventadas.

## Portada
Nombre, curso, profesor, fecha, enlace al repositorio de GitHub.

## 1. Introducción
Hoy en día muchas aplicaciones se ejecutan en contenedores porque así funcionan igual en cualquier computador. En este trabajo se hizo una API de productos en ASP.NET Core con una base de datos PostgreSQL, cada una en su propio contenedor Docker, conectadas con Docker Compose.

## 2. Objetivo general
Desarrollar una aplicación con dos contenedores Docker (API y base de datos) que se comuniquen entre sí.

## 3. Objetivos específicos
- Crear una API REST en .NET 8 para registrar, consultar y eliminar productos.
- Guardar la información en PostgreSQL 16 con un volumen.
- Configurar Docker Compose con una red propia para que la API use el host `database`.
- Automatizar la construcción de la imagen con GitHub Actions.

## 4. Arquitectura (explicación sencilla)
El usuario hace una petición HTTP al puerto 8080. El contenedor `api-app` la recibe y le pide o guarda los datos al contenedor `database` por la red `red-proyecto`, usando el nombre `database`. PostgreSQL guarda los datos en el volumen `postgres_data`.

## 5. Diagrama
```
 Navegador / curl
        |  http://localhost:8080
        v
 +------------------+   red-proyecto   +--------------------+
 |  api-app         | ---------------> |  database          |
 |  ASP.NET .NET 8  |  Host=database   |  PostgreSQL 16     |
 |  puerto 8080     |  puerto 5432     |  volumen:          |
 +------------------+                  |  postgres_data     |
                                       +--------------------+
```
(Puedes redibujarlo en draw.io o Word.)

## 6 a 11. Evidencias: capturas que debes tomar
| # | Sección | Comando | Qué debe verse en la captura |
|---|---|---|---|
| 6 | docker build | `docker compose build` | Fin sin errores, imagen construida |
| 7 | docker compose up | `docker compose up --build` | Ambos servicios iniciando y "Conexion con PostgreSQL correcta." |
| 8 | docker ps | `docker ps` | `api-app` y `database` en ejecución, database `(healthy)` |
| 9 | docker network inspect | `docker network ls` y luego `docker network inspect <red>` | Los dos contenedores dentro de la misma red |
| 10 | Comunicación API-PostgreSQL | POST de un producto, GET, y `docker exec ... SELECT` (README sección 5) | El producto enviado por la API aparece en la tabla de PostgreSQL |
| 11 | GitHub Actions | Subir el repo a GitHub | Pestaña Actions con el workflow en verde |

## 12. Conclusiones (ideas para completar)
- Qué aprendiste sobre Docker Compose y las redes entre contenedores.
- Por qué se usa el nombre `database` y no `localhost`.
- Para qué sirven el volumen y el healthcheck.
- Qué ventaja da automatizar con GitHub Actions.
- Dificultades que tuviste y cómo las resolviste.

## 13. Referencias (APA 7). Verifica las fechas y URLs al consultarlas.
- Docker Inc. (s. f.). *Docker Compose overview*. https://docs.docker.com/compose/
- Docker Inc. (s. f.). *Dockerfile reference*. https://docs.docker.com/reference/dockerfile/
- GitHub. (s. f.). *GitHub Actions documentation*. https://docs.github.com/actions
- Microsoft. (s. f.). *Tutorial: Create a web API with ASP.NET Core*. https://learn.microsoft.com/aspnet/core/tutorials/first-web-api
- Microsoft. (s. f.). *Containerize a .NET app*. https://learn.microsoft.com/dotnet/core/docker/build-container
- The PostgreSQL Global Development Group. (s. f.). *PostgreSQL 16 documentation*. https://www.postgresql.org/docs/16/
