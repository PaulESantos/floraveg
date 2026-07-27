# Convertir formato de inventario (long) a matriz de comunidad (sitios x especies)

Transforma un data frame en formato tidy/long en una matriz cuantitativa
o de presencia/ausencia de sitios (filas) por especies (columnas), apta
para funciones del paquete `vegan`.

## Usage

``` r
long_to_comm(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  fill = 0
)
```

## Arguments

- datos:

  Data frame con observaciones.

- sitio:

  Nombre de la columna con el identificador del sitio o parcela. Por
  defecto `"sitio"`.

- especie:

  Nombre de la columna con el nombre taxonómico o código de especie. Por
  defecto `"especie"`.

- abundancia:

  Nombre de la columna con la abundancia/conteo. Si es `NULL`, se cuenta
  el número de registros (filas) por especie y sitio. Por defecto
  `"abundancia"`.

- fill:

  Valor numérico para rellenar ausencias. Por defecto `0`.

## Value

Una matriz numérica de R con sitios en las filas y especies en las
columnas.

## Examples

``` r
df <- data.frame(
  sitio = c("P1", "P1", "P2", "P2"),
  especie = c("SpA", "SpB", "SpA", "SpC"),
  abundancia = c(10, 5, 2, 8)
)
long_to_comm(df, sitio = "sitio", especie = "especie", abundancia = "abundancia")
#>    SpA SpB SpC
#> P1  10   5   0
#> P2   2   0   8
```
