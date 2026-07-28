# Configuración global para la aplicación Shiny de floraveg
suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(DT)
  library(ggplot2)
  library(plotly)
  library(vegan)
  library(rlang)
})

# Cargar el paquete floraveg si está instalado y exponer módulos internos.
#
# shinyapps.io instala el paquete como dependencia, pero `library(floraveg)` solo
# adjunta las funciones exportadas. Los módulos Shiny no exportados siguen en el
# namespace del paquete, por eso se copian al ambiente de la app.
if (requireNamespace("floraveg", quietly = TRUE)) {
  suppressPackageStartupMessages(library(floraveg))

  floraveg_ns <- asNamespace("floraveg")
  internal_patterns <- c(
    "^mod_",
    "^fv_",
    "^standardize_inventory$",
    "^validate_inventario$"
  )
  internal_names <- unique(unlist(lapply(
    internal_patterns,
    function(pattern) ls(floraveg_ns, pattern = pattern)
  )))

  for (name in internal_names) {
    assign(name, get(name, envir = floraveg_ns), envir = environment())
  }
} else {
  # Carga de respaldo para despliegues independientes en Shiny Server / shinyapps.io.
  r_paths <- c("R", "../../R", "../R")
  r_dir <- r_paths[dir.exists(r_paths)][1]
  if (!is.na(r_dir)) {
    r_files <- list.files(r_dir, pattern = "\\.[RR]$", full.names = TRUE)
    lapply(r_files, source, local = environment())
  }
}
