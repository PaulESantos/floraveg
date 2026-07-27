# Curva de Acumulación de Especies (MINAM 2015)

Curva de Acumulación de Especies (MINAM 2015)

## Usage

``` r
curva_acumulacion(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  metodo = "random",
  sustituciones = 100
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

- metodo:

  Método de acumulación para
  [`vegan::specaccum`](https://vegandevs.github.io/vegan/reference/specaccum.html).
  Por defecto `"random"`.

- sustituciones:

  Número de permutaciones cuando `metodo = "random"`. Por defecto `100`.

## Value

Objeto de clase `specaccum`.
