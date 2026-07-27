# Cobertura (Área de Copa) (§6.9 MINAM 2015)

Calcula el área de copa individual o la cobertura relativa porcentual
respecto al área del sitio.

## Usage

``` r
cobertura(dc_m = NULL, porcentaje_observado = NULL, area_parcela_m2 = NULL)
```

## Arguments

- dc_m:

  Vector numérico con el diámetro de copa en metros.

- porcentaje_observado:

  Vector numérico opcional con cobertura % observada directamente (p.
  ej. en herbazales).

- area_parcela_m2:

  Área de la unidad muestral en metros cuadrados (m2).

## Value

Lista o data frame con área de copa (m2) y cobertura relativa (%).

## Examples

``` r
cobertura(dc_m = c(3, 4.5, 6), area_parcela_m2 = 500)
#>   area_copa_m2 cobertura_relativa_pct
#> 1      7.06860                1.41372
#> 2     15.90435                3.18087
#> 3     28.27440                5.65488
```
