#!/usr/bin/env bash
# Prueba de integracion: levanta los dos contenedores y comprueba que se comunican.
# Si algo falla, el script termina con codigo 1 y Jenkins marca el build como FALLIDO.
set -euo pipefail

# Si existe un .env (uso local) se carga. En Jenkins las variables vienen de las credenciales.
if [ -f .env ]; then set -a; . ./.env; set +a; fi

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-ci-productos}"
RED="${COMPOSE_PROJECT_NAME}_red-proyecto"
NOMBRE="Prueba-Jenkins-${BUILD_NUMBER:-local}"

fallar() {
  echo ""
  echo "PRUEBA FALLIDA: $1"
  exit 1
}

# Ejecuta curl dentro de la red de Docker, igual que lo haria otro contenedor del proyecto
curl_en_red() {
  docker run --rm --network "$RED" curlimages/curl:8.10.1 -s --max-time 10 "$@"
}

echo "== 1. Levantando los contenedores (docker compose up)"
docker compose down -v --remove-orphans || true
docker compose up -d || fallar "docker compose up no pudo iniciar los servicios"

echo "== 2. Comprobando que api-app y database estan en la misma red"
CONTENEDORES=$(docker network inspect "$RED" --format '{{range .Containers}}{{.Name}} {{end}}') \
  || fallar "no existe la red $RED"
echo "Contenedores en la red: $CONTENEDORES"
echo "$CONTENEDORES" | grep -q "api-app"  || fallar "api-app no esta en la red"
echo "$CONTENEDORES" | grep -q "database" || fallar "database no esta en la red"

echo "== 3. Esperando a que la API responda (se llama por el nombre del servicio: api-app)"
LISTA=no
for intento in $(seq 1 30); do
  CODIGO=$(curl_en_red -o /dev/null -w "%{http_code}" http://api-app:8080/api/productos || true)
  if [ "$CODIGO" = "200" ]; then LISTA=si; break; fi
  echo "   intento $intento/30: la API responde '$CODIGO', espero 3 segundos"
  sleep 3
done
[ "$LISTA" = "si" ] || fallar "la API no respondio (probablemente no logra conectarse a database)"

echo "== 4. POST: registrar un producto (la API lo guarda en PostgreSQL)"
RESPUESTA=$(curl_en_red -X POST http://api-app:8080/api/productos \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"$NOMBRE\",\"descripcion\":\"creado por Jenkins\",\"precio\":1500}" \
  -w "\n%{http_code}") || fallar "no se pudo enviar el POST"
CODIGO=$(echo "$RESPUESTA" | tail -n 1)
CUERPO=$(echo "$RESPUESTA" | head -n 1)
echo "Respuesta ($CODIGO): $CUERPO"
[ "$CODIGO" = "201" ] || fallar "el POST debia responder 201 y respondio $CODIGO"
ID=$(echo "$CUERPO" | sed -n 's/.*"id":\([0-9][0-9]*\).*/\1/p')
[ -n "$ID" ] || fallar "no se pudo leer el id del producto creado"

echo "== 5. GET por id: consultar el producto"
RESPUESTA=$(curl_en_red http://api-app:8080/api/productos/"$ID" -w "\n%{http_code}") \
  || fallar "no se pudo enviar el GET"
CODIGO=$(echo "$RESPUESTA" | tail -n 1)
CUERPO=$(echo "$RESPUESTA" | head -n 1)
echo "Respuesta ($CODIGO): $CUERPO"
[ "$CODIGO" = "200" ] || fallar "el GET debia responder 200 y respondio $CODIGO"
echo "$CUERPO" | grep -q "$NOMBRE" || fallar "el producto consultado no es el que se registro"

echo "== 6. Verificando directamente dentro de PostgreSQL"
FILAS=$(docker compose exec -T database psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -A \
  -c "SELECT COUNT(*) FROM \"Productos\" WHERE \"Id\" = $ID;" | tr -d '[:space:]') \
  || fallar "no se pudo consultar PostgreSQL"
echo "Filas encontradas con Id=$ID: $FILAS"
[ "$FILAS" = "1" ] || fallar "el producto no esta guardado en PostgreSQL"

echo "== 7. DELETE: eliminar el producto y comprobar que ya no existe"
CODIGO=$(curl_en_red -X DELETE -o /dev/null -w "%{http_code}" http://api-app:8080/api/productos/"$ID" || true)
[ "$CODIGO" = "204" ] || fallar "el DELETE debia responder 204 y respondio $CODIGO"
CODIGO=$(curl_en_red -o /dev/null -w "%{http_code}" http://api-app:8080/api/productos/"$ID" || true)
[ "$CODIGO" = "404" ] || fallar "despues del DELETE el GET debia responder 404 y respondio $CODIGO"

echo ""
echo "TODAS LAS PRUEBAS PASARON: api-app y database se comunican por el nombre del servicio."
