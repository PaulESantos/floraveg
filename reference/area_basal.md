# Área Basal (§6.8 MINAM 2015)

Calcula el área basal individual o agregada a partir del Diámetro a la
Altura del Pecho (DAP en cm) o de la Longitud de Circunferencia (LC en
cm).

## Usage

``` r
area_basal(dap_cm = NULL, lc_cm = NULL, unidad_salida = c("m2", "cm2"))
```

## Arguments

- dap_cm:

  Vector numérico con el DAP en centímetros.

- lc_cm:

  Vector numérico opcional con la longitud de circunferencia en cm.

- unidad_salida:

  Carácter; `"m2"` (metros cuadrados) o `"cm2"`. Por defecto `"m2"`.

## Value

Vector numérico con el área basal en la unidad especificada.

## Examples

``` r
area_basal(dap_cm = c(15, 25, 40))
#> [1] 0.0176715 0.0490875 0.1256640
```
