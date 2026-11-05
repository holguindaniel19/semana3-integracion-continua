namespace ApiApp.Models;

// Representa un producto. Cada propiedad es una columna en la tabla.
public class Producto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public decimal Precio { get; set; }
}
