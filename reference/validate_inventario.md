# Validar estructura de datos de inventario

Comprueba que el objeto provisto sea un data frame y contenga las
columnas requeridas.

## Usage

``` r
validate_inventario(datos, required_cols = c("sitio", "especie"))
```

## Arguments

- datos:

  Data.frame o tibble con los datos del inventario.

- required_cols:

  Vector de caracteres con los nombres de las columnas indispensables.

## Value

El mismo data frame si la validación es exitosa.

## Examples

``` r
df <- data.frame(sitio = c("P1", "P1"), especie = c("Sp1", "Sp2"), abundancia = c(5, 2))
validate_inventario(df, c("sitio", "especie"))
#>   sitio especie abundancia
#> 1    P1     Sp1          5
#> 2    P1     Sp2          2
```
