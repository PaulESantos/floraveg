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
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3",
        shiny::h4(class = "card-header bg-primary text-white mb-0 flex-grow-1 me-2", shiny::icon("table"), " 1. Abundancia y Frecuencia por Especie"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_est_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_est_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
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
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3",
        shiny::h4(class = "card-header bg-primary text-white mb-0 flex-grow-1 me-2", shiny::icon("ruler-combined"), " 3. Densidad Poblacional por Hectarea"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_dens_sitio_csv"), "Dens. Sitio (CSV)", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_dens_sitio_xlsx"), "Dens. Sitio (Excel)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel")),
          shiny::downloadButton(ns("dl_dens_sp_csv"), "Dens. Especie (CSV)", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_dens_sp_xlsx"), "Dens. Especie (Excel)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      shiny::fluidRow(
        shiny::column(width = 4, shiny::numericInput(ns("area_ha"), "Area total o de parcela (ha):", value = 1, min = 0.001, step = 0.1)),
        shiny::column(width = 8, shiny::uiOutput(ns("resumen_densidad_poblacional")))
      ),
      DT::DTOutput(ns("tabla_densidad_sitio")),
      shiny::hr(),
      DT::DTOutput(ns("tabla_densidad_especie"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3",
        shiny::h4(class = "card-header bg-success text-white mb-0 flex-grow-1 me-2", shiny::icon("circle-nodes"), " 4. Cobertura Vegetal"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_cob_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_cob_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      DT::DTOutput(ns("tabla_cobertura_sitio")),
      shiny::hr(),
      plotly::plotlyOutput(ns("plot_cobertura_abundancia"), height = "380px")
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3",
        shiny::h4(class = "card-header bg-dark text-white mb-0 flex-grow-1 me-2", shiny::icon("seedling"), " 5. Regeneracion Natural"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_regen_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_regen_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      DT::DTOutput(ns("tabla_regeneracion")),
      shiny::hr(),
      plotly::plotlyOutput(ns("plot_regeneracion"), height = "380px")
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
          altura_m = round(stats::runif(60, 3, 28), 1),
          dc_m = round(stats::runif(60, 1.5, 9), 1),
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
      shiny::req(df)
      shiny::validate(shiny::need(
        "dap_cm" %in% names(df),
        "Se requiere una columna DAP mapeada como 'dap_cm' para construir la distribucion diametrica."
      ))

      ancho <- input$ancho_clase
      dd <- distribucion_diametrica(df$dap_cm, ancho_clase = ancho)
      df_clases <- dd$tabla_clases

      p <- ggplot2::ggplot(df_clases, ggplot2::aes(x = Clase, y = frecuencia)) +
        ggplot2::geom_col(fill = fv_pal[["suelo"]], color = fv_pal[["marca"]], alpha = 0.85) +
        fv_chart_theme() +
        ggplot2::labs(
          title = paste0("Distribuci\u00f3n Diam\u00e9trica (Clases de ", ancho, " cm)"),
          x = "Clases Diam\u00e9tricas de DAP (cm)",
          y = "N\u00famero de Individuos"
        ) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

      plotly::ggplotly(p)
    })

    densidad_sitio <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      area <- ifelse(is.null(input$area_ha), 1, input$area_ha)
      shiny::req(area > 0)

      agg <- stats::aggregate(df$abundancia, by = list(Sitio = df$sitio), FUN = sum, na.rm = TRUE)
      names(agg)[2] <- "N_individuos"
      agg$Area_ha <- area
      agg$Individuos_ha <- round(densidad_poblacional(agg$N_individuos, area_ha = area), 2)
      agg[order(-agg$Individuos_ha), ]
    })

    densidad_especie <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      area <- ifelse(is.null(input$area_ha), 1, input$area_ha)
      shiny::req(area > 0)

      agg <- stats::aggregate(df$abundancia, by = list(Especie = df$especie), FUN = sum, na.rm = TRUE)
      names(agg)[2] <- "N_individuos"
      agg$Area_ha <- area
      agg$Individuos_ha <- round(densidad_poblacional(agg$N_individuos, area_ha = area), 2)
      agg[order(-agg$Individuos_ha), ]
    })

    output$resumen_densidad_poblacional <- shiny::renderUI({
      df <- datos_modulo()
      shiny::req(df)
      area <- ifelse(is.null(input$area_ha), 1, input$area_ha)
      total_ind <- sum(df$abundancia, na.rm = TRUE)
      dens_total <- round(densidad_poblacional(total_ind, area_ha = area), 2)

      shiny::div(
        class = "d-flex gap-3 flex-wrap",
        shiny::div(class = "metric-card p-3 rounded bg-light border", shiny::div(class = "metric-value", total_ind), shiny::div(class = "metric-label", "Individuos Totales")),
        shiny::div(class = "metric-card p-3 rounded bg-light border", shiny::div(class = "metric-value", dens_total), shiny::div(class = "metric-label", "Individuos/ha Total"))
      )
    })

    output$tabla_densidad_sitio <- DT::renderDT({
      DT::datatable(densidad_sitio(), options = list(pageLength = 6, scrollX = TRUE), rownames = FALSE, style = "bootstrap4")
    })

    output$tabla_densidad_especie <- DT::renderDT({
      DT::datatable(densidad_especie(), options = list(pageLength = 8, scrollX = TRUE), rownames = FALSE, style = "bootstrap4")
    })

    cobertura_resumen <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      shiny::validate(shiny::need(
        "dc_m" %in% names(df),
        "Se requiere una columna de diametro de copa mapeada como 'dc_m' para calcular cobertura vegetal."
      ))
      area <- ifelse(is.null(input$area_ha), 1, input$area_ha)
      area_m2 <- area * 10000

      df$area_copa_m2 <- cobertura(dc_m = df$dc_m, area_parcela_m2 = area_m2)$area_copa_m2
      sitio <- stats::aggregate(
        cbind(area_copa_m2, abundancia) ~ sitio,
        data = df,
        FUN = sum,
        na.rm = TRUE
      )
      sitio$cobertura_relativa_pct <- round((sitio$area_copa_m2 / area_m2) * 100, 2)
      names(sitio) <- c("Sitio", "Area_Copa_m2", "Abundancia_Total", "Cobertura_Relativa_pct")

      especie <- stats::aggregate(
        cbind(area_copa_m2, abundancia) ~ especie,
        data = df,
        FUN = sum,
        na.rm = TRUE
      )
      especie$cobertura_relativa_pct <- round((especie$area_copa_m2 / area_m2) * 100, 2)
      names(especie) <- c("Especie", "Area_Copa_m2", "Abundancia_Total", "Cobertura_Relativa_pct")

      list(sitio = sitio[order(-sitio$Cobertura_Relativa_pct), ], especie = especie)
    })

    output$tabla_cobertura_sitio <- DT::renderDT({
      cov <- cobertura_resumen()
      DT::datatable(cov$sitio, options = list(pageLength = 6, scrollX = TRUE), rownames = FALSE, style = "bootstrap4")
    })

    output$plot_cobertura_abundancia <- plotly::renderPlotly({
      cov <- cobertura_resumen()
      df_cov <- cov$especie
      shiny::req(df_cov)
      p <- ggplot2::ggplot(df_cov, ggplot2::aes(x = Abundancia_Total, y = Cobertura_Relativa_pct, text = Especie)) +
        ggplot2::geom_point(color = fv_pal[["agua"]], size = 3, alpha = 0.8) +
        fv_chart_theme() +
        ggplot2::labs(
          title = "Comparacion cobertura vs abundancia por especie",
          x = "Abundancia total",
          y = "Cobertura relativa (%)"
        )
      plotly::ggplotly(p, tooltip = c("text", "x", "y"))
    })

    regeneracion_resumen <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      shiny::validate(shiny::need(
        "dap_cm" %in% names(df),
        "Se requiere DAP mapeado como 'dap_cm' para clasificar regeneracion natural."
      ))
      df$Estadio <- regeneracion_natural(df$dap_cm, altura_m = if ("altura_m" %in% names(df)) df$altura_m else NULL)
      tab <- as.data.frame(stats::xtabs(abundancia ~ sitio + Estadio, data = df))
      names(tab) <- c("Sitio", "Estadio", "N_individuos")
      total_sitio <- stats::aggregate(N_individuos ~ Sitio, data = tab, FUN = sum)
      tab <- merge(tab, total_sitio, by = "Sitio", suffixes = c("", "_sitio"))
      tab$Proporcion_pct <- round((tab$N_individuos / tab$N_individuos_sitio) * 100, 2)
      tab[, c("Sitio", "Estadio", "N_individuos", "Proporcion_pct")]
    })

    output$tabla_regeneracion <- DT::renderDT({
      DT::datatable(regeneracion_resumen(), options = list(pageLength = 8, scrollX = TRUE), rownames = FALSE, style = "bootstrap4")
    })

    output$plot_regeneracion <- plotly::renderPlotly({
      df_r <- regeneracion_resumen()
      shiny::req(df_r)
      p <- ggplot2::ggplot(df_r, ggplot2::aes(x = Sitio, y = Proporcion_pct, fill = Estadio)) +
        ggplot2::geom_col(position = "stack", alpha = 0.9) +
        fv_scale_fill(c("Brinzal", "Latizal", "Fustal")) +
        fv_chart_theme() +
        ggplot2::labs(
          title = "Estructura de regeneracion natural por sitio",
          x = "Sitio / Parcela",
          y = "Proporcion (%)",
          fill = "Estadio"
        ) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
      plotly::ggplotly(p)
    })

    # Descargas Estructura
    output$dl_est_csv <- shiny::downloadHandler(
      filename = function() { paste0("abundancia_frecuencia_especies_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(df_est(), file, row.names = FALSE) }
    )

    output$dl_est_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("abundancia_frecuencia_especies_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(df_est(), file)
        } else {
          utils::write.csv(df_est(), file, row.names = FALSE)
        }
      }
    )

    # Descargas Densidad
    output$dl_dens_sitio_csv <- shiny::downloadHandler(
      filename = function() { paste0("densidad_poblacional_sitio_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(densidad_sitio(), file, row.names = FALSE) }
    )

    output$dl_dens_sitio_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("densidad_poblacional_sitio_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(densidad_sitio(), file)
        } else {
          utils::write.csv(densidad_sitio(), file, row.names = FALSE)
        }
      }
    )

    output$dl_dens_sp_csv <- shiny::downloadHandler(
      filename = function() { paste0("densidad_poblacional_especie_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(densidad_especie(), file, row.names = FALSE) }
    )

    output$dl_dens_sp_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("densidad_poblacional_especie_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(densidad_especie(), file)
        } else {
          utils::write.csv(densidad_especie(), file, row.names = FALSE)
        }
      }
    )

    # Descargas Cobertura
    output$dl_cob_csv <- shiny::downloadHandler(
      filename = function() { paste0("cobertura_vegetal_sitio_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(cobertura_resumen()$sitio, file, row.names = FALSE) }
    )

    output$dl_cob_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("cobertura_vegetal_sitio_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(cobertura_resumen()$sitio, file)
        } else {
          utils::write.csv(cobertura_resumen()$sitio, file, row.names = FALSE)
        }
      }
    )

    # Descargas Regeneracion
    output$dl_regen_csv <- shiny::downloadHandler(
      filename = function() { paste0("regeneracion_natural_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(regeneracion_resumen(), file, row.names = FALSE) }
    )

    output$dl_regen_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("regeneracion_natural_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(regeneracion_resumen(), file)
        } else {
          utils::write.csv(regeneracion_resumen(), file, row.names = FALSE)
        }
      }
    )

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
        "  geom_col(fill = '#b08968', color = '#1b4d3e') +\n",
        "  theme_minimal(base_size = 12) +\n",
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
          class = "code-block-scroll",
          codigo_r_text()
        )
      ))
    })

  })
}
