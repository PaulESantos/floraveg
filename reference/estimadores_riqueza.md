# Estimadores No Paramétricos de Riqueza (SINIA / MINAM Tabla 2.0-3)

Calcula la riqueza total de especies esperada mediante los estimadores
no paramétricos Chao 2, Jackknife 1, Jackknife 2 y Bootstrap.

## Usage

``` r
estimadores_riqueza(
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

Data frame con los valores de riqueza esperada estimada por cada método.

## Examples

``` r
df <- data.frame(
  sitio = c("P1", "P1", "P2", "P2", "P3", "P3"),
  especie = c("Sp1", "Sp2", "Sp1", "Sp3", "Sp1", "Sp4"),
  abundancia = c(1, 2, 3, 1, 2, 4)
)
estimadores_riqueza(df)
#>   riqueza_observada chao2 jackknife1 jackknife2 bootstrap
#> 1                 4     6          6          7  4.888889
```
