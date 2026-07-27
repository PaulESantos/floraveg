# Densidad Poblacional (§6.4 MINAM 2015)

Calcula la densidad poblacional (individuos por hectárea), considerando
opcionalmente conteo de tocones.

## Usage

``` r
densidad_poblacional(n_individuos, area_ha, tocones = 0)
```

## Arguments

- n_individuos:

  Número total o vector de individuos.

- area_ha:

  Área del muestreo en hectáreas (ha).

- tocones:

  Conteo adicional de tocones. Por defecto `0`.

## Value

Densidad en individuos/ha.

## Examples

``` r
densidad_poblacional(n_individuos = 450, area_ha = 0.5)
#> [1] 900
```
