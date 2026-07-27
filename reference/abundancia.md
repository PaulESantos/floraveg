# Abundancia Absoluta y Relativa (§6.3 MINAM 2015)

Calcula la abundancia absoluta (número de individuos) y relativa (%) por
especie.

## Usage

``` r
abundancia(
  datos,
  especie = "especie",
  abundancia = "abundancia",
  tipo = c("ambas", "absoluta", "relativa")
)
```

## Arguments

- datos:

  Data frame con los datos de inventario.

- especie:

  Nombre de la columna de especie. Por defecto `"especie"`.

- abundancia:

  Nombre de la columna de abundancia. Si es `NULL`, se cuenta el número
  de filas por especie. Por defecto `"abundancia"`.

- tipo:

  Carácter; `"ambas"`, `"absoluta"` o `"relativa"`.

## Value

Data frame ordenado por abundancia decreciente con especie, n_individuos
y abundancia_relativa_pct.

## Examples

``` r
df <- data.frame(
  especie = c("SpA", "SpA", "SpB", "SpC", "SpC", "SpC"),
  abundancia = c(5, 5, 10, 2, 3, 5)
)
abundancia(df)
#>   especie n_individuos abundancia_relativa_pct
#> 1     SpA           10                33.33333
#> 2     SpB           10                33.33333
#> 3     SpC           10                33.33333
```
