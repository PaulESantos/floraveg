# Grafico ggplot2 de Curvas de Dominancia-Abundancia de Whittaker

Genera un grafico de ggplot2 para visualizar distribuciones de
abundancia de especies (SAD).

## Usage

``` r
plot_whittaker(datos, scale = "logabun", por_sitio = TRUE, top_n_labels = 3)
```

## Arguments

- datos:

  Data frame con datos de inventario.

- scale:

  Escala de abundancia en el eje Y: `"logabun"` (Log10 Abundancia),
  `"abundance"` (Absoluta), `"proportion"` (porcentaje Abundancia
  Relativa), `"accumfreq"` (porcentaje Frecuencia Acumulada). Por
  defecto `"logabun"`.

- por_sitio:

  Si es `TRUE`, grafica curvas por sitio; si es `FALSE`, agrupa la
  comunidad general. Por defecto `TRUE`.

- top_n_labels:

  Numero de especies top a etiquetar en el grafico. Por defecto `3`.

## Value

Un objeto de clase `ggplot`.
