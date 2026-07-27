# M\u00f3dulo Shiny: \u00cdndice de Valor de Importancia Ecol\u00f3gica (IVI 300% / 200% con ggplot2)
mod_ivi_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "card p-3 mb-4 shadow-sm border-0 bg-light d-flex justify-content-between align-items-center flex-row",
      shiny::div(
        shiny::h4(class = "text-success font-weight-bold mb-0", shiny::icon("chart-pie"), " \u00cdndice de Valor de Importancia Ecol\u00f3gica (IVI)"),
        shiny::p(class = "text-muted small mb-0", "C\u00e1lculo del IVI (Abundancia Rel. + Dominancia Rel. + Frecuencia Rel.) y ranking top de especies.")
      ),
      shiny::div(
        class = "d-flex align-items-center gap-2",
        shiny::actionButton(ns("btn_ver_codigo"), "Ver C\u00f3digo R", icon = shiny::icon("code"), class = "btn-outline-success btn-sm font-weight-bold me-2"),
        shiny::checkboxInput(ns("usar_modo_independiente"), "Modo Independiente", value = FALSE)
      )
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-primary text-white mb-3", shiny::icon("table"), " 1. \u00cdndice de Valor de Importancia (IVI)"),
      DT::DTOutput(ns("tabla_ivi"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-success text-white mb-3", shiny::icon("chart-bar"), " 2. Especies Ecol\u00f3gicamente M\u00e1s Importantes (Top 10 IVI)"),
      plotly::plotlyOutput(ns("plot_ivi"), height = "450px")
    )
  )
}

mod_ivi_server <- function(id, datos_reactive = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    datos_modulo <- shiny::reactive({
      if (isTRUE(input$usar_modo_independiente) || is.null(datos_reactive)) {
        set.seed(42)
        sitios <- paste0("Parcela_", rep(1:4, each = 15))
        especies <- c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra",
                      "Guarea guidonia", "Inga edulis", "Dipteryx micrantha", "Protium puncticulatum")
        data.frame(
          sitio = sitios,
          especie = sample(especies, 60, replace = TRUE),
          abundancia = sample(1:15, 60, replace = TRUE),
          dap_cm = round(stats::runif(60, 10, 90), 1),
          stringsAsFactors = FALSE
        )
      } else {
        shiny::req(datos_reactive())
        standardize_inventory(datos_reactive())
      }
    })

    df_ivi <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)

      res <- calc_ivi(df)
      res$abundancia_rel_pct <- round(res$abundancia_rel_pct, 2)
      res$area_basal_m2 <- round(res$area_basal_m2, 4)
      res$dominancia_rel_pct <- round(res$dominancia_rel_pct, 2)
      res$frecuencia_rel_pct <- round(res$frecuencia_rel_pct, 2)
      res$ivi <- round(res$ivi, 2)

      names(res) <- c("Especie", "N_Ind", "Abundancia_Rel_pct", "Area_Basal_m2", "Dominancia_Rel_pct", "Frecuencia_Rel_pct", "IVI")
      res
    })

    output$tabla_ivi <- DT::renderDT({
      df_i <- df_ivi()
      shiny::req(df_i)
      df_show <- df_i
      names(df_show) <- c("Especie", "N\u00b0 Ind.", "Abundancia Rel. (%)", "\u00c1rea Basal (m\u00b2)", "Dominancia Rel. (%)", "Frecuencia Rel. (%)", "IVI")
      DT::datatable(df_show, options = list(pageLength = 10, scrollX = TRUE), style = "bootstrap4")
    })

    output$plot_ivi <- plotly::renderPlotly({
      df_i <- df_ivi()
      shiny::req(df_i)

      top10 <- utils::head(df_i, 10)
      top10$Especie <- factor(top10$Especie, levels = rev(top10$Especie))

      df_long <- data.frame(
        Especie = rep(top10$Especie, 3),
        Componente = factor(rep(c("Abundancia Rel. (%)", "Dominancia Rel. (%)", "Frecuencia Rel. (%)"), each = nrow(top10)),
                            levels = c("Frecuencia Rel. (%)", "Dominancia Rel. (%)", "Abundancia Rel. (%)")),
        Valor = c(top10$Abundancia_Rel_pct, top10$Dominancia_Rel_pct, top10$Frecuencia_Rel_pct)
      )

      p <- ggplot2::ggplot(df_long, ggplot2::aes(x = Especie, y = Valor, fill = Componente)) +
        ggplot2::geom_col(position = "stack", alpha = 0.9) +
        ggplot2::coord_flip() +
        ggplot2::scale_fill_manual(values = c(
          "Abundancia Rel. (%)" = "#40916c",
          "Dominancia Rel. (%)" = "#1b4d3e",
          "Frecuencia Rel. (%)" = "#95d5b2"
        )) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "Componentes del IVI para las Top 10 Especies",
          x = "Especie",
          y = "Valor Porcentual Acumulado (%)",
          fill = "Componente IVI"
        )

      plotly::ggplotly(p)
    })

    codigo_r_text <- shiny::reactive({
      paste0(
        "library(floraveg)\n",
        "library(ggplot2)\n\n",
        "# 1. Calculo del Indice de Valor de Importancia Ecologica (IVI)\n",
        "tabla_ivi <- calc_ivi(datos)\n",
        "top10 <- head(tabla_ivi, 10)\n\n",
        "# 2. Grafico apilado de IVI con ggplot2\n",
        "df_long <- data.frame(\n",
        "  Especie = rep(top10$especie, 3),\n",
        "  Componente = rep(c('Abundancia Rel. (%)', 'Dominancia Rel. (%)', 'Frecuencia Rel. (%)'), each = nrow(top10)),\n",
        "  Valor = c(top10$abundancia_rel_pct, top10$dominancia_rel_pct, top10$frecuencia_rel_pct)\n",
        ")\n",
        "ggplot(df_long, aes(x = reorder(Especie, Valor), y = Valor, fill = Componente)) +\n",
        "  geom_col(position = 'stack') +\n",
        "  coord_flip() +\n",
        "  scale_fill_manual(values = c('Abundancia Rel. (%)' = '#40916c', 'Dominancia Rel. (%)' = '#1b4d3e', 'Frecuencia Rel. (%)' = '#95d5b2')) +\n",
        "  theme_minimal() +\n",
        "  labs(title = 'Top 10 Especies IVI', x = 'Especie', y = 'Porcentaje (%)')\n"
      )
    })

    shiny::observeEvent(input$btn_ver_codigo, {
      shiny::showModal(shiny::modalDialog(
        title = shiny::tags$div(shiny::icon("code"), " C\u00f3digo R - IVI"),
        size = "l",
        easyClose = TRUE,
        footer = shiny::tagList(
          shiny::actionButton(
            ns("btn_copiar"),
            "Copiar al Portapapeles",
            icon = shiny::icon("copy"),
            class = "btn-success",
            onclick = sprintf("copyCodeToClipboard('%s')", ns("modal_code_ivi"))
          ),
          shiny::modalButton("Cerrar")
        ),
        shiny::tags$p("Sintaxis R en ggplot2 lista para ejecutar en RStudio:"),
        shiny::tags$pre(
          id = ns("modal_code_ivi"),
          style = "background-color: #1e293b; color: #38bdf8; padding: 1rem; border-radius: 8px; max-height: 400px; overflow-y: auto;",
          codigo_r_text()
        )
      ))
    })

  })
}
