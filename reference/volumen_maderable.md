# Volumen Maderable (§6.10 MINAM 2015)

Estima el volumen maderable en pie (m3) a partir del área basal (m2), la
altura (m) y un factor de forma (\$F_m\$).

## Usage

``` r
volumen_maderable(area_basal_m2, altura_m, factor_forma = 0.7)
```

## Arguments

- area_basal_m2:

  Area basal en metros cuadrados (m2).

- altura_m:

  Altura comercial o total del árbol en metros (m).

- factor_forma:

  Factor de forma del fuste. Por defecto `0.70` (bosques tropicales
  húmedos, Malleux 1982).

## Value

Vector numérico con el volumen maderable en metros cúbicos (m3).

## Examples

``` r
volumen_maderable(area_basal_m2 = 0.25, altura_m = 18, factor_forma = 0.70)
#> [1] 3.15
```
