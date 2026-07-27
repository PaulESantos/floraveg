# M\u00f3dulo Shiny: Estructura de la Vegetaci\u00f3n y Distribuci\u00f3n Diam\u00e9trica (Dise\u00f1o Vertical + ggplot2)
mod_estructura_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "card p-3 mb-4 shadow-sm border-0 bg-light d-flex justify-content-between align-items-center flex-row",
      shiny::div(
        shiny::h4(class = "text-success font-weight-bold mb-0", shiny::icon("tree"), " Estructura Vegetacional & Distribuci\u00f3n Diam\u00e9trica"),
        shiny::p(class = "text-muted small mb-0", "C\u00e1lculo de abundancia, frecuencia absoluta/relativa y curvas de estructura diam\u00e9trica (J-Invertida).")
      ),
      shiny::div(
        class = "d-flex align-items-center gap-2",
        shiny::actionButton(ns("btn_ver_codigo"), "Ver C\u00f3digo R", icon = shiny::icon("code"), class = "btn-outline-success btn-sm font-weight-bold me-2"),
        shiny::checkboxInput(ns("usar_modo_independiente"), "Modo Independiente", value = FALSE)
      )
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-primary text-white mb-3", shiny::icon("table"), " 1. Abundancia y Frecuencia por Especie"),
      DT::DTOutput(ns("tabla_estructura"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-success text-white mb-3", shiny::icon("chart-bar"), " 2. Distribuci\u00f3n Diam\u00e9trica (J-Invertida)"),
      shiny::div(
        class = "mb-3",
        style = "max-width: 300px;",
        shiny::numericInput(ns("ancho_clase"), "Ancho de clase DAP (cm):", value = 10, min = 1, max = 50)
      ),
      plotly::plotlyOutput(ns("plot_diametrica"), height = "450px")
    )
  )
}

mod_estructura_server <- function(id, datos_reactive = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    datos_modulo <- shiny::reactive({
      if (isTRUE(input$usar_modo_independiente) || is.null(datos_reactive)) {
        set.seed(42)
        especies <- c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra",
                      "Guarea guidonia", "Inga edulis", "Dipteryx micrantha")
        sitios <- paste0("Parcela_", rep(1:4, each = 15))
        data.frame(
          sitio = sitios,
          especie = sample(especies, 60, replace = TRUE),
          abundancia = sample(1:15, 60, replace = TRUE),
          dap_cm = round(stats::runif(60, 8, 85), 1),
          stringsAsFactors = FALSE
        )
      } else {
        shiny::req(datos_reactive())
        standardize_inventory(datos_reactive())
      }
    })

    df_est <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)

      ab <- abundancia(df, tipo = "ambas")
      freq <- frecuencia(df)

      res <- merge(ab, freq[, c("especie", "frecuencia_absoluta", "frecuencia_relativa_pct")], by = "especie", all = TRUE)
      res$abundancia_relativa_pct <- round(res$abundancia_relativa_pct, 2)
      res$frecuencia_relativa_pct <- round(res$frecuencia_relativa_pct, 2)

      res <- res[order(-res$n_individuos), ]
      names(res) <- c("Especie", "N\u00b0 Ind. (Abundancia)", "Abundancia Rel. (%)", "Frec. Abs. (Sitios)", "Frecuencia Rel. (%)")
      res
    })

    output$tabla_estructura <- DT::renderDT({
      DT::datatable(df_est(), options = list(pageLength = 8, scrollX = TRUE), style = "bootstrap4")
    })

    output$plot_diametrica <- plotly::renderPlotly({
      df <- datos_modulo()
      shiny::req(df, "dap_cm" %in% names(df))

      ancho <- input$ancho_clase
      dd <- distribucion_diametrica(df$dap_cm, ancho_clase = ancho)
      df_clases <- dd$tabla_clases

      p <- ggplot2::ggplot(df_clases, ggplot2::aes(x = Clase, y = frecuencia)) +
        ggplot2::geom_col(fill = "#2d6a4f", color = "#1b4d3e", alpha = 0.85) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = paste0("Distribuci\u00f3n Diam\u00e9trica (Clases de ", ancho, " cm)"),
          x = "Clases Diam\u00e9tricas de DAP (cm)",
          y = "N\u00famero de Individuos"
        ) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

      plotly::ggplotly(p)
    })

    codigo_r_text <- shiny::reactive({
      ancho <- ifelse(is.null(input$ancho_clase), 10, input$ancho_clase)
      paste0(
        "library(floraveg)\n",
        "library(ggplot2)\n\n",
        "# 1. Abundancia y Frecuencia por especie\n",
        "ab <- abundancia(datos, tipo = 'ambas')\n",
        "freq <- frecuencia(datos)\n\n",
        "# 2. Distribucion diametrica con ggplot2\n",
        "dd <- distribucion_diametrica(datos$dap_cm, ancho_clase = ", ancho, ")\n",
        "df_clases <- dd$tabla_clases\n\n",
        "ggplot(df_clases, aes(x = Clase, y = frecuencia)) +\n",
        "  geom_col(fill = '#2d6a4f', color = '#1b4d3e') +\n",
        "  theme_minimal() +\n",
        "  labs(title = 'Distribucion Diametrica (J-Invertida)', x = 'Clase DAP (cm)', y = 'Individuos')\n"
      )
    })

    shiny::observeEvent(input$btn_ver_codigo, {
      shiny::showModal(shiny::modalDialog(
        title = shiny::tags$div(shiny::icon("code"), " C\u00f3digo R (ggplot2) - Estructura Vegetacional"),
        size = "l",
        easyClose = TRUE,
        footer = shiny::tagList(
          shiny::actionButton(
            ns("btn_copiar"),
            "Copiar al Portapapeles",
            icon = shiny::icon("copy"),
            class = "btn-success",
            onclick = sprintf("copyCodeToClipboard('%s')", ns("modal_code_est"))
          ),
          shiny::modalButton("Cerrar")
        ),
        shiny::tags$p("Sintaxis R en ggplot2 lista para ejecutar en RStudio:"),
        shiny::tags$pre(
          id = ns("modal_code_est"),
          style = "background-color: #1e293b; color: #38bdf8; padding: 1rem; border-radius: 8px; max-height: 400px; overflow-y: auto;",
          codigo_r_text()
        )
      ))
    })

  })
}
