#' Lanzador de la Aplicación Shiny de floraveg
#'
#' Inicia la interfaz gráfica interactiva del paquete \code{floraveg} en el navegador web predeterminado.
#'
#' @param launch.browser Lógico; si es \code{TRUE}, abre automáticamente el navegador. Por defecto \code{TRUE}.
#' @param port Puerto numérico opcional para el servidor Shiny.
#'
#' @return Objeto de aplicación Shiny (ejecución interactiva).
#' @export
#' @examples
#' \dontrun{
#' run_floraveg()
#' }
run_floraveg <- function(launch.browser = TRUE, port = getOption("shiny.port")) {
  appDir <- system.file("shiny", package = "floraveg")
  if (appDir == "") {
    stop("No se encontro el directorio de la aplicacion Shiny en el paquete 'floraveg'.", call. = FALSE)
  }
  shiny::runApp(appDir, launch.browser = launch.browser, port = port)
}
