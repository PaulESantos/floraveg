# Coeficiente de Similitud de Sorensen-Dice

Coeficiente de Similitud de Sorensen-Dice

## Usage

``` r
diversidad_sorensen(
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

Objeto de clase `dist` con los valores de similitud de Sorensen-Dice.
