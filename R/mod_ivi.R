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
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3",
        shiny::h4(class = "card-header bg-primary text-white mb-0 flex-grow-1 me-2", shiny::icon("table"), " 1. \u00cdndice de Valor de Importancia (IVI)"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_ivi_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_ivi_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      DT::DTOutput(ns("tabla_ivi"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-success text-white mb-3", shiny::icon("chart-bar"), " 2. Especies Ecol\u00f3gicamente M\u00e1s Importantes (Top 10 IVI)"),
      plotly::plotlyOutput(ns("plot_ivi"), height = "450px")
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3",
        shiny::h4(class = "card-header bg-primary text-white mb-0 flex-grow-1 me-2", shiny::icon("ranking-star"), " 3. Ranking por Componentes de Dominancia"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_componentes_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_componentes_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      DT::DTOutput(ns("tabla_componentes_ivi"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3",
        shiny::h4(class = "card-header bg-dark text-white mb-0 flex-grow-1 me-2", shiny::icon("filter"), " 4. Especies Raras por Baja Abundancia y Frecuencia"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_raras_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_raras_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      shiny::uiOutput(ns("resumen_rareza_ivi")),
      DT::DTOutput(ns("tabla_raras_ivi"))
    )
  )
}

mod_ivi_server <- function(id, datos_reactive = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    datos_modulo <- shiny::reactive({
      if (isTRUE(input$usar_modo_independiente) || is.null(datos_reactive)) {
        obtener_datos_ejemplo()
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
      has_dap <- "dap_cm" %in% names(df)
      if (has_dap) {
        res$ivi <- round(res$ivi, 2)
        res$tipo_ivi <- "IVI 300% (Abundancia + Dominancia + Frecuencia)"
      } else {
        res$dominancia_rel_pct <- NA_real_
        res$area_basal_m2 <- NA_real_
        res$ivi <- round(res$abundancia_rel_pct + res$frecuencia_rel_pct, 2)
        res$tipo_ivi <- "IVI 200% simplificado (Abundancia + Frecuencia)"
      }

      names(res) <- c("Especie", "N_Ind", "Abundancia_Rel_pct", "Area_Basal_m2", "Dominancia_Rel_pct", "Frecuencia_Rel_pct", "IVI", "Tipo_IVI")
      res
    })

    output$tabla_ivi <- DT::renderDT({
      df_i <- df_ivi()
      shiny::req(df_i)
      df_show <- df_i
      names(df_show) <- c("Especie", "N\u00b0 Ind.", "Abundancia Rel. (%)", "\u00c1rea Basal (m\u00b2)", "Dominancia Rel. (%)", "Frecuencia Rel. (%)", "IVI", "Tipo IVI")
      DT::datatable(df_show, options = list(pageLength = 10, scrollX = TRUE), style = "bootstrap4")
    })

    output$plot_ivi <- plotly::renderPlotly({
      df_i <- df_ivi()
      shiny::req(df_i)

      top10 <- utils::head(df_i, 10)
      top10$Especie <- factor(top10$Especie, levels = rev(top10$Especie))

      if (all(is.na(top10$Dominancia_Rel_pct))) {
        df_long <- data.frame(
          Especie = rep(top10$Especie, 2),
          Componente = factor(rep(c("Abundancia Rel. (%)", "Frecuencia Rel. (%)"), each = nrow(top10)),
                              levels = c("Frecuencia Rel. (%)", "Abundancia Rel. (%)")),
          Valor = c(top10$Abundancia_Rel_pct, top10$Frecuencia_Rel_pct)
        )
      } else {
        df_long <- data.frame(
          Especie = rep(top10$Especie, 3),
          Componente = factor(rep(c("Abundancia Rel. (%)", "Dominancia Rel. (%)", "Frecuencia Rel. (%)"), each = nrow(top10)),
                              levels = c("Frecuencia Rel. (%)", "Dominancia Rel. (%)", "Abundancia Rel. (%)")),
          Valor = c(top10$Abundancia_Rel_pct, top10$Dominancia_Rel_pct, top10$Frecuencia_Rel_pct)
        )
      }

      p <- ggplot2::ggplot(df_long, ggplot2::aes(x = Especie, y = Valor, fill = Componente)) +
        ggplot2::geom_col(position = "stack", alpha = 0.9) +
        ggplot2::coord_flip() +
        fv_scale_fill(levels(df_long$Componente)) +
        fv_chart_theme() +
        ggplot2::labs(
          title = "Componentes del IVI para las Top 10 Especies",
          x = "Especie",
          y = "Valor Porcentual Acumulado (%)",
          fill = "Componente IVI"
        )

      plotly::ggplotly(p)
    })

    componentes_ivi <- shiny::reactive({
      df_i <- df_ivi()
      shiny::req(df_i)
      data.frame(
        Componente = c("Abundancia Relativa", "Dominancia Relativa", "Frecuencia Relativa", "IVI Total"),
        Especie_Lider = c(
          df_i$Especie[which.max(df_i$Abundancia_Rel_pct)],
          if (all(is.na(df_i$Dominancia_Rel_pct))) "No aplica sin DAP" else df_i$Especie[which.max(df_i$Dominancia_Rel_pct)],
          df_i$Especie[which.max(df_i$Frecuencia_Rel_pct)],
          df_i$Especie[which.max(df_i$IVI)]
        ),
        Valor = round(c(
          max(df_i$Abundancia_Rel_pct, na.rm = TRUE),
          if (all(is.na(df_i$Dominancia_Rel_pct))) NA_real_ else max(df_i$Dominancia_Rel_pct, na.rm = TRUE),
          max(df_i$Frecuencia_Rel_pct, na.rm = TRUE),
          max(df_i$IVI, na.rm = TRUE)
        ), 2),
        stringsAsFactors = FALSE
      )
    })

    output$tabla_componentes_ivi <- DT::renderDT({
      DT::datatable(componentes_ivi(), options = list(dom = 't', scrollX = TRUE), rownames = FALSE, style = "bootstrap4")
    })

    especies_raras <- shiny::reactive({
      df_i <- df_ivi()
      shiny::req(df_i)
      q_ab <- stats::quantile(df_i$Abundancia_Rel_pct, probs = 0.25, na.rm = TRUE)
      q_fr <- stats::quantile(df_i$Frecuencia_Rel_pct, probs = 0.25, na.rm = TRUE)
      rare <- df_i[df_i$Abundancia_Rel_pct <= q_ab & df_i$Frecuencia_Rel_pct <= q_fr, ]
      rare <- rare[order(rare$Abundancia_Rel_pct, rare$Frecuencia_Rel_pct), ]
      rare[, c("Especie", "N_Ind", "Abundancia_Rel_pct", "Frecuencia_Rel_pct", "IVI", "Tipo_IVI")]
    })

    output$resumen_rareza_ivi <- shiny::renderUI({
      rare <- especies_raras()
      shiny::div(
        class = "alert alert-info py-2 px-3",
        shiny::icon("circle-info"), " ",
        shiny::strong(nrow(rare)), " especies cumplen el criterio de rareza operacional: abundancia relativa y frecuencia relativa en el cuartil inferior del inventario activo."
      )
    })

    output$tabla_raras_ivi <- DT::renderDT({
      DT::datatable(especies_raras(), options = list(pageLength = 8, scrollX = TRUE), rownames = FALSE, style = "bootstrap4")
    })

    # Descarga IVI CSV
    output$dl_ivi_csv <- shiny::downloadHandler(
      filename = function() { paste0("tabla_ivi_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(df_ivi(), file, row.names = FALSE) }
    )

    # Descarga IVI Excel
    output$dl_ivi_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("tabla_ivi_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(df_ivi(), file)
        } else {
          utils::write.csv(df_ivi(), file, row.names = FALSE)
        }
      }
    )

    # Descarga Componentes CSV
    output$dl_componentes_csv <- shiny::downloadHandler(
      filename = function() { paste0("componentes_lideres_ivi_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(componentes_ivi(), file, row.names = FALSE) }
    )

    # Descarga Componentes Excel
    output$dl_componentes_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("componentes_lideres_ivi_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(componentes_ivi(), file)
        } else {
          utils::write.csv(componentes_ivi(), file, row.names = FALSE)
        }
      }
    )

    # Descarga Especies Raras CSV
    output$dl_raras_csv <- shiny::downloadHandler(
      filename = function() { paste0("especies_raras_ivi_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(especies_raras(), file, row.names = FALSE) }
    )

    # Descarga Especies Raras Excel
    output$dl_raras_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("especies_raras_ivi_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(especies_raras(), file)
        } else {
          utils::write.csv(especies_raras(), file, row.names = FALSE)
        }
      }
    )

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
        "  scale_fill_manual(values = c('Abundancia Rel. (%)' = '#2f7d5c', 'Dominancia Rel. (%)' = '#d98e2f', 'Frecuencia Rel. (%)' = '#3a86c8')) +\n",
        "  theme_minimal(base_size = 12) +\n",
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
          class = "code-block-scroll",
          codigo_r_text()
        )
      ))
    })

  })
}
