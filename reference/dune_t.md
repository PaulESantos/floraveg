# Datos de Observaciones de Vegetacion de Dunas (Dune Dataset en Formato Largo)

Conjunto de datos de observaciones de 30 especies de vegetacion en 20
sitios en dunas holandesas (Jongman et al., 1987), formateado en
estructura larga (sitio/plot, especie/species, abundancia/abundance).

## Usage

``` r
data(dune_t)
```

## Format

Un `data.frame` con 197 filas y 3 columnas:

- plot:

  Identificador de la parcela / sitio (1 al 20).

- species:

  Nombre abreviado o cientifico de la especie (30 especies).

- abundance:

  Conteo / abundancia observada de la especie en el sitio.

## Source

Jongman, R.H.G., ter Braak, C.J.F. & van Tongeren, O.F.R. (1987). *Data
Analysis in Community and Landscape Ecology*. Pudoc, Wageningen.
