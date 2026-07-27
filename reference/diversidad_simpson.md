# Índice de Dominancia y Diversidad de Simpson (D y 1-D)

Índice de Dominancia y Diversidad de Simpson (D y 1-D)

## Usage

``` r
diversidad_simpson(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia"
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

## Value

Data frame con el sitio, dominancia de Simpson (D) e índice de Simpson
(1 - D).
