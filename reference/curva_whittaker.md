# Curvas de Dominancia-Abundancia de Whittaker (Rank-Abundance)

Calcula los rangos de abundancia, proporciones relativas, frecuencias
acumuladas y valores logaritmicos para especies agrupadas por sitio o
nivel general (pooled).

## Usage

``` r
curva_whittaker(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  por_sitio = TRUE
)
```

## Arguments

- datos:

  Data frame con datos de inventario en formato long o matriz de
  comunidad.

- sitio:

  Nombre de la columna del sitio/parcela. Por defecto `"sitio"`.

- especie:

  Nombre de la columna de la especie. Por defecto `"especie"`.

- abundancia:

  Nombre de la columna de abundancia. Por defecto `"abundancia"`.

- por_sitio:

  Si es `TRUE`, genera curvas independientes por sitio; si es `FALSE`,
  agrupa la comunidad completa (pooled). Por defecto `TRUE`.

## Value

Un data frame con columnas: `sitio`, `especie`, `rank`, `abundance`,
`proportion`, `accumfreq`, `logabun`, `rankfreq`.
