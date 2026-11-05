using ApiApp.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// La cadena de conexion viene de las variables de entorno (docker-compose.yml).
// Aqui NO hay contraseñas escritas.
var cadenaConexion = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<AppDbContext>(opciones =>
    opciones.UseNpgsql(cadenaConexion));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Crea la tabla automaticamente si no existe.
// Se reintenta varias veces por si PostgreSQL todavia esta arrancando.
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    for (var intento = 1; intento <= 10; intento++)
    {
        try
        {
            db.Database.EnsureCreated();
            Console.WriteLine("Conexion con PostgreSQL correcta.");
            break;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Intento {intento}/10: no se pudo conectar ({ex.Message})");
            if (intento == 10) throw;
            Thread.Sleep(3000);
        }
    }
}

// Swagger siempre activo para poder probar la API en el navegador.
app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

// Ruta simple para comprobar que la API esta viva.
app.MapGet("/", () => "API de productos funcionando. Prueba /swagger o /api/productos");

app.Run();
