# ---------- Etapa 1: compilar la API ----------
# Imagen oficial de Microsoft con el SDK de .NET 8 (version fija)
FROM mcr.microsoft.com/dotnet/sdk:8.0.404 AS build
WORKDIR /src

# Primero se copia solo el .csproj para aprovechar la cache de Docker
COPY ApiApp/ApiApp.csproj ApiApp/
RUN dotnet restore ApiApp/ApiApp.csproj

# Despues se copia el resto del codigo y se publica
COPY ApiApp/ ApiApp/
RUN dotnet publish ApiApp/ApiApp.csproj -c Release -o /app/publish --no-restore

# ---------- Etapa 2: imagen final (solo lo necesario para ejecutar) ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0.11 AS final
WORKDIR /app
COPY --from=build /app/publish .

# En .NET 8 los contenedores escuchan en el puerto 8080
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Comando que inicia la API
ENTRYPOINT ["dotnet", "ApiApp.dll"]
