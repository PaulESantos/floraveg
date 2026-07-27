# Índice de Valor de Importancia (IVI) (§6.12 MINAM 2015)

Calcula el Índice de Valor de Importancia Ecológica (IVI) para cada
especie a partir de la suma de la Abundancia Relativa (%), Dominancia
Relativa (%) calculada por Área Basal, y Frecuencia Relativa (%).

## Usage

``` r
calc_ivi(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  dap_cm = "dap_cm"
)
```

## Arguments

- datos:

  Data frame con datos de inventario.

- sitio:

  Nombre de la columna de sitio/parcela. Por defecto `"sitio"`.

- especie:

  Nombre de la columna de especie. Por defecto `"especie"`.

- abundancia:

  Nombre de la columna de abundancia (o número de individuos). Por
  defecto `"abundancia"`.

- dap_cm:

  Nombre de la columna con el Diámetro a la Altura del Pecho en cm. Por
  defecto `"dap_cm"`.

## Value

Data frame ordenado por IVI decreciente con las columnas: `especie`,
`n_individuos`, `abundancia_rel_pct`, `area_basal_m2`,
`dominancia_rel_pct`, `frecuencia_rel_pct` e `ivi`.

## Examples

``` r
df <- data.frame(
  sitio = c("P1", "P1", "P1", "P2", "P2"),
  especie = c("SpA", "SpB", "SpC", "SpA", "SpB"),
  abundancia = c(5, 3, 2, 8, 4),
  dap_cm = c(20, 15, 10, 25, 18)
)
calc_ivi(df)
#>   especie n_individuos abundancia_rel_pct area_basal_m2 dominancia_rel_pct
#> 1     SpA           13          59.090909    0.08050350          61.230585
#> 2     SpB            7          31.818182    0.04311846          32.795699
#> 3     SpC            2           9.090909    0.00785400           5.973716
#>   frecuencia_rel_pct       ivi
#> 1                 40 160.32149
#> 2                 40 104.61388
#> 3                 20  35.06462
```
