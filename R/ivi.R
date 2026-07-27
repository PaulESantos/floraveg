#' Índice de Valor de Importancia (IVI) (§6.12 MINAM 2015)
#'
#' Calcula el Índice de Valor de Importancia Ecológica (IVI) para cada especie a partir de la suma
#' de la Abundancia Relativa (%), Dominancia Relativa (%) calculada por Área Basal, y Frecuencia Relativa (%).
#'
#' @param datos Data frame con datos de inventario.
#' @param sitio Nombre de la columna de sitio/parcela. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia (o número de individuos). Por defecto \code{"abundancia"}.
#' @param dap_cm Nombre de la columna con el Diámetro a la Altura del Pecho en cm. Por defecto \code{"dap_cm"}.
#'
#' @return Data frame ordenado por IVI decreciente con las columnas: \code{especie}, \code{n_individuos}, \code{abundancia_rel_pct}, \code{area_basal_m2}, \code{dominancia_rel_pct}, \code{frecuencia_rel_pct} e \code{ivi}.
#' @export
#' @examples
#' df <- data.frame(
#'   sitio = c("P1", "P1", "P1", "P2", "P2"),
#'   especie = c("SpA", "SpB", "SpC", "SpA", "SpB"),
#'   abundancia = c(5, 3, 2, 8, 4),
#'   dap_cm = c(20, 15, 10, 25, 18)
#' )
#' calc_ivi(df)
calc_ivi <- function(datos, sitio = "sitio", especie = "especie",
                     abundancia = "abundancia", dap_cm = "dap_cm") {
  validate_inventario(datos, c(sitio, especie))

  # 1. Abundancia Relativa
  df_ab <- abundancia(datos, especie = especie, abundancia = abundancia, tipo = "ambas")

  # 2. Frecuencia Relativa
  df_fr <- frecuencia(datos, sitio = sitio, especie = especie)

  # 3. Dominancia Relativa (Área Basal)
  if (dap_cm %in% names(datos)) {
    datos$ab_temp_m2 <- area_basal(dap_cm = datos[[dap_cm]], unidad_salida = "m2")
    df_dom <- stats::aggregate(
      datos$ab_temp_m2,
      by = list(especie = datos[[especie]]),
      FUN = sum,
      na.rm = TRUE
    )
    names(df_dom) <- c("especie", "area_basal_m2")
    total_ab <- sum(df_dom$area_basal_m2, na.rm = TRUE)
    df_dom$dominancia_rel_pct <- (df_dom$area_basal_m2 / total_ab) * 100
  } else {
    warning("La columna 'dap_cm' no fue encontrada; la dominancia relativa se asignara igual a la abundancia relativa.", call. = FALSE)
    df_dom <- data.frame(
      especie = df_ab$especie,
      area_basal_m2 = NA_real_,
      dominancia_rel_pct = df_ab$abundancia_relativa_pct,
      stringsAsFactors = FALSE
    )
  }

  # Combinar componentes
  res <- merge(df_ab, df_dom, by = "especie", all = TRUE)
  res <- merge(res, df_fr[, c("especie", "frecuencia_relativa_pct")], by = "especie", all = TRUE)

  # Rellenar NAs si los hay
  res$abundancia_relativa_pct[is.na(res$abundancia_relativa_pct)] <- 0
  res$dominancia_rel_pct[is.na(res$dominancia_rel_pct)] <- 0
  res$frecuencia_relativa_pct[is.na(res$frecuencia_relativa_pct)] <- 0

  res$ivi <- res$abundancia_relativa_pct + res$dominancia_rel_pct + res$frecuencia_relativa_pct

  # Renombrar columnas para claridad
  names(res)[names(res) == "abundancia_relativa_pct"] <- "abundancia_rel_pct"
  names(res)[names(res) == "frecuencia_relativa_pct"] <- "frecuencia_rel_pct"

  res <- res[order(-res$ivi), ]
  rownames(res) <- NULL

  res[, c("especie", "n_individuos", "abundancia_rel_pct", "area_basal_m2",
          "dominancia_rel_pct", "frecuencia_rel_pct", "ivi")]
}
