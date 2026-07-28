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

# Cargar el paquete floraveg si está instalado, o los archivos de código R locales
if (requireNamespace("floraveg", quietly = TRUE)) {
  suppressPackageStartupMessages(library(floraveg))
} else {
  # Carga de respaldo para despliegues independientes en Shiny Server / shinyapps.io
  r_paths <- c("R", "../../R", "../R")
  r_dir <- r_paths[dir.exists(r_paths)][1]
  if (!is.na(r_dir)) {
    r_files <- list.files(r_dir, pattern = "\\.[RR]$", full.names = TRUE)
    lapply(r_files, source)
  }
}
