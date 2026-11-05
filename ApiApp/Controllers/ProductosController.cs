using ApiApp.Data;
using ApiApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiApp.Controllers;

[ApiController]
[Route("api/[controller]")]   // la ruta queda: /api/productos
public class ProductosController : ControllerBase
{
    private readonly AppDbContext _db;

    public ProductosController(AppDbContext db)
    {
        _db = db;
    }

    // GET /api/productos  -> lista todos los productos
    [HttpGet]
    public async Task<ActionResult<List<Producto>>> ObtenerTodos()
    {
        return await _db.Productos.ToListAsync();
    }

    // GET /api/productos/1  -> busca un producto por su id
    [HttpGet("{id}")]
    public async Task<ActionResult<Producto>> ObtenerPorId(int id)
    {
        var producto = await _db.Productos.FindAsync(id);
        if (producto == null)
        {
            return NotFound(new { mensaje = "No existe un producto con ese id" });
        }
        return producto;
    }

    // POST /api/productos  -> registra un producto nuevo
    [HttpPost]
    public async Task<ActionResult<Producto>> Crear(Producto producto)
    {
        if (string.IsNullOrWhiteSpace(producto.Nombre))
        {
            return BadRequest(new { mensaje = "El nombre es obligatorio" });
        }
        if (producto.Precio < 0)
        {
            return BadRequest(new { mensaje = "El precio no puede ser negativo" });
        }

        producto.Id = 0; // el id lo genera PostgreSQL
        _db.Productos.Add(producto);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(ObtenerPorId), new { id = producto.Id }, producto);
    }

    // DELETE /api/productos/1  -> elimina un producto
    [HttpDelete("{id}")]
    public async Task<IActionResult> Eliminar(int id)
    {
        var producto = await _db.Productos.FindAsync(id);
        if (producto == null)
        {
            return NotFound(new { mensaje = "No existe un producto con ese id" });
        }

        _db.Productos.Remove(producto);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
