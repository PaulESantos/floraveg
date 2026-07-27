# Lanzador de la Aplicación Shiny de floraveg

Inicia la interfaz gráfica interactiva del paquete `floraveg` en el
navegador web predeterminado.

## Usage

``` r
run_floraveg(launch.browser = TRUE, port = getOption("shiny.port"))
```

## Arguments

- launch.browser:

  Lógico; si es `TRUE`, abre automáticamente el navegador. Por defecto
  `TRUE`.

- port:

  Puerto numérico opcional para el servidor Shiny.

## Value

Objeto de aplicación Shiny (ejecución interactiva).

## Examples

``` r
if (FALSE) { # \dontrun{
run_floraveg()
} # }
```
