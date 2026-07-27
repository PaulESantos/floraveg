# Modelo Paramétrico de Clench para Curvas de Acumulación (SINIA / MINAM Tabla 2.0-3)

Ajusta el modelo no lineal de Clench (S(n) = (a \* n) / (1 + b \* n))
sobre los datos de acumulación de especies para estimar la riqueza
máxima asintótica (a / b) y evaluar la representatividad (\> 70%).

## Usage

``` r
modelo_clench(
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

Lista con los coeficientes a y b, la riqueza asintótica estimada, la
riqueza observada, el % de representatividad y el modelo nls.

## Examples

``` r
df <- data.frame(
  sitio = c("P1", "P1", "P2", "P2", "P3", "P3", "P4", "P4"),
  especie = c("Sp1", "Sp2", "Sp1", "Sp3", "Sp1", "Sp4", "Sp2", "Sp5"),
  abundancia = c(1, 2, 3, 1, 2, 4, 1, 1)
)
modelo_clench(df)
#> $riqueza_observada
#> [1] 5
#> 
#> $asintota_estimada
#> [1] 9.927424
#> 
#> $representatividad_pct
#> [1] 50.36553
#> 
#> $coeficientes
#>         a         b 
#> 2.5092278 0.2527572 
#> 
#> $modelo
#> Nonlinear regression model
#>   model: riqueza ~ (a * muestras)/(1 + b * muestras)
#>    data: df_acc
#>      a      b 
#> 2.5092 0.2528 
#>  residual sum-of-squares: 0.0007169
#> 
#> Number of iterations to convergence: 5 
#> Achieved convergence tolerance: 1.444e-06
#> 
```
