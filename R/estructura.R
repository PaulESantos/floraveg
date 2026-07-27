#' Abundancia Absoluta y Relativa (§6.3 MINAM 2015)
#'
#' Calcula la abundancia absoluta (número de individuos) y relativa (%) por especie.
#'
#' @param datos Data frame con los datos de inventario.
#' @param especie Nombre de la columna de especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Si es \code{NULL}, se cuenta el número de filas por especie. Por defecto \code{"abundancia"}.
#' @param tipo Carácter; \code{"ambas"}, \code{"absoluta"} o \code{"relativa"}.
#'
#' @return Data frame ordenado por abundancia decreciente con especie, n_individuos y abundancia_relativa_pct.
#' @export
#' @examples
#' df <- data.frame(
#'   especie = c("SpA", "SpA", "SpB", "SpC", "SpC", "SpC"),
#'   abundancia = c(5, 5, 10, 2, 3, 5)
#' )
#' abundancia(df)
abundancia <- function(datos, especie = "especie", abundancia = "abundancia",
                       tipo = c("ambas", "absoluta", "relativa")) {
  tipo <- match.arg(tipo)
  validate_inventario(datos, especie)

  if (!is.null(abundancia) && abundancia %in% names(datos)) {
    df_abs <- stats::aggregate(
      datos[[abundancia]],
      by = list(especie = datos[[especie]]),
      FUN = sum,
      na.rm = TRUE
    )
    names(df_abs)[2] <- "n_individuos"
  } else {
    df_abs <- stats::aggregate(
      rep(1, nrow(datos)),
      by = list(especie = datos[[especie]]),
      FUN = length
    )
    names(df_abs)[2] <- "n_individuos"
  }

  total_ind <- sum(df_abs$n_individuos)
  df_abs$abundancia_relativa_pct <- (df_abs$n_individuos / total_ind) * 100

  df_res <- df_abs[order(-df_abs$n_individuos), ]
  rownames(df_res) <- NULL

  if (tipo == "absoluta") {
    return(df_res[, c("especie", "n_individuos")])
  } else if (tipo == "relativa") {
    return(df_res[, c("especie", "abundancia_relativa_pct")])
  }
  df_res
}

#' Densidad Poblacional (§6.4 MINAM 2015)
#'
#' Calcula la densidad poblacional (individuos por hectárea), considerando opcionalmente conteo de tocones.
#'
#' @param n_individuos Número total o vector de individuos.
#' @param area_ha Área del muestreo en hectáreas (ha).
#' @param tocones Conteo adicional de tocones. Por defecto \code{0}.
#'
#' @return Densidad en individuos/ha.
#' @export
#' @examples
#' densidad_poblacional(n_individuos = 450, area_ha = 0.5)
densidad_poblacional <- function(n_individuos, area_ha, tocones = 0) {
  if (area_ha <= 0) {
    stop("El valor de 'area_ha' debe ser mayor a 0.", call. = FALSE)
  }
  (n_individuos + tocones) / area_ha
}

#' Frecuencia Absoluta y Relativa (§6.5 MINAM 2015)
#'
#' Calcula la frecuencia absoluta (número de unidades muestrales donde aparece la especie) y la frecuencia relativa (%).
#'
#' @param datos Data frame con datos de inventario en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna de sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de especie. Por defecto \code{"especie"}.
#'
#' @return Data frame con especie, frecuencia_absoluta, frecuencia_pct y frecuencia_relativa_pct.
#' @export
#' @examples
#' df <- data.frame(
#'   sitio = c("P1", "P1", "P2", "P3"),
#'   especie = c("SpA", "SpB", "SpA", "SpA")
#' )
#' frecuencia(df)
frecuencia <- function(datos, sitio = "sitio", especie = "especie") {
  if (is.matrix(datos)) {
    mat_bin <- datos > 0
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, fill = 0)
    mat_bin <- mat > 0
  }

  total_sitios <- nrow(mat_bin)
  freq_abs <- colSums(mat_bin)
  freq_pct <- (freq_abs / total_sitios) * 100
  freq_rel_pct <- (freq_pct / sum(freq_pct)) * 100

  res <- data.frame(
    especie = names(freq_abs),
    frecuencia_absoluta = as.numeric(freq_abs),
    frecuencia_pct = as.numeric(freq_pct),
    frecuencia_relativa_pct = as.numeric(freq_rel_pct),
    stringsAsFactors = FALSE
  )

  res[order(-res$frecuencia_absoluta), ]
}

#' Área Basal (§6.8 MINAM 2015)
#'
#' Calcula el área basal individual o agregada a partir del Diámetro a la Altura del Pecho (DAP en cm)
#' o de la Longitud de Circunferencia (LC en cm).
#'
#' @param dap_cm Vector numérico con el DAP en centímetros.
#' @param lc_cm Vector numérico opcional con la longitud de circunferencia en cm.
#' @param unidad_salida Carácter; \code{"m2"} (metros cuadrados) o \code{"cm2"}. Por defecto \code{"m2"}.
#'
#' @return Vector numérico con el área basal en la unidad especificada.
#' @export
#' @examples
#' area_basal(dap_cm = c(15, 25, 40))
area_basal <- function(dap_cm = NULL, lc_cm = NULL, unidad_salida = c("m2", "cm2")) {
  unidad_salida <- match.arg(unidad_salida)

  if (is.null(dap_cm) && is.null(lc_cm)) {
    stop("Debe proveer 'dap_cm' o 'lc_cm'.", call. = FALSE)
  }

  if (!is.null(dap_cm)) {
    ab_cm2 <- 0.7854 * (dap_cm^2)
  } else {
    ab_cm2 <- (lc_cm / 4) * 3.1416
  }

  if (unidad_salida == "m2") {
    return(ab_cm2 / 10000)
  }
  ab_cm2
}

#' Cobertura (Área de Copa) (§6.9 MINAM 2015)
#'
#' Calcula el área de copa individual o la cobertura relativa porcentual respecto al área del sitio.
#'
#' @param dc_m Vector numérico con el diámetro de copa en metros.
#' @param porcentaje_observado Vector numérico opcional con cobertura % observada directamente (p. ej. en herbazales).
#' @param area_parcela_m2 Área de la unidad muestral en metros cuadrados (m2).
#'
#' @return Lista o data frame con área de copa (m2) y cobertura relativa (%).
#' @export
#' @examples
#' cobertura(dc_m = c(3, 4.5, 6), area_parcela_m2 = 500)
cobertura <- function(dc_m = NULL, porcentaje_observado = NULL, area_parcela_m2 = NULL) {
  if (!is.null(porcentaje_observado)) {
    return(data.frame(cobertura_relativa_pct = porcentaje_observado))
  }

  if (is.null(dc_m)) {
    stop("Debe proveer 'dc_m' o 'porcentaje_observado'.", call. = FALSE)
  }

  ac_m2 <- 3.1416 * ((dc_m / 2)^2)

  if (!is.null(area_parcela_m2)) {
    cob_pct <- (ac_m2 / area_parcela_m2) * 100
    return(data.frame(area_copa_m2 = ac_m2, cobertura_relativa_pct = cob_pct))
  }

  data.frame(area_copa_m2 = ac_m2)
}

#' Distribución Diamétrica (§6.6 MINAM 2015)
#'
#' Clasifica los valores de DAP en clases diamétricas estandarizadas (5 cm o 10 cm según la región/ecosistema)
#' y prepara la tabla de frecuencias para la curva de distribución J invertida.
#'
#' @param dap_cm Vector numérico de diámetros a la altura del pecho (cm).
#' @param ancho_clase Ancho de la clase diamétrica en cm (10 cm por defecto para selva, 5 cm para costa/sierra).
#' @param min_dap DAP mínimo a considerar. Por defecto \code{0}.
#'
#' @return Lista con la tabla de frecuencias por clase, marcas de clase y el objeto de ajuste no lineal \code{nls} si aplica.
#' @export
#' @examples
#' daps <- c(12, 15, 18, 22, 25, 33, 41, 45, 52, 68)
#' distribucion_diametrica(daps, ancho_clase = 10)
distribucion_diametrica <- function(dap_cm, ancho_clase = 10, min_dap = 0) {
  dap_filtrado <- dap_cm[dap_cm >= min_dap & !is.na(dap_cm)]

  if (length(dap_filtrado) == 0) {
    stop("No hay valores de DAP validos que cumplan la condicion min_dap.", call. = FALSE)
  }

  max_dap <- max(dap_filtrado)
  cortes <- seq(floor(min_dap), ceiling(max_dap) + ancho_clase, by = ancho_clase)

  clases <- cut(dap_filtrado, breaks = cortes, right = FALSE, include.lowest = TRUE)
  tabla_freq <- as.data.frame(table(Clase = clases))

  # Marcas de clase
  tabla_freq$marca_clase <- cortes[-length(cortes)] + (ancho_clase / 2)
  names(tabla_freq)[2] <- "frecuencia"

  # Intento de ajuste J invertida: Y = K * exp(-a * X)
  modelo_j <- tryCatch({
    stats::nls(
      frecuencia ~ K * exp(-a * marca_clase),
      data = tabla_freq[tabla_freq$frecuencia > 0, ],
      start = list(K = max(tabla_freq$frecuencia), a = 0.1)
    )
  }, error = function(e) NULL)

  list(
    tabla_clases = tabla_freq,
    ancho_clase = ancho_clase,
    modelo_j_invertida = modelo_j
  )
}
