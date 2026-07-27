# Índice de Equitabilidad de Pielou (J') (SINIA / MINAM Tabla 2.0-4)

Índice de Equitabilidad de Pielou (J') (SINIA / MINAM Tabla 2.0-4)

## Usage

``` r
diversidad_pielou(
  datos,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  base = 2
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

- base:

  Base logarítmica utilizada en Shannon (2 por defecto).

## Value

Data frame con el sitio, riqueza (S), Shannon (H') y Equitabilidad de
Pielou (J').
