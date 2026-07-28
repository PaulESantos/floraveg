# Estandarizar nombres de columnas del inventario floristico

Mapea automaticamente variantes comunes de nombres de columnas
(plot/sitio, species/especie, abundance/abundancia).

## Usage

``` r
standardize_inventory(datos)
```

## Arguments

- datos:

  Data frame con el inventario floristico.

## Value

Data frame estandarizado con las columnas 'sitio', 'especie' y
'abundancia'.

## Examples

``` r
df <- data.frame(plot = c("P1", "P1"), species = c("SpA", "SpB"), count = c(5, 2))
standardize_inventory(df)
#>   sitio especie abundancia
#> 1    P1     SpA          5
#> 2    P1     SpB          2
```
