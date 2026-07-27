# Biomasa Aérea (§6.11 MINAM 2015)

Estima la biomasa aérea para estratos arbóreos (P = D \* V) o para
estratos herbáceos (vía peso seco por metro cuadrado).

## Usage

``` r
biomasa_aerea(
  densidad_madera = NULL,
  volumen_m3 = NULL,
  peso_seco_g_m2 = NULL,
  area_ha = NULL
)
```

## Arguments

- densidad_madera:

  Densidad básica de la madera (g/cm3 o t/m3). Requerido para arbóreas.

- volumen_m3:

  Volumen maderable en m3. Requerido para arbóreas.

- peso_seco_g_m2:

  Peso seco en gramos por m2 (para método destructivo de herbazales).

- area_ha:

  Área total en hectáreas si se desea escalar el resultado a nivel de
  lote/sitio.

## Value

Biomasa estimada en toneladas (t).

## Examples

``` r
# Biomasa arbórea
biomasa_aerea(densidad_madera = 0.60, volumen_m3 = 3.15)
#> [1] 1.89

# Biomasa en herbazal (peso seco en 1 m2 escalado a 1 ha)
biomasa_aerea(peso_seco_g_m2 = 120, area_ha = 1)
#> [1] 1.2
```
