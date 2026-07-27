#' Estructura de Regeneración Natural y Estadios Forestales (SINIA / MINAM §2.1.4.3.2)
#'
#' Clasifica árboles e individuos forestales en categorías de regeneración y desarrollo:
#' Brinzales (DAP < 2.5 cm / plántulas), Latizales (DAP de 2.5 a 10 cm) y Fustales (DAP >= 10 cm).
#'
#' @param dap_cm Vector numérico con el Diámetro a la Altura del Pecho (DAP en cm).
#' @param altura_m Vector numérico opcional de alturas totales (m) para afinar plántulas.
#'
#' @return Vector de factores con las categorías ("Brinzal", "Latizal", "Fustal").
#' @export
#' @examples
#' regeneracion_natural(dap_cm = c(0.5, 1.2, 5.5, 12.0, 45.0))
regeneracion_natural <- function(dap_cm, altura_m = NULL) {
  if (any(dap_cm < 0, na.rm = TRUE)) {
    stop("Los valores de DAP deben ser mayores o iguales a 0.", call. = FALSE)
  }

  estadios <- cut(
    dap_cm,
    breaks = c(-Inf, 2.5, 10, Inf),
    labels = c("Brinzal", "Latizal", "Fustal"),
    right = FALSE
  )

  as.factor(estadios)
}

#' Proporción de Estados Fenológicos (SINIA / MINAM Tabla 2.1.4-8)
#'
#' Cuantifica la proporción porcentual de los estados fenológicos registrados en campo
#' (Floración, Fructificación, Vegetativo, Plántula).
#'
#' @param vector_fenologia Vector de caracteres o factores con la observación fenológica por individuo.
#'
#' @return Data frame con la frecuencia observada y el porcentaje de cada estado fenológico.
#' @export
#' @examples
#' fenologia <- c("Floracion", "Floracion", "Fructificacion", "Vegetativo", "Vegetativo", "Vegetativo")
#' proporcion_fenologia(fenologia)
proporcion_fenologia <- function(vector_fenologia) {
  vec_clean <- vector_fenologia[!is.na(vector_fenologia)]
  if (length(vec_clean) == 0) {
    stop("El vector de fenologia no contiene observaciones validas.", call. = FALSE)
  }

  tabla <- table(Estado = vec_clean)
  df_res <- as.data.frame(tabla)
  names(df_res) <- c("estado_fenologico", "frecuencia")
  df_res$porcentaje <- (df_res$frecuencia / sum(df_res$frecuencia)) * 100

  df_res[order(-df_res$frecuencia), ]
}
