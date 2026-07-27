# Diversidad Alfa e Índices de Riqueza y Equidad (MINAM 2015 / speciesdiv)

Calcula la riqueza y los índices clásicos y avanzados de diversidad alfa
por sitio o unidad muestral: Riqueza observada (S), N° Individuos (N),
Shannon-Wiener (H'), Equitabilidad de Pielou (J'), Gini-Simpson, Simpson
Inverso, Margalef, Menhinick y McIntosh.

## Usage

``` r
diversidad_alfa(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  metodos = "full",
  base = 2
)
```

## Arguments

- datos:

  Data frame con datos de inventario en formato long o matriz de
  comunidad.

- sitio:

  Nombre de la columna del sitio/parcela. Por defecto `"sitio"`.

- especie:

  Nombre de la columna de la especie. Por defecto `"especie"`.

- abundancia:

  Nombre de la columna con la abundancia. Por defecto `"abundancia"`.

- metodos:

  Vector o carácter de métodos a calcular: `"full"`, `"richness"`,
  `"shannon"`, `"pielou"`, `"gini_simpson"`, `"simpson_inv"`,
  `"margalef"`, `"menhinick"`, `"mcintosh"`. Por defecto `"full"`.

- base:

  Base del logaritmo para Shannon y Pielou. Por defecto `2` según
  especificación MINAM.

## Value

Un data frame con el sitio y las columnas correspondientes a los índices
calculados.

## Examples

``` r
df <- data.frame(
  sitio = c("P1", "P1", "P2", "P2", "P2"),
  especie = c("SpA", "SpB", "SpA", "SpB", "SpC"),
  abundancia = c(10, 5, 2, 8, 1)
)
diversidad_alfa(df)
#>   sitio n_individuos riqueza_s shannon_h  pielou_j gini_simpson simpson_inv
#> 1    P1           15         2 0.9182958 0.9182958    0.4444444    1.800000
#> 2    P2           11         3 1.0957953 0.6913698    0.4297521    1.753623
#>    margalef menhinick mcintosh
#> 1 0.3692694 0.5163978 0.343278
#> 2 0.8340648 0.9045340 0.350546
```
