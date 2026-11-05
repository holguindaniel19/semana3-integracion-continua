using ApiApp.Models;
using Microsoft.EntityFrameworkCore;

namespace ApiApp.Data;

// Clase que conecta la API con la base de datos PostgreSQL.
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    // Esta propiedad representa la tabla "Productos".
    public DbSet<Producto> Productos => Set<Producto>();
}
