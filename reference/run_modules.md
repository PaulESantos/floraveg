# Lanzadores Standalone de Módulos Shiny de floraveg

Estas funciones permiten ejecutar cada módulo de la aplicación Shiny de
forma 100% independiente.

## Usage

``` r
run_mod_modelo_datos(launch.browser = TRUE)

run_mod_diversidad(launch.browser = TRUE)

run_mod_estructura(launch.browser = TRUE)

run_mod_biomasa(launch.browser = TRUE)

run_mod_ivi(launch.browser = TRUE)

run_mod_codigo_r(launch.browser = TRUE)
```

## Arguments

- launch.browser:

  Lógico; abre en el navegador. Por defecto TRUE.

## Value

Objeto Shiny app.
