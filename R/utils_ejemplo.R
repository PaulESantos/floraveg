#' Generar Datos de Ejemplo Deterministas (Sin Semilla Aleatoria)
#'
#' Funcion auxiliar interna para proveer un conjunto de datos de ejemplo
#' determinista para la aplicacion Shiny sin usar \code{set.seed()} ni
#' funciones de generacion aleatoria.
#'
#' @return Un \code{data.frame} con 60 filas y columnas de inventario estandar:
#'   \code{sitio}, \code{especie}, \code{abundancia}, \code{dap_cm}, \code{altura_m}, \code{dc_m}.
#' @noRd
obtener_datos_ejemplo <- function() {
  sitios <- paste0("Parcela_", rep(1:4, each = 15))
  especies_base <- c(
    "Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra",
    "Guarea guidonia", "Inga edulis", "Dipteryx micrantha",
    "Buchenavia capitata", "Eschweilera coriacea", "Protium puncticulatum"
  )
  especies <- rep_len(especies_base, 60)

  abundancia <- c(
    12, 5, 8, 3, 15, 1, 9, 4, 11, 7, 2, 14, 6, 10, 13,
    8, 3, 12, 5, 1, 9, 14, 2, 7, 11, 4, 15, 6, 10, 13,
    5, 11, 2, 9, 14, 3, 8, 1, 12, 6, 15, 4, 7, 10, 13,
    9, 2, 11, 5, 14, 1, 8, 12, 3, 6, 15, 7, 4, 10, 13
  )

  dap_cm <- c(
    25.4, 42.1, 15.8, 68.3, 31.2, 12.0, 54.6, 22.1, 78.4, 19.5, 33.7, 85.0, 14.2, 48.9, 62.3,
    28.1, 45.6, 18.2, 71.0, 34.5, 13.8, 57.2, 24.3, 80.1, 21.0, 36.4, 82.5, 16.0, 51.2, 65.0,
    23.5, 40.8, 14.5, 66.0, 29.8, 11.2, 52.0, 20.4, 75.8, 18.0, 31.5, 81.0, 13.5, 46.8, 59.8,
    26.8, 43.9, 16.9, 69.5, 32.4, 12.9, 55.8, 23.0, 77.2, 20.1, 35.0, 83.8, 15.1, 50.0, 63.5
  )

  altura_m <- c(
    12.5, 18.2, 8.4, 25.0, 14.1, 6.5, 21.3, 10.2, 28.5, 9.1, 15.6, 30.2, 7.8, 20.4, 24.1,
    13.2, 19.0, 9.0, 26.1, 15.0, 7.1, 22.0, 11.0, 29.2, 9.8, 16.4, 29.5, 8.2, 21.1, 25.0,
    11.8, 17.5, 7.9, 24.2, 13.5, 6.0, 20.5, 9.5, 27.6, 8.5, 14.8, 28.8, 7.2, 19.6, 23.2,
    12.9, 18.7, 8.7, 25.5, 14.6, 6.8, 21.8, 10.6, 28.1, 9.4, 16.0, 29.9, 8.0, 20.7, 24.5
  )

  dc_m <- c(
    4.5, 7.2, 3.1, 9.8, 5.0, 2.2, 8.1, 3.9, 11.4, 3.2, 5.8, 12.0, 2.8, 7.9, 9.5,
    4.8, 7.6, 3.4, 10.2, 5.3, 2.5, 8.5, 4.2, 11.8, 3.5, 6.1, 11.5, 3.0, 8.2, 9.9,
    4.2, 6.8, 2.8, 9.4, 4.7, 2.0, 7.7, 3.6, 11.0, 2.9, 5.4, 11.2, 2.5, 7.5, 9.0,
    4.6, 7.4, 3.2, 10.0, 5.1, 2.3, 8.3, 4.0, 11.6, 3.3, 5.9, 11.8, 2.9, 8.0, 9.7
  )

  data.frame(
    sitio = sitios,
    especie = especies,
    abundancia = abundancia,
    dap_cm = dap_cm,
    altura_m = altura_m,
    dc_m = dc_m,
    stringsAsFactors = FALSE
  )
}
