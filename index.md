# floraveg

**`floraveg`** es un paquete de R diseñado para automatizar el
procesamiento, estandarización y análisis de inventarios florísticos y
de vegetación, siguiendo estrictamente la **Guía de Inventario de la
Flora y Vegetación del Ministerio del Ambiente del Perú (MINAM, 2015)**
y estándares ecológicos neotropicales.

------------------------------------------------------------------------

## 🌿 Características Principales

- 📊 **Estandarización y Validación**: Verificación automática de
  esquemas de datos de inventario y conversión fluida a matrices de
  comunidad (`sitio x especie`).
- 🧮 **Diversidad Alfa y Beta**: Cálculo de índices de riqueza ($`S`$),
  diversidad de Shannon ($`H'`$), equitabilidad de Pielou ($`J'`$),
  dominancia de Simpson ($`D`$), similitud de Sørensen/Jaccard y curvas
  de Whittaker.
- 🌳 **Estructura Forestal e IVI**: Abundancia absoluta/relativa,
  frecuencia, dominancia por área basal, cobertura de copa, clases
  diamétricas y el **Índice de Valor de Importancia (IVI)**.
- 🪵 **Biomasa Aérea y Volumen**: Modelos alométricos de biomasa leñosa
  aérea (**AGB** - *Chave et al. 2014*), volumen maderable y base de
  datos integrada de densidad de madera neotropical.
- 🖥️ **Aplicación Web Shiny Integrada**: Interfaz gráfica interactiva
  moderna para explorar datos, generar gráficos exportables y extraer
  código R ejecutable mediante
  [`run_floraveg()`](https://paulesantos.github.io/floraveg/reference/run_floraveg.md).

------------------------------------------------------------------------

## 🚀 Instalación

Puedes instalar la versión de desarrollo de **`floraveg`** desde GitHub
con:

``` r

# Instalar paquete devtools / remotes si no está disponible
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Instalar floraveg desde GitHub
remotes::install_github("PaulESantos/floraveg")
```

------------------------------------------------------------------------

## 💡 Ejemplos de Uso con Resultados

``` r

library(floraveg)
```

### 1. Carga y Estandarización de Inventario

``` r

# Cargar datos de ejemplo de bosque neotropical integrados
data("bci_t")
head(bci_t)
#>   plot                 species abundance
#> 1    1 Alchornea costaricensis         2
#> 2    1        Alseis blackiana        25
#> 3    1         Annona spraguei         1
#> 4    1           Apeiba glabra        13
#> 5    1        Apeiba tibourbou         2
#> 6    1    Astronium graveolens         6

# Convertir un data frame de inventario (formato largo) a matriz de comunidad (sitio x especie)
inv_ejemplo <- data.frame(
  sitio = rep(c("Parcela_1", "Parcela_2"), each = 3),
  especie = c("Cedrela odorata", "Ceiba pentandra", "Inga edulis",
              "Cedrela odorata", "Guarea guidonia", "Inga edulis"),
  abundancia = c(5, 2, 8, 3, 12, 4)
)

matriz_com <- long_to_comm(inv_ejemplo, sitio = "sitio", especie = "especie", abundancia = "abundancia")
print(matriz_com)
#>           Cedrela odorata Ceiba pentandra Guarea guidonia Inga edulis
#> Parcela_1               5               2               0           8
#> Parcela_2               3               0              12           4
```

### 2. Análisis de Diversidad Alfa

``` r

# Calcular índices de diversidad alfa completos
alfa_res <- diversidad_alfa(matriz_com)
print(alfa_res)
#>       sitio n_individuos riqueza_s shannon_h  pielou_j gini_simpson simpson_inv
#> 1 Parcela_1           15         3  1.399581 0.8830374    0.5866667    2.419355
#> 2 Parcela_2           19         3  1.312431 0.8280516    0.5318560    2.136095
#>    margalef menhinick  mcintosh
#> 1 0.7385387 0.7745967 0.4813823
#> 2 0.6792465 0.6882472 0.4098052

# Calcular índice de Shannon-Wiener
shannon_res <- diversidad_shannon(matriz_com)
print(shannon_res)
#>       sitio shannon_h base_log
#> 1 Parcela_1  1.399581        2
#> 2 Parcela_2  1.312431        2
```

### 3. Parámetros Estructurales e Índice de Valor de Importancia (IVI)

``` r

# Crear datos de estructura forestal con DAP
inventario_dap <- data.frame(
  sitio = paste0("P", rep(1:3, each = 4)),
  especie = rep(c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra", "Inga edulis"), 3),
  abundancia = c(10, 5, 2, 8, 12, 4, 3, 9, 8, 6, 1, 10),
  dap_cm = c(25, 45, 80, 15, 30, 50, 75, 18, 28, 40, 85, 20)
)

# Calcular el Índice de Valor de Importancia (IVI) por especie
tabla_ivi <- calc_ivi(
  datos = inventario_dap,
  sitio = "sitio",
  especie = "especie",
  abundancia = "abundancia",
  dap_cm = "dap_cm"
)

print(tabla_ivi)
#>                 especie n_individuos abundancia_rel_pct area_basal_m2
#> 1       Ceiba pentandra            6           7.692308    1.51189500
#> 2       Cedrela odorata           30          38.461538    0.18134886
#> 3 Swietenia macrophylla           15          19.230769    0.48105750
#> 4           Inga edulis           27          34.615385    0.07453446
#>   dominancia_rel_pct frecuencia_rel_pct      ivi
#> 1          67.230119                 25 99.92243
#> 2           8.064122                 25 71.52566
#> 3          21.391402                 25 65.62217
#> 4           3.314358                 25 62.92974
```

### 4. Estimación de Biomasa Aérea (AGB) y Volumen Maderable

``` r

# Calcular área basal (m2) y volumen maderable (m3)
ab <- area_basal(dap_cm = c(25.4, 42.1, 68.0), unidad_salida = "m2")
volumen <- volumen_maderable(
  area_basal_m2 = ab,
  altura_m = c(14.5, 22.0, 31.0),
  factor_forma = 0.7
)
print(volumen)
#> [1] 0.5143093 2.1437583 7.8807664

# Calcular biomasa aérea (AGB en toneladas) a partir de densidad de madera y volumen
biomasa <- biomasa_aerea(
  densidad_madera = c(0.55, 0.62, 0.48),
  volumen_m3 = volumen
)
print(biomasa)
#> [1] 0.2828701 1.3291301 3.7827679
```

### 5. Lanzar la Aplicación Interactiva Shiny

Para iniciar la aplicación web interactiva completa en tu navegador
local:

``` r

library(floraveg)

# Iniciar la aplicación interactiva principal
run_floraveg()
```

O si prefieres ejecutar un módulo específico de forma independiente:

``` r

# Ejemplo: ejecutar solo el módulo de Diversidad
run_mod_diversidad()
```

------------------------------------------------------------------------

## 📖 Referencias

- **MINAM (2015)**. *Guía de Inventario de la Flora y Vegetación*.
  Ministerio del Ambiente del Perú, Lima.
- **Chave, J., et al. (2014)**. *Improved allometric models to estimate
  the aboveground biomass of tropical trees*. Global Change Biology,
  20(10), 3177-3190.
- **Jongman, R. H. G., ter Braak, C. J. F., & van Tongeren, O. F. R.
  (1987)**. *Data Analysis in Community and Landscape Ecology*. Pudoc,
  Wageningen.
