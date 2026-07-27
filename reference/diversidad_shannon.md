# Índice de Diversidad de Shannon-Wiener (H') (MINAM 2015)

Índice de Diversidad de Shannon-Wiener (H') (MINAM 2015)

## Usage

``` r
diversidad_shannon(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  base = 2
)
```

## Arguments

- datos:

  Data frame en formato long o matriz de comunidad.

- sitio:

  Nombre de la columna del sitio. Por defecto `"sitio"`.

- especie:

  Nombre de la columna de la especie. Por defecto `"especie"`.

- abundancia:

  Nombre de la columna de abundancia. Por defecto `"abundancia"`.

- base:

  Base del logaritmo. Por defecto `2`.

## Value

Data frame con el sitio y su respectivo valor de Shannon-Wiener (H').
