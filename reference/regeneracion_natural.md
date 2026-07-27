# Estructura de Regeneración Natural y Estadios Forestales (SINIA / MINAM §2.1.4.3.2)

Clasifica árboles e individuos forestales en categorías de regeneración
y desarrollo: Brinzales (DAP \< 2.5 cm / plántulas), Latizales (DAP de
2.5 a 10 cm) y Fustales (DAP \>= 10 cm).

## Usage

``` r
regeneracion_natural(dap_cm, altura_m = NULL)
```

## Arguments

- dap_cm:

  Vector numérico con el Diámetro a la Altura del Pecho (DAP en cm).

- altura_m:

  Vector numérico opcional de alturas totales (m) para afinar plántulas.

## Value

Vector de factores con las categorías ("Brinzal", "Latizal", "Fustal").

## Examples

``` r
regeneracion_natural(dap_cm = c(0.5, 1.2, 5.5, 12.0, 45.0))
#> [1] Brinzal Brinzal Latizal Fustal  Fustal 
#> Levels: Brinzal Latizal Fustal
```
