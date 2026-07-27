# Proporción de Estados Fenológicos (SINIA / MINAM Tabla 2.1.4-8)

Cuantifica la proporción porcentual de los estados fenológicos
registrados en campo (Floración, Fructificación, Vegetativo, Plántula).

## Usage

``` r
proporcion_fenologia(vector_fenologia)
```

## Arguments

- vector_fenologia:

  Vector de caracteres o factores con la observación fenológica por
  individuo.

## Value

Data frame con la frecuencia observada y el porcentaje de cada estado
fenológico.

## Examples

``` r
fenologia <- c("Floracion", "Floracion", "Fructificacion", "Vegetativo", "Vegetativo", "Vegetativo")
proporcion_fenologia(fenologia)
#>   estado_fenologico frecuencia porcentaje
#> 3        Vegetativo          3   50.00000
#> 1         Floracion          2   33.33333
#> 2    Fructificacion          1   16.66667
```
