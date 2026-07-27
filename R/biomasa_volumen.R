#' Base de Datos de Referencia Neotropical para Densidad Básica de la Madera (g/cm³)
#' @export
densidades_referencia_neotropical <- c(
  "Cedrela odorata" = 0.45,
  "Swietenia macrophylla" = 0.53,
  "Ceiba pentandra" = 0.25,
  "Guarea guidonia" = 0.58,
  "Inga edulis" = 0.55,
  "Dipteryx micrantha" = 0.88,
  "Buchenavia capitata" = 0.65,
  "Eschweilera coriacea" = 0.78,
  "Protium puncticulatum" = 0.52,
  "Handroanthus serratifolius" = 0.95,
  "Hevea brasiliensis" = 0.56,
  "Calycophyllum spruceanum" = 0.72,
  "Mauritia flexuosa" = 0.30,
  "Ochroma pyramidale" = 0.15,
  "Jacaranda copaia" = 0.42,
  # Géneros (Fallbacks)
  "Cedrela" = 0.45,
  "Swietenia" = 0.53,
  "Ceiba" = 0.28,
  "Guarea" = 0.58,
  "Inga" = 0.54,
  "Dipteryx" = 0.86,
  "Buchenavia" = 0.65,
  "Eschweilera" = 0.76,
  "Protium" = 0.54,
  "Handroanthus" = 0.92,
  "Hevea" = 0.56,
  "Calycophyllum" = 0.72,
  "Mauritia" = 0.30,
  "Ochroma" = 0.15,
  "Jacaranda" = 0.42
)

#' Obtener Densidades Específicas de la Madera por Especie o Género
#'
#' Asigna valores de densidad básica de la madera (g/cm3) consultando un diccionario
#' de referencia por especie (ej. 'Cedrela odorata'), por género (ej. 'Cedrela') o retornando
#' un valor estándar predeterminado en caso de no encontrarse coincidencia.
#'
#' @param especies Vector de caracteres con nombres científicos o identificadores de especie.
#' @param db_densidades Vector nombrado opcional con valores de densidad (g/cm3). Si es \code{NULL},
#'   se utiliza la base de referencia neotropical interna.
#' @param default Valor numérico por defecto (g/cm3) para especies o géneros no encontrados. Por defecto \code{0.60}.
#'
#' @return Un vector numérico de densidades básicas de la madera de la misma longitud que \code{especies}.
#' @export
#' @examples
#' especies <- c("Cedrela odorata", "Inga edulis", "Especie desconocida")
#' obtener_densidad_madera(especies, default = 0.60)
obtener_densidad_madera <- function(especies, db_densidades = NULL, default = 0.60) {
  if (is.null(db_densidades)) {
    db_densidades <- densidades_referencia_neotropical
  }

  especies <- as.character(especies)
  generos <- sub(" .*", "", especies)

  densidades <- rep(as.numeric(default), length(especies))

  for (i in seq_along(especies)) {
    sp <- especies[i]
    gen <- generos[i]

    if (!is.na(sp) && sp %in% names(db_densidades)) {
      densidades[i] <- as.numeric(db_densidades[[sp]])
    } else if (!is.na(gen) && gen %in% names(db_densidades)) {
      densidades[i] <- as.numeric(db_densidades[[gen]])
    }
  }

  densidades
}

#' Volumen Maderable (§6.10 MINAM 2015)
#'
#' Estima el volumen maderable en pie (m3) a partir del área basal (m2), la altura (m)
#' y un factor de forma ($F_m$).
#'
#' @param area_basal_m2 Area basal en metros cuadrados (m2).
#' @param altura_m Altura comercial o total del árbol en metros (m).
#' @param factor_forma Factor de forma del fuste. Por defecto \code{0.70} (bosques tropicales húmedos, Malleux 1982).
#'
#' @return Vector numérico con el volumen maderable en metros cúbicos (m3).
#' @export
#' @examples
#' volumen_maderable(area_basal_m2 = 0.25, altura_m = 18, factor_forma = 0.70)
volumen_maderable <- function(area_basal_m2, altura_m, factor_forma = 0.70) {
  if (any(area_basal_m2 < 0 | altura_m < 0 | factor_forma <= 0, na.rm = TRUE)) {
    stop("Los parametros de entrada deben ser mayores o iguales a 0.", call. = FALSE)
  }
  area_basal_m2 * altura_m * factor_forma
}

#' Biomasa Aérea (§6.11 MINAM 2015)
#'
#' Estima la biomasa aérea para estratos arbóreos (P = D * V) o para estratos herbáceos (vía peso seco por metro cuadrado).
#'
#' @param densidad_madera Densidad básica de la madera (g/cm3 o t/m3). Requerido para arbóreas.
#' @param volumen_m3 Volumen maderable en m3. Requerido para arbóreas.
#' @param peso_seco_g_m2 Peso seco en gramos por m2 (para método destructivo de herbazales).
#' @param area_ha Área total en hectáreas si se desea escalar el resultado a nivel de lote/sitio.
#'
#' @return Biomasa estimada en toneladas (t).
#' @export
#' @examples
#' # Biomasa arbórea
#' biomasa_aerea(densidad_madera = 0.60, volumen_m3 = 3.15)
#'
#' # Biomasa en herbazal (peso seco en 1 m2 escalado a 1 ha)
#' biomasa_aerea(peso_seco_g_m2 = 120, area_ha = 1)
biomasa_aerea <- function(densidad_madera = NULL, volumen_m3 = NULL,
                          peso_seco_g_m2 = NULL, area_ha = NULL) {
  if (!is.null(densidad_madera) && !is.null(volumen_m3)) {
    biomasa_ton <- densidad_madera * volumen_m3
    return(biomasa_ton)
  }

  if (!is.null(peso_seco_g_m2)) {
    biomasa_ton_ha <- peso_seco_g_m2 * 0.01
    if (!is.null(area_ha)) {
      return(biomasa_ton_ha * area_ha)
    }
    return(biomasa_ton_ha)
  }

  stop("Debe proveer ('densidad_madera' y 'volumen_m3') o 'peso_seco_g_m2'.", call. = FALSE)
}
