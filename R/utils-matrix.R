#' Estandarizar nombres de columnas del inventario floristico
#'
#' Mapea automaticamente variantes comunes de nombres de columnas (plot/sitio, species/especie, abundance/abundancia).
#'
#' @param datos Data frame con el inventario floristico.
#'
#' @return Data frame estandarizado con las columnas 'sitio', 'especie' y 'abundancia'.
#' @export
standardize_inventory <- function(datos) {
  if (!is.data.frame(datos)) return(datos)

  cols <- names(datos)

  if (!"sitio" %in% cols) {
    p_col <- cols[tolower(cols) %in% c("plot", "parcela", "sitios", "plots", "estacion", "transecto")][1]
    if (!is.na(p_col)) names(datos)[names(datos) == p_col] <- "sitio"
  }

  if (!"especie" %in% cols) {
    s_col <- cols[tolower(cols) %in% c("species", "especies", "sp", "nombre_cientifico", "taxa", "taxon")][1]
    if (!is.na(s_col)) names(datos)[names(datos) == s_col] <- "especie"
  }

  if (!"abundancia" %in% cols) {
    a_col <- cols[tolower(cols) %in% c("abundance", "abundancias", "count", "conteo", "n", "ind", "individuos")][1]
    if (!is.na(a_col)) {
      names(datos)[names(datos) == a_col] <- "abundancia"
    } else {
      datos$abundancia <- 1
    }
  }

  datos
}

#' Validar estructura de datos de inventario
#'
#' Comprueba que el objeto provisto sea un data frame y contenga las columnas requeridas.
#'
#' @param datos Data.frame o tibble con los datos del inventario.
#' @param required_cols Vector de caracteres con los nombres de las columnas indispensables.
#'
#' @return El mismo data frame si la validación es exitosa.
#' @export
#' @examples
#' df <- data.frame(sitio = c("P1", "P1"), especie = c("Sp1", "Sp2"), abundancia = c(5, 2))
#' validate_inventario(df, c("sitio", "especie"))
validate_inventario <- function(datos, required_cols = c("sitio", "especie")) {
  if (!is.data.frame(datos)) {
    stop("El argumento 'datos' debe ser un data.frame o tibble.", call. = FALSE)
  }
  datos <- standardize_inventory(datos)
  missing_cols <- setdiff(required_cols, names(datos))
  if (length(missing_cols) > 0) {
    stop(
      paste0("Faltan las siguientes columnas requeridas en los datos: ",
             paste(missing_cols, collapse = ", ")),
      call. = FALSE
    )
  }
  datos
}

#' Convertir formato de inventario (long) a matriz de comunidad (sitios x especies)
#'
#' Transforma un data frame en formato tidy/long en una matriz cuantitativa o de presencia/ausencia de
#' sitios (filas) por especies (columnas), apta para funciones del paquete \code{vegan}.
#'
#' @param datos Data frame con observaciones.
#' @param sitio Nombre de la columna con el identificador del sitio o parcela. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna con el nombre taxonómico o código de especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna con la abundancia/conteo. Si es \code{NULL},
#'   se cuenta el número de registros (filas) por especie y sitio. Por defecto \code{"abundancia"}.
#' @param fill Valor numérico para rellenar ausencias. Por defecto \code{0}.
#'
#' @return Una matriz numérica de R con sitios en las filas y especies en las columnas.
#' @export
#' @examples
#' df <- data.frame(
#'   sitio = c("P1", "P1", "P2", "P2"),
#'   especie = c("SpA", "SpB", "SpA", "SpC"),
#'   abundancia = c(10, 5, 2, 8)
#' )
#' long_to_comm(df, sitio = "sitio", especie = "especie", abundancia = "abundancia")
long_to_comm <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia", fill = 0) {
  datos <- standardize_inventory(datos)
  if (!sitio %in% names(datos) && "sitio" %in% names(datos)) sitio <- "sitio"
  if (!especie %in% names(datos) && "especie" %in% names(datos)) especie <- "especie"
  if (!is.null(abundancia) && !abundancia %in% names(datos) && "abundancia" %in% names(datos)) abundancia <- "abundancia"

  validate_inventario(datos, c(sitio, especie))

  sitios_vec <- as.character(datos[[sitio]])
  especies_vec <- as.character(datos[[especie]])

  if (!is.null(abundancia) && abundancia %in% names(datos)) {
    vals <- suppressWarnings(as.numeric(datos[[abundancia]]))
    vals[is.na(vals) | !is.finite(vals)] <- 1
    df_sum <- stats::aggregate(
      vals,
      by = list(sitio = sitios_vec, especie = especies_vec),
      FUN = sum,
      na.rm = TRUE
    )
    names(df_sum)[3] <- "val"
  } else {
    df_sum <- stats::aggregate(
      rep(1, nrow(datos)),
      by = list(sitio = sitios_vec, especie = especies_vec),
      FUN = length
    )
    names(df_sum)[3] <- "val"
  }

  sitios_unicos <- sort(unique(df_sum$sitio))
  especies_unicas <- sort(unique(df_sum$especie))

  mat <- matrix(
    as.numeric(fill),
    nrow = length(sitios_unicos),
    ncol = length(especies_unicas),
    dimnames = list(sitios_unicos, especies_unicas)
  )

  for (i in seq_len(nrow(df_sum))) {
    s <- as.character(df_sum$sitio[i])
    e <- as.character(df_sum$especie[i])
    mat[s, e] <- as.numeric(df_sum$val[i])
  }

  storage.mode(mat) <- "numeric"
  mat
}

# Declaracion de variables globales para ggplot2 y R CMD check
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("x", "y", "xend", "yend", "label", "Sitio1", "Sitio2", "Similitud", "Riqueza", "Sitios", "Metrica", "Valor", "ab_m2", "vol_m3", "biomasa_ton", "dens_assigned", "sitio"))
}
