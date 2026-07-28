#' Lanzadores Standalone de Módulos Shiny de floraveg
#'
#' Estas funciones permiten ejecutar cada módulo de la aplicación Shiny de forma 100% independiente.
#'
#' @param launch.browser Lógico; abre en el navegador. Por defecto TRUE.
#' @return Objeto Shiny app (ejecución interactiva).
#' @name run_modules
#' @examples
#' if (interactive()) {
#'   run_mod_modelo_datos()
#'   run_mod_diversidad()
#'   run_mod_estructura()
#'   run_mod_biomasa()
#'   run_mod_ivi()
#'   run_mod_codigo_r()
#' }
NULL

#' @rdname run_modules
#' @export
run_mod_modelo_datos <- function(launch.browser = TRUE) {
  if (!requireNamespace("shiny", quietly = TRUE) || !requireNamespace("bslib", quietly = TRUE)) {
    stop("Los paquetes 'shiny' y 'bslib' son requeridos.", call. = FALSE)
  }
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, bootswatch = "flatly", primary = "#1b4d3e"),
    mod_modelo_datos_ui("mod_standalone")
  )
  server <- function(input, output, session) {
    mod_modelo_datos_server("mod_standalone")
  }
  shiny::shinyApp(ui, server, options = list(launch.browser = launch.browser))
}

#' @rdname run_modules
#' @export
run_mod_diversidad <- function(launch.browser = TRUE) {
  if (!requireNamespace("shiny", quietly = TRUE) || !requireNamespace("bslib", quietly = TRUE)) {
    stop("Los paquetes 'shiny' y 'bslib' son requeridos.", call. = FALSE)
  }
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, bootswatch = "flatly", primary = "#1b4d3e"),
    mod_diversidad_ui("mod_standalone")
  )
  server <- function(input, output, session) {
    mod_diversidad_server("mod_standalone", datos_reactive = NULL)
  }
  shiny::shinyApp(ui, server, options = list(launch.browser = launch.browser))
}

#' @rdname run_modules
#' @export
run_mod_estructura <- function(launch.browser = TRUE) {
  if (!requireNamespace("shiny", quietly = TRUE) || !requireNamespace("bslib", quietly = TRUE)) {
    stop("Los paquetes 'shiny' y 'bslib' son requeridos.", call. = FALSE)
  }
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, bootswatch = "flatly", primary = "#1b4d3e"),
    mod_estructura_ui("mod_standalone")
  )
  server <- function(input, output, session) {
    mod_estructura_server("mod_standalone", datos_reactive = NULL)
  }
  shiny::shinyApp(ui, server, options = list(launch.browser = launch.browser))
}

#' @rdname run_modules
#' @export
run_mod_biomasa <- function(launch.browser = TRUE) {
  if (!requireNamespace("shiny", quietly = TRUE) || !requireNamespace("bslib", quietly = TRUE)) {
    stop("Los paquetes 'shiny' y 'bslib' son requeridos.", call. = FALSE)
  }
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, bootswatch = "flatly", primary = "#1b4d3e"),
    mod_biomasa_volumen_ui("mod_standalone")
  )
  server <- function(input, output, session) {
    mod_biomasa_volumen_server("mod_standalone", datos_reactive = NULL)
  }
  shiny::shinyApp(ui, server, options = list(launch.browser = launch.browser))
}

#' @rdname run_modules
#' @export
run_mod_ivi <- function(launch.browser = TRUE) {
  if (!requireNamespace("shiny", quietly = TRUE) || !requireNamespace("bslib", quietly = TRUE)) {
    stop("Los paquetes 'shiny' y 'bslib' son requeridos.", call. = FALSE)
  }
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, bootswatch = "flatly", primary = "#1b4d3e"),
    mod_ivi_ui("mod_standalone")
  )
  server <- function(input, output, session) {
    mod_ivi_server("mod_standalone", datos_reactive = NULL)
  }
  shiny::shinyApp(ui, server, options = list(launch.browser = launch.browser))
}

#' @rdname run_modules
#' @export
run_mod_codigo_r <- function(launch.browser = TRUE) {
  if (!requireNamespace("shiny", quietly = TRUE) || !requireNamespace("bslib", quietly = TRUE)) {
    stop("Los paquetes 'shiny' y 'bslib' son requeridos.", call. = FALSE)
  }
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, bootswatch = "flatly", primary = "#1b4d3e"),
    mod_codigo_r_ui("mod_standalone")
  )
  server <- function(input, output, session) {
    mod_codigo_r_server("mod_standalone", datos_reactive = NULL)
  }
  shiny::shinyApp(ui, server, options = list(launch.browser = launch.browser))
}
