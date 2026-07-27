# Frecuencia Absoluta y Relativa (§6.5 MINAM 2015)

Calcula la frecuencia absoluta (número de unidades muestrales donde
aparece la especie) y la frecuencia relativa (%).

## Usage

``` r
frecuencia(datos, sitio = "sitio", especie = "especie")
```

## Arguments

- datos:

  Data frame con datos de inventario en formato long o matriz de
  comunidad.

- sitio:

  Nombre de la columna de sitio. Por defecto `"sitio"`.

- especie:

  Nombre de la columna de especie. Por defecto `"especie"`.

## Value

Data frame con especie, frecuencia_absoluta, frecuencia_pct y
frecuencia_relativa_pct.

## Examples

``` r
df <- data.frame(
  sitio = c("P1", "P1", "P2", "P3"),
  especie = c("SpA", "SpB", "SpA", "SpA")
)
frecuencia(df)
#>   especie frecuencia_absoluta frecuencia_pct frecuencia_relativa_pct
#> 1     SpA                   3      100.00000                      75
#> 2     SpB                   1       33.33333                      25
```
