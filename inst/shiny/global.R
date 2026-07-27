# Configuración global para la aplicación Shiny de floraveg
suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(DT)
  library(ggplot2)
  library(plotly)
})

if (requireNamespace("floraveg", quietly = TRUE)) {
  suppressPackageStartupMessages(library(floraveg))
}
