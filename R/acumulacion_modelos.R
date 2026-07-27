#' Modelo Paramétrico de Clench para Curvas de Acumulación (SINIA / MINAM Tabla 2.0-3)
#'
#' Ajusta el modelo no lineal de Clench (S(n) = (a * n) / (1 + b * n)) sobre los datos de acumulación
#' de especies para estimar la riqueza máxima asintótica (a / b) y evaluar la representatividad (> 70%).
#'
#' @param datos Data frame en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Por defecto \code{"abundancia"}.
#'
#' @return Lista con los coeficientes a y b, la riqueza asintótica estimada, la riqueza observada, el % de representatividad y el modelo nls.
#' @export
#' @examples
#' df <- data.frame(
#'   sitio = c("P1", "P1", "P2", "P2", "P3", "P3", "P4", "P4"),
#'   especie = c("Sp1", "Sp2", "Sp1", "Sp3", "Sp1", "Sp4", "Sp2", "Sp5"),
#'   abundancia = c(1, 2, 3, 1, 2, 4, 1, 1)
#' )
#' modelo_clench(df)
modelo_clench <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia") {
  sa <- curva_acumulacion(datos, sitio = sitio, especie = especie, abundancia = abundancia, metodo = "random")

  df_acc <- data.frame(
    muestras = sa$sites,
    riqueza = sa$richness
  )

  # Ajuste NLS: S(n) = (a * n) / (1 + b * n)
  modelo <- tryCatch({
    stats::nls(
      riqueza ~ (a * muestras) / (1 + b * muestras),
      data = df_acc,
      start = list(a = max(df_acc$riqueza), b = 0.1)
    )
  }, error = function(e) {
    NULL
  })

  if (is.null(modelo)) {
    warning("No se pudo converger en el ajuste del modelo de Clench con los datos provistos.", call. = FALSE)
    return(list(
      riqueza_observada = max(df_acc$riqueza),
      asintota_estimada = NA_real_,
      representatividad_pct = NA_real_,
      coeficientes = NULL,
      modelo = NULL
    ))
  }

  coefs <- stats::coef(modelo)
  a <- coefs["a"]
  b <- coefs["b"]
  asintota <- a / b
  s_obs <- max(df_acc$riqueza)
  rep_pct <- (s_obs / asintota) * 100

  list(
    riqueza_observada = s_obs,
    asintota_estimada = as.numeric(asintota),
    representatividad_pct = as.numeric(rep_pct),
    coeficientes = c(a = as.numeric(a), b = as.numeric(b)),
    modelo = modelo
  )
}

#' Estimadores No Paramétricos de Riqueza (SINIA / MINAM Tabla 2.0-3)
#'
#' Calcula la riqueza total de especies esperada mediante los estimadores no paramétricos
#' Chao 2, Jackknife 1, Jackknife 2 y Bootstrap.
#'
#' @param datos Data frame en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Por defecto \code{"abundancia"}.
#'
#' @return Data frame con los valores de riqueza esperada estimada por cada método.
#' @export
#' @examples
#' df <- data.frame(
#'   sitio = c("P1", "P1", "P2", "P2", "P3", "P3"),
#'   especie = c("Sp1", "Sp2", "Sp1", "Sp3", "Sp1", "Sp4"),
#'   abundancia = c(1, 2, 3, 1, 2, 4)
#' )
#' estimadores_riqueza(df)
estimadores_riqueza <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia") {
  if (is.matrix(datos)) {
    mat <- datos
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, abundancia = abundancia)
  }

  res_pool <- vegan::specpool(mat)

  data.frame(
    riqueza_observada = as.numeric(res_pool$Species),
    chao2 = as.numeric(res_pool$chao),
    jackknife1 = as.numeric(res_pool$jack1),
    jackknife2 = as.numeric(res_pool$jack2),
    bootstrap = as.numeric(res_pool$boot),
    stringsAsFactors = FALSE
  )
}
