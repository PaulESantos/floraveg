# Obtener Densidades Específicas de la Madera por Especie o Género

Asigna valores de densidad básica de la madera (g/cm3) consultando un
diccionario de referencia por especie (ej. 'Cedrela odorata'), por
género (ej. 'Cedrela') o retornando un valor estándar predeterminado en
caso de no encontrarse coincidencia.

## Usage

``` r
obtener_densidad_madera(especies, db_densidades = NULL, default = 0.6)
```

## Arguments

- especies:

  Vector de caracteres con nombres científicos o identificadores de
  especie.

- db_densidades:

  Vector nombrado opcional con valores de densidad (g/cm3). Si es
  `NULL`, se utiliza la base de referencia neotropical interna.

- default:

  Valor numérico por defecto (g/cm3) para especies o géneros no
  encontrados. Por defecto `0.60`.

## Value

Un vector numérico de densidades básicas de la madera de la misma
longitud que `especies`.

## Examples

``` r
especies <- c("Cedrela odorata", "Inga edulis", "Especie desconocida")
obtener_densidad_madera(especies, default = 0.60)
#> [1] 0.45 0.55 0.60
```
