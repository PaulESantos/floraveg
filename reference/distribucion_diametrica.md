# Distribución Diamétrica (§6.6 MINAM 2015)

Clasifica los valores de DAP en clases diamétricas estandarizadas (5 cm
o 10 cm según la región/ecosistema) y prepara la tabla de frecuencias
para la curva de distribución J invertida.

## Usage

``` r
distribucion_diametrica(dap_cm, ancho_clase = 10, min_dap = 0)
```

## Arguments

- dap_cm:

  Vector numérico de diámetros a la altura del pecho (cm).

- ancho_clase:

  Ancho de la clase diamétrica en cm (10 cm por defecto para selva, 5 cm
  para costa/sierra).

- min_dap:

  DAP mínimo a considerar. Por defecto `0`.

## Value

Lista con la tabla de frecuencias por clase, marcas de clase y el objeto
de ajuste no lineal `nls` si aplica.

## Examples

``` r
daps <- c(12, 15, 18, 22, 25, 33, 41, 45, 52, 68)
distribucion_diametrica(daps, ancho_clase = 10)
#> $tabla_clases
#>     Clase frecuencia marca_clase
#> 1  [0,10)          0           5
#> 2 [10,20)          3          15
#> 3 [20,30)          2          25
#> 4 [30,40)          1          35
#> 5 [40,50)          2          45
#> 6 [50,60)          1          55
#> 7 [60,70]          1          65
#> 
#> $ancho_clase
#> [1] 10
#> 
#> $modelo_j_invertida
#> Nonlinear regression model
#>   model: frecuencia ~ K * exp(-a * marca_clase)
#>    data: tabla_freq[tabla_freq$frecuencia > 0, ]
#>       K       a 
#> 3.88083 0.02322 
#>  residual sum-of-squares: 1.049
#> 
#> Number of iterations to convergence: 5 
#> Achieved convergence tolerance: 5.227e-07
#> 
```
