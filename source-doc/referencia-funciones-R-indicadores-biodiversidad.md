# Referencia técnica: funciones de R para indicadores de biodiversidad y vegetación

**Basado en:** Guía de inventario de la flora y vegetación (MINAM, 2015), Capítulo 6 — Estimación de parámetros
**Propósito:** Documento de referencia para el desarrollo de un paquete en R que automatice el cálculo de los indicadores descritos en la guía.

---

## 1. Estructura de datos de entrada requerida

Antes de detallar cada indicador, se define la estructura mínima de datos que el paquete debe soportar, ya que varias funciones dependen de estos campos:

| Campo | Descripción | Usado en |
|---|---|---|
| `parcela` / `sitio` | Identificador de la unidad muestral | Todos |
| `especie` | Nombre científico o código taxonómico | 6.1, 6.2, 6.3, 6.5, 6.12, 6.13 |
| `familia` | Familia taxonómica | 6.1 |
| `forma_vida` | Árbol, arbusto, palmera, herbácea, etc. | 6.1, 6.6 |
| `dap_cm` | Diámetro a la altura del pecho (cm) | 6.6, 6.8, 6.10 |
| `altura_m` | Altura total o del fuste (m) | 6.10, 6.11 |
| `dc_m` | Diámetro de copa (m) | 6.9 |
| `abundancia` / `n_individuos` | Número de individuos por especie/parcela | 6.3, 6.4, 6.12 |
| `densidad_madera` | Densidad básica de la madera (g/cm³) | 6.11 |
| `tipo_vegetacion` | Estrato o unidad de vegetación mapeada | Todos (para reportes por estrato) |

Se recomienda que el paquete acepte datos en formato "long" (una fila por individuo/registro) y provea funciones internas de conversión a matriz de comunidad (sitios × especies) para las funciones que dependen de `vegan`.

---

## 2. Tabla resumen de indicadores y funciones

| N.° | Indicador (guía) | Sección | Fórmula guía | Función(es) R propuesta(s) | Paquete |
|---|---|---|---|---|---|
| 1 | Diversidad alfa (riqueza) | 6.1 | N.° total de especies | `specnumber()`, `rarefy()` | `vegan` |
| 2 | Diversidad beta — Jaccard | 6.2 | I_J = c/(a+b-c) | `vegdist(method="jaccard")` | `vegan` |
| 3 | Diversidad beta — Morisita-Horn | 6.2 | I_M-H (fórmula abundancia) | `vegdist(method="horn")` | `vegan` |
| 4 | Abundancia absoluta/relativa | 6.3 | n, n/N × 100 | `table()`, `decostand(method="total")` | base, `vegan` |
| 5 | Densidad poblacional | 6.4 | D = N/A | función propia (aritmética) | — |
| 6 | Frecuencia | 6.5 | Fi = (mi/M) × 100 | función propia + `specnumber()` sobre P/A | `vegan` |
| 7 | Distribución diamétrica | 6.6 | Clases de 10 o 5 cm; curva J invertida Y=Ke⁻ᵃˣ | `hist()`, `cut()`, `nls()` | base, `stats` |
| 8 | Curva de acumulación de especies | 6.7 | Curva especie-área | `specaccum()`, `poolaccum()` | `vegan` |
| 9 | Área basal | 6.8 | AB = 0,7854 × DAP² | función propia (vectorizada) | — |
| 10 | Cobertura (área de copa) | 6.9 | AC = 3,1416 × (DC/2)² | función propia (vectorizada) | — |
| 11 | Volumen maderable | 6.10 | V = AB × A × Fm | función propia / `BIOMASS::computeAGB()` (adaptable) | `BIOMASS` |
| 12 | Biomasa aérea arbórea | 6.11 | P = D × V | función propia / `BIOMASS::computeAGB()` | `BIOMASS` |
| 13 | Índice de Valor de Importancia (IVI) | 6.12 | IVI = Ab% + Dom% + Fr% | `importancevalue()` | `BiodiversityR` |
| 14 | Índice de diversidad Shannon-Wiener | 6.13 | H' = -∑(pi)(log₂ pi) | `diversity(index="shannon")` (ajustar base log) | `vegan` |
| 15 | Índices agrostológicos (pastizales) | 6.14 | Ponderación 50/20/20/10 | función propia (sin equivalente en CRAN) | — |

---

## 3. Detalle por indicador

### 3.1. Diversidad alfa (riqueza) — §6.1

**Definición en la guía:** número total de especies presentes en un lugar, sin considerar abundancia.

**Función R:**
```r
vegan::specnumber(x, MARGIN = 1)
```
- `x`: matriz de comunidad (sitios en filas, especies en columnas), valores de abundancia o presencia/ausencia.
- Devuelve un vector con la riqueza por sitio (parcela o tipo de vegetación).

**Complemento — riqueza rarificada** (para comparar unidades muestrales de distinto tamaño/esfuerzo):
```r
vegan::rarefy(x, sample)
```

**Notas para el paquete:** envolver en una función `diversidad_alfa(datos, agrupar_por = "tipo_vegetacion")` que reciba datos en formato "long" y devuelva la tabla de riqueza por unidad de análisis.

---

### 3.2. Diversidad beta — §6.2

**Definición en la guía:** variación en el número de especies entre hábitats de un mismo ecosistema. La guía especifica dos índices:

**a) Coeficiente de Similitud de Jaccard** (datos cualitativos, presencia/ausencia)

Fórmula guía: `I_J = c / (a + b - c)`

```r
vegan::vegdist(x, method = "jaccard", binary = TRUE)
```

**b) Índice de Morisita-Horn** (datos cuantitativos de abundancia)

Fórmula guía: `I_M-H = 2∑(ani×bnj) / [(da+db)×aN×bN]`

```r
vegan::vegdist(x, method = "horn")
```

**Nota importante:** `vegdist()` en `vegan` devuelve una medida de **disimilitud** (0 = idéntico, 1 = totalmente distinto), mientras que la guía define ambos índices como **similitud** (0 = sin especies compartidas, 1 = misma composición). El paquete debe restar de 1 el resultado de `vegdist()` para reportar el valor en la misma escala que usa la guía: `similitud <- 1 - vegdist(...)`.

**Complemento — partición de diversidad beta** (turnover vs anidamiento), útil si se requiere descomponer el índice:
```r
betapart::beta.pair() / betapart::beta.multi()
```

---

### 3.3. Abundancia — §6.3

**Definición en la guía:** abundancia absoluta (n.° individuos/especie en un área) y abundancia relativa (n/N × 100).

**Función R:**
```r
# Abundancia absoluta
table(datos$especie)

# Abundancia relativa
vegan::decostand(x, method = "total") * 100
```

**Notas para el paquete:** función propia `abundancia(datos, tipo = c("absoluta","relativa"))` que trabaje tanto sobre datos "long" como sobre matriz de comunidad.

---

### 3.4. Densidad poblacional — §6.4

**Definición en la guía:** D = N/A (individuos por unidad de superficie, típicamente por hectárea).

No existe una función estándar en CRAN para esto; se implementa de forma directa:

```r
densidad_poblacional <- function(n_individuos, area_ha) {
  n_individuos / area_ha
}
```

**Notas para el paquete:** debe incluir el conteo de tocones como variable adicional opcional, tal como indica la guía (§6.4, aplicación similar a abundancia).

---

### 3.5. Frecuencia — §6.5

**Definición en la guía:** `Fi = (mi/M) × 100`, donde *mi* = n.° de unidades muestrales donde aparece la especie y *M* = n.° total de unidades muestrales.

```r
frecuencia <- function(x) {
  # x: matriz de comunidad binaria (presencia/ausencia), sitios en filas
  colSums(x > 0) / nrow(x) * 100
}
```

Alternativamente, usando `vegan::specnumber()` con `MARGIN = 2` sobre una matriz de presencia/ausencia transpuesta, o construyendo la proporción manualmente como se muestra arriba (recomendado por mayor claridad).

**Uso posterior:** este valor (frecuencia relativa) es un insumo directo para el cálculo del IVI (§3.13).

---

### 3.6. Distribución diamétrica — §6.6

**Definición en la guía:** distribución de individuos por clases diamétricas (10 cm para selva alta/baja, 5 cm para costa/sierra); modelo de curva "J invertida": `Y = Ke^(-ax)`.

```r
# Clasificación en clases diamétricas
clases <- cut(datos$dap_cm, breaks = seq(0, max(datos$dap_cm) + 10, by = 10))
tabla_clases <- table(clases)

# Ajuste del modelo J invertida
modelo_j <- nls(n ~ K * exp(-a * clase_media), data = df_clases,
                 start = list(K = max(df_clases$n), a = 0.1))
```

**Notas para el paquete:** el tamaño de clase (5 o 10 cm) debe ser un parámetro configurable, condicionado al tipo de bosque (`region` o `tipo_vegetacion`), replicando el criterio de la guía.

---

### 3.7. Curva de acumulación de especies — §6.7

**Definición en la guía:** curva "área-especies", usada para validar el tamaño mínimo de la unidad muestral.

```r
vegan::specaccum(x, method = "random")   # curva de acumulación
vegan::poolaccum(x)                       # con estimadores e intervalos de confianza
```

**Complemento recomendado — rarefacción/extrapolación con intervalos de confianza:**
```r
iNEXT::iNEXT(x, q = 0, datatype = "abundance")
```

**Notas para el paquete:** conviene incluir una función de graficado (`plot.specaccum` o `ggplot2`) que reproduzca el formato de la Figura n.° 1 de la guía (subparcelas en el eje X, número de especies en el eje Y).

---

### 3.8. Área basal — §6.8

**Definición en la guía:** `AB = 3,1416 × (DAP/2)²` equivalente a `AB = 0,7854 × DAP²`. Alternativa con longitud de circunferencia: `AB = (LC/4) × 3,1416`.

```r
area_basal <- function(dap_cm) {
  0.7854 * dap_cm^2   # cm²; convertir a m² dividiendo entre 10000 si se requiere
}

area_basal_circunferencia <- function(lc_cm) {
  (lc_cm / 4) * 3.1416
}
```

**Notas para el paquete:** debe permitir agregación por parcela y por especie (`sum(area_basal)` agrupado), ya que el área basal total es la base para calcular la dominancia relativa del IVI.

---

### 3.9. Cobertura (área de copa) — §6.9

**Definición en la guía:** `AC = 3,1416 × (DC/2)²`, expresada como área (m²) y como porcentaje del área muestral.

```r
area_copa <- function(dc_m) {
  3.1416 * (dc_m / 2)^2
}

cobertura_relativa <- function(area_copa_total, area_parcela) {
  (area_copa_total / area_parcela) * 100
}
```

**Notas para el paquete:** para herbazales, la guía indica medir cobertura relativa directamente en campo (no a partir del diámetro individual), por lo que la función debe aceptar también un input directo de porcentaje de cobertura observada.

---

### 3.10. Volumen maderable — §6.10

**Definición en la guía:** `V = AB × A × Fm`, donde *Fm* es el factor de forma (valor por defecto sugerido: 0,70 para bosques húmedos tropicales, según Malleux 1982).

```r
volumen_maderable <- function(area_basal_m2, altura_m, factor_forma = 0.70) {
  area_basal_m2 * altura_m * factor_forma
}
```

**Paquete de referencia para ampliar:** `BIOMASS` (Réjou-Méchain et al.) incluye funciones para estimar volumen/biomasa a partir de DAP, altura y densidad de madera, con bases de datos de densidad de madera por especie/género (`BIOMASS::getWoodDensity()`), útil como complemento cuando no se dispone de estudios locales de factor de forma.

---

### 3.11. Biomasa aérea arbórea — §6.11

**Definición en la guía:** `P = D × V`, donde *D* es la densidad básica de la madera (g/cm³ o t/m³) y *V* el volumen maderable en pie (m³).

```r
biomasa_aerea <- function(densidad_madera, volumen_m3) {
  densidad_madera * volumen_m3   # toneladas
}
```

**Para herbazales:** la guía indica un método destructivo (extraer, secar y pesar 1 m²), por lo que la función correspondiente debe aceptar un input de peso seco medido directamente, no calculado.

**Paquete de referencia:** `BIOMASS::computeAGB()` implementa ecuaciones alométricas estándar (Chave et al.) que pueden usarse como método alternativo/complementario al enfoque volumétrico de la guía.

---

### 3.12. Índice de Valor de Importancia (IVI) — §6.12

**Definición en la guía:** `IVI = Abundancia% + Dominancia% + Frecuencia%` (suma total = 300%).

```r
BiodiversityR::importancevalue(x, site = "parcela", species = "especie",
                                 count = "n_individuos", basal = "area_basal",
                                 factor = "parcela")
```

Si se prefiere no depender de `BiodiversityR`, función propia:
```r
ivi <- function(abundancia_rel, dominancia_rel, frecuencia_rel) {
  abundancia_rel + dominancia_rel + frecuencia_rel
}
Donde cada componente ya debe estar expresado en porcentaje relativo (suma de cada componente = 100%).

**Notas para el paquete:** esta función depende directamente de las funciones de §3.3 (abundancia relativa), §3.5 (frecuencia relativa) y §3.8 (dominancia relativa vía área basal), por lo que conviene construirla como una función "orquestadora" que llame a las tres.

---

### 3.13. Índice de diversidad Shannon-Wiener (H') — §6.13

**Definición en la guía:** `H' = -∑(pi)(log₂ pi)`, usando **logaritmo base 2**.

```r
vegan::diversity(x, index = "shannon")   # por defecto usa log natural (base e)
```

⚠️ **Ajuste obligatorio:** la guía especifica explícitamente log₂, mientras que `vegan::diversity()` usa logaritmo natural por defecto. Conversión:
```r
shannon_log2 <- function(x) {
  vegan::diversity(x, index = "shannon") / log(2)
}
```

**Notas para el paquete:** documentar claramente esta diferencia de base logarítmica para evitar resultados no comparables con estudios que citen la guía.

---

### 3.14. Índices agrostológicos (pastizales) — §6.14

**Definición en la guía:** cuatro sub-índices (especies deseables/decrecientes, forrajero, suelo desnudo/roca/pavimento de erosión, vigor), ponderados 50/20/20/10 para obtener la "condición del pastizal" (5 categorías: excelente, buena, regular, pobre, muy pobre).

No existe equivalente en CRAN (es metodología específica peruana, Flórez 2005). Debe implementarse íntegramente como función propia:

```r
condicion_pastizal <- function(indice_deseables, indice_forrajero,
                                indice_suelo, indice_vigor) {
  puntaje <- indice_deseables * 0.50 + indice_forrajero * 0.20 +
             indice_suelo * 0.20 + indice_vigor * 0.10

  categoria <- cut(puntaje,
    breaks = c(-Inf, 22, 36, 53, 78, 100),
    labels = c("Muy pobre", "Pobre", "Regular", "Buena", "Excelente"))

  list(puntaje = puntaje, categoria = categoria)
}
```

**Notas para el paquete:** cada sub-índice requiere su propia función auxiliar (cálculo de puntos por especie según tablas de referencia de Flórez 2005, no incluidas en la guía actual); se recomienda dejarlas como funciones separadas y documentar que dependen de tablas de calificación externas al alcance de este documento.

---

## 4. Dependencias recomendadas para el paquete

| Paquete | Uso principal | Obligatorio / Complementario |
|---|---|---|
| `vegan` | Riqueza, diversidad beta, Shannon, curva de acumulación | Obligatorio |
| `BiodiversityR` | Cálculo directo de IVI | Recomendado |
| `BIOMASS` | Estimación alométrica de volumen/biomasa, densidad de madera por especie | Complementario |
| `iNEXT` | Rarefacción/extrapolación con intervalos de confianza | Complementario |
| `betapart` | Partición de diversidad beta (turnover/anidamiento) | Complementario |
| `dplyr` / `tidyr` | Manipulación de datos "long" ↔ matriz de comunidad | Obligatorio (utilitario interno) |
| `ggplot2` | Visualización (curvas de acumulación, distribución diamétrica) | Recomendado |

---

## 5. Consideraciones generales para el diseño del paquete

1. **Unidad de entrada estandarizada:** definir una clase o estructura de datos interna (p. ej. `inventario_flora`) que valide los campos mínimos requeridos (sección 1) antes de ejecutar cualquier función.
2. **Conversión automática long ↔ matriz de comunidad:** casi todas las funciones de `vegan` requieren matriz de sitios × especies; el paquete debe ofrecer una función de conversión reutilizable (p. ej. `long_to_comm()`).
3. **Parámetros regionales configurables:** valores como el tamaño de clase diamétrica (5 o 10 cm), el DAP mínimo (5 o 10 cm) y el factor de forma (0,70 por defecto) dependen del tipo de bosque/región según la guía (cuadros n.° 8 y n.° 14) — deben quedar parametrizados, no hardcodeados.
4. **Trazabilidad con la guía:** cada función exportada debe documentar en su `roxygen2` la sección de la guía (§6.x) y la fórmula original, para mantener trazabilidad normativa (útil si el paquete se usará en estudios ambientales sujetos al SEIA/ZEE).
5. **Diferencias de convención a documentar explícitamente:**
   - Shannon-Wiener: log₂ (guía) vs. log natural (`vegan` por defecto).
   - Jaccard/Morisita-Horn: similitud (guía) vs. disimilitud (`vegan::vegdist`) — requiere `1 - x`.

---

*Documento elaborado como insumo técnico para el desarrollo de un paquete en R, con base en la Guía de inventario de la flora y vegetación (MINAM, 2015).*
