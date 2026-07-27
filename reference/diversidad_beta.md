# Diversidad Beta: Coeficientes de Similitud (MINAM 2015) Indice de Diversidad Beta (Jaccard, Sorensen o Morisita-Horn)

Diversidad Beta: Coeficientes de Similitud (MINAM 2015) Indice de
Diversidad Beta (Jaccard, Sorensen o Morisita-Horn)

## Usage

``` r
diversidad_beta(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  metodo = c("jaccard", "sorensen", "morisita-horn"),
  formato = c("matrix", "tidy")
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

  Nombre de la columna con abundancia. Por defecto `"abundancia"`.

- metodo:

  Caracter; `"jaccard"` (cualitativo), `"sorensen"` (cualitativo) o
  `"morisita-horn"` (cuantitativo).

- formato:

  Caracter; `"matrix"` (matriz/dist original) o `"tidy"` (data.frame
  ordenado con sitio_1, sitio_2, similitud, disimilitud). Por defecto
  `"matrix"`.

## Value

Si `formato = "matrix"`, objeto de clase `dist` o matriz de similitud (0
a 1). Si `formato = "tidy"`, un `data.frame` con las columnas `sitio_1`,
`sitio_2`, `similitud` y `disimilitud`.
