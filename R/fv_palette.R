# Shared visual palette for floraveg Shiny charts.
# Keep these values synchronized with inst/shiny/www/custom.css :root tokens.
fv_pal <- c(
  marca = "#1b4d3e",
  vegetacion = "#2f7d5c",
  suelo = "#b08968",
  agua = "#3a86c8",
  ambar = "#d98e2f",
  flor = "#8a4fae",
  alerta = "#c94f4f",
  menta = "#dcefe7",
  tinta = "#172033",
  neutro = "#64748b"
)

fv_chart_theme <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", color = fv_pal[["tinta"]]),
      plot.subtitle = ggplot2::element_text(color = fv_pal[["neutro"]]),
      axis.title = ggplot2::element_text(color = fv_pal[["tinta"]]),
      axis.text = ggplot2::element_text(color = fv_pal[["tinta"]]),
      legend.title = ggplot2::element_text(face = "bold", color = fv_pal[["tinta"]]),
      panel.grid.minor = ggplot2::element_blank()
    )
}

fv_fill_values <- function(keys) {
  mapping <- c(
    "Abundancia Rel. (%)" = fv_pal[["vegetacion"]],
    "Dominancia Rel. (%)" = fv_pal[["ambar"]],
    "Frecuencia Rel. (%)" = fv_pal[["agua"]],
    "Volumen (m3)" = fv_pal[["suelo"]],
    "Biomasa (t)" = fv_pal[["vegetacion"]],
    "Carbono (t)" = fv_pal[["vegetacion"]],
    "CO2e (t)" = fv_pal[["agua"]],
    "Brinzal" = fv_pal[["vegetacion"]],
    "Latizal" = fv_pal[["ambar"]],
    "Fustal" = fv_pal[["suelo"]],
    "Submuestreo probable" = fv_pal[["alerta"]],
    "Completitud aceptable" = fv_pal[["ambar"]],
    "Completitud robusta" = fv_pal[["vegetacion"]],
    "No evaluable" = fv_pal[["neutro"]]
  )

  vals <- unname(mapping[keys])
  vals[is.na(vals)] <- unname(fv_pal[["neutro"]])
  stats::setNames(vals, keys)
}

fv_scale_fill <- function(keys, ...) {
  ggplot2::scale_fill_manual(values = fv_fill_values(keys), ...)
}
