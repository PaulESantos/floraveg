#' floraveg: Indicadores Ecológicos y de Vegetación según Guía MINAM
#'
#' Paquete en R para automatizar el cálculo de parámetros estructurales,
#' índices de diversidad, biomasa, volumen maderable e Índice de Valor de Importancia (IVI),
#' conforme a la Guía de Inventario de la Flora y Vegetación (MINAM, 2015).
#'
#' @docType package
#' @name floraveg-package
#' @aliases floraveg
#' @keywords internal
"_PACKAGE"

# Declarar variables globales no ligadas para evitar NOTEs en R CMD check (ggplot2 aes)
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    "Sitio", "Valor", "Metrica", "Sitio1", "Sitio2", "Similitud",
    "Sitios", "Riqueza", "SD", "Clase", "Especie", "Componente", "frecuencia"
  ))
}
