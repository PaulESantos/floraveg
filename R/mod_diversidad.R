# M\u00f3dulo Shiny: Diversidad Alfa, Beta y Curvas de Acumulaci\u00f3n (Dise\u00f1o Vertical + ggplot2)
mod_diversidad_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "card p-3 mb-4 shadow-sm border-0 bg-light d-flex justify-content-between align-items-center flex-row",
      shiny::div(
        shiny::h4(class = "text-success font-weight-bold mb-0", shiny::icon("leaf"), " An\u00e1lisis de Diversidad Flor\u00edstica Alfa y Beta"),
        shiny::p(class = "text-muted small mb-0", "\u00cdndices alfa completos (Riqueza, Shannon, Pielou, Gini-Simpson, Simpson Inv., Margalef, Menhinick, McIntosh), similitud beta (Jaccard/S\u00f8rensen/Morisita-Horn), dendrogramas y acumulaciones.")
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
        class = "d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2",
        shiny::h4(class = "text-primary font-weight-bold mb-0", shiny::icon("table"), " 1. \u00cdndices de Diversidad Alfa por Parcela (Completo)"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_alfa_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_alfa_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      shiny::p(class = "text-muted small", "Indicadores de riqueza, equidad y dominancia (speciesdiv): Riqueza (S), Shannon (H' log2), Pielou (J'), Gini-Simpson, Simpson Inverso, Margalef, Menhinick y McIntosh."),
      DT::DTOutput(ns("tabla_alfa"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-success text-white mb-3", shiny::icon("grip"), " 2. An\u00e1lisis y Visualizaci\u00f3n de Diversidad Beta"),
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shiny::selectInput(
            ns("metodo_beta"),
            "\u00cdndice de Similitud Beta:",
            choices = c(
              "Jaccard (Cualitativo - Presencia/Ausencia)" = "jaccard",
              "S\u00f8rensen (Cualitativo - Presencia/Ausencia)" = "sorensen",
              "Morisita-Horn (Cuantitativo - Abundancia)" = "morisita-horn"
            ),
            selected = "jaccard"
          )
        ),
        shiny::column(
          width = 6,
          shiny::radioButtons(
            ns("tipo_vis_beta"),
            "Instrumento de Visualizaci\u00f3n Beta:",
            choices = c(
              "Heatmap Interactivo de Similitud" = "heatmap",
              "Dendrograma de Agrupamiento Jer\u00e1rquico (UPGMA)" = "dendrograma"
            ),
            selected = "heatmap",
            inline = TRUE
          )
        )
      ),
      shiny::uiOutput(ns("nota_tecnica_beta_info")),
      plotly::plotlyOutput(ns("plot_beta"), height = "420px"),
      shiny::hr(),
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2",
        shiny::radioButtons(
          ns("formato_tabla_beta"),
          "Presentaci\u00f3n de Resultados Beta:",
          choices = c(
            "Objeto Tidy (Tabla de Pares Sitio 1 vs Sitio 2)" = "tidy",
            "Matriz Num\u00e9rica Tradicional" = "matrix"
          ),
          selected = "tidy",
          inline = TRUE
        ),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_beta_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_beta_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      DT::DTOutput(ns("tabla_beta"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-dark text-white mb-3", shiny::icon("chart-line"), " 3. Curva Especie-\u00c1rea & Estimadores de Riqueza"),
      plotly::plotlyOutput(ns("plot_acumulacion"), height = "400px"),
      shiny::hr(),
      shiny::uiOutput(ns("resumen_representatividad")),
      shiny::hr(),
      shiny::h5(class = "font-weight-bold text-secondary mb-2", "Estimadores de Riqueza Esperada (Chao1, Jackknife, Bootstrap):"),
      shiny::tableOutput(ns("tabla_estimadores"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-warning text-dark mb-3", shiny::icon("chart-area"), " 4. Rarefacci\u00f3n y Extrapolaci\u00f3n de la Diversidad (iNEXT - Chao et al.)"),
      shiny::p(class = "text-muted small", "Curvas de rarefacci\u00f3n (interpolaci\u00f3n) y extrapolaci\u00f3n de la riqueza/diversidad basadas en n\u00fameros de Hill (q=0 Riqueza, q=1 Shannon, q=2 Simpson) seg\u00fan Chao et al. (iNEXT)."),
      shiny::fluidRow(
        shiny::column(
          width = 4,
          shiny::selectInput(
            ns("inext_orden_q"),
            "Orden de Diversidad (Hill q):",
            choices = c(
              "q = 0 (Riqueza de Especies S)" = 0,
              "q = 1 (Diversidad de Shannon exp(H'))" = 1,
              "q = 2 (Diversidad de Simpson 1/D)" = 2
            ),
            selected = 0
          )
        ),
        shiny::column(
          width = 4,
          shiny::selectInput(
            ns("inext_tipo_curva"),
            "Tipo de Curva iNEXT:",
            choices = c(
              "1. Basada en Tama\u00f1o de Muestra (N\u00b0 Individuos)" = 1,
              "2. Completitud de Muestra (Cobertura vs N)" = 2,
              "3. Basada en Cobertura de Muestra (Cobertura vs Riqueza)" = 3
            ),
            selected = 1
          )
        ),
        shiny::column(
          width = 4,
          shiny::numericInput(ns("inext_nboot"), "Replicaciones Bootstrap:", value = 10, min = 0, max = 100, step = 5)
        )
      ),
      plotly::plotlyOutput(ns("plot_inext"), height = "450px"),
      shiny::hr(),
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2",
        shiny::h5(class = "font-weight-bold text-dark mb-0", shiny::icon("table"), " Resumen de Estimaciones Asint\u00f3ticas y Cobertura (iNEXT):"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_inext_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_inext_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      DT::DTOutput(ns("tabla_inext"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-dark text-white mb-3", shiny::icon("chart-line"), " 5. Curvas de Dominancia-Abundancia (Whittaker Rank-Abundance)"),
      shiny::fluidRow(
        shiny::column(
          width = 4,
          shiny::selectInput(
            ns("whittaker_scale"),
            "Escala Eje Y (Abundancia):",
            choices = c(
              "Log10 Abundancia" = "logabun",
              "Abundancia Absoluta (N\u00b0 Ind)" = "abundance",
              "Proporci\u00f3n Relativa (%)" = "proportion",
              "Frecuencia Acumulada (%)" = "accumfreq"
            ),
            selected = "logabun"
          )
        ),
        shiny::column(
          width = 4,
          shiny::selectInput(
            ns("whittaker_agrupacion"),
            "Agrupaci\u00f3n de Curvas:",
            choices = c(
              "Curvas por Parcela/Sitio" = "por_sitio",
              "Comunidad Total (Pooled)" = "general"
            ),
            selected = "por_sitio"
          )
        ),
        shiny::column(
          width = 4,
          shiny::numericInput(ns("whittaker_top_labels"), "Etiquetar Especies Top:", value = 3, min = 0, max = 10, step = 1)
        )
      ),
      plotly::plotlyOutput(ns("plot_whittaker"), height = "450px"),
      shiny::hr(),
      shiny::div(
        class = "d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2",
        shiny::h5(class = "font-weight-bold text-dark mb-0", shiny::icon("table"), " Tabla de Rango de Abundancia por Especie (Whittaker):"),
        shiny::div(
          class = "d-flex gap-2",
          shiny::downloadButton(ns("dl_whittaker_csv"), "Descargar CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
          shiny::downloadButton(ns("dl_whittaker_xlsx"), "Descargar Excel (.xlsx)", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
        )
      ),
      DT::DTOutput(ns("tabla_whittaker"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-success text-white mb-3", shiny::icon("magnifying-glass-chart"), " 6. Rareza, Ocurrencia y Completitud por Sitio"),
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shiny::div(
            class = "d-flex justify-content-between align-items-center mb-2",
            shiny::h5(class = "mb-0 font-weight-bold", "Ocurrencia y Rareza de Especies"),
            shiny::div(
              class = "d-flex gap-1",
              shiny::downloadButton(ns("dl_ocurrencia_csv"), "CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
              shiny::downloadButton(ns("dl_ocurrencia_xlsx"), "Excel", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
            )
          ),
          DT::DTOutput(ns("tabla_ocurrencia"))
        ),
        shiny::column(
          width = 6,
          shiny::div(
            class = "d-flex justify-content-between align-items-center mb-2",
            shiny::h5(class = "mb-0 font-weight-bold", "Completitud Muestral por Sitio"),
            shiny::div(
              class = "d-flex gap-1",
              shiny::downloadButton(ns("dl_completitud_csv"), "CSV", class = "btn-outline-primary btn-sm", icon = shiny::icon("file-csv")),
              shiny::downloadButton(ns("dl_completitud_xlsx"), "Excel", class = "btn-outline-success btn-sm", icon = shiny::icon("file-excel"))
            )
          ),
          DT::DTOutput(ns("tabla_completitud_sitio"))
        )
      ),
      shiny::hr(),
      plotly::plotlyOutput(ns("plot_completitud_sitio"), height = "360px")
    )
  )
}

mod_diversidad_server <- function(id, datos_reactive = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    datos_modulo <- shiny::reactive({
      if (isTRUE(input$usar_modo_independiente) || is.null(datos_reactive)) {
        set.seed(42)
        especies <- c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra",
                      "Guarea guidonia", "Inga edulis", "Dipteryx micrantha",
                      "Buchenavia capitata", "Eschweilera coriacea", "Protium puncticulatum")
        sitios <- paste0("Parcela_", rep(1:4, each = 15))
        data.frame(
          sitio = sitios,
          especie = sample(especies, 60, replace = TRUE),
          abundancia = sample(1:15, 60, replace = TRUE),
          stringsAsFactors = FALSE
        )
      } else {
        shiny::req(datos_reactive())
        standardize_inventory(datos_reactive())
      }
    })

    df_alfa <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)

      res <- diversidad_alfa(df, metodos = "full", base = 2)

      if ("shannon_h" %in% names(res)) res$shannon_h <- round(res$shannon_h, 3)
      if ("pielou_j" %in% names(res)) res$pielou_j <- round(res$pielou_j, 3)
      if ("gini_simpson" %in% names(res)) res$gini_simpson <- round(res$gini_simpson, 3)
      if ("simpson_inv" %in% names(res)) res$simpson_inv <- round(res$simpson_inv, 3)
      if ("margalef" %in% names(res)) res$margalef <- round(res$margalef, 3)
      if ("menhinick" %in% names(res)) res$menhinick <- round(res$menhinick, 3)
      if ("mcintosh" %in% names(res)) res$mcintosh <- round(res$mcintosh, 3)

      names(res) <- c("Sitio", "N\u00b0 Ind. (N)", "Riqueza (S)", "Shannon (H' log2)", "Pielou (J')",
                      "Gini-Simpson", "Simpson Inv.", "Margalef", "Menhinick", "McIntosh")
      res
    })

    output$tabla_alfa <- DT::renderDT({
      DT::datatable(df_alfa(), options = list(pageLength = 6, scrollX = TRUE), style = "bootstrap4")
    })

    # Descarga Alfa CSV
    output$dl_alfa_csv <- shiny::downloadHandler(
      filename = function() { paste0("diversidad_alfa_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(df_alfa(), file, row.names = FALSE) }
    )

    # Descarga Alfa Excel
    output$dl_alfa_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("diversidad_alfa_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(df_alfa(), file)
        } else {
          utils::write.csv(df_alfa(), file, row.names = FALSE)
        }
      }
    )

    metodo_sel <- shiny::reactive({
      if (is.null(input$metodo_beta)) "jaccard" else input$metodo_beta
    })

    output$nota_tecnica_beta_info <- shiny::renderUI({
      met <- metodo_sel()

      if (met == "jaccard") {
        shiny::div(
          class = "alert alert-info py-2 px-3 my-2 small shadow-sm border-left-info",
          shiny::icon("circle-info"), " ",
          shiny::tags$b("Nota T\u00e9cnica - \u00cdndice de Jaccard (Cualitativo): "),
          "Recomendado para datos de ", shiny::tags$b("Presencia / Ausencia"), " (listas de especies sin conteo). Eval\u00faa la proporci\u00f3n de especies compartidas sobre el total acumulado entre dos parcelas. Es un \u00edndice robusto e intuitivo cuando no se registr\u00f3 el n\u00famero de individuos."
        )
      } else if (met == "sorensen") {
        shiny::div(
          class = "alert alert-info py-2 px-3 my-2 small shadow-sm border-left-info",
          shiny::icon("circle-info"), " ",
          shiny::tags$b("Nota T\u00e9cnica - \u00cdndice de S\u00f8rensen (Cualitativo): "),
          "Recomendado para datos de ", shiny::tags$b("Presencia / Ausencia"), ". Otorga el doble de peso a las coincidencias de especies entre parcelas (2a / (2a + b + c)), lo que minimiza el sesgo cuando el esfuerzo de muestreo es moderado o parcial."
        )
      } else {
        shiny::div(
          class = "alert alert-success py-2 px-3 my-2 small shadow-sm border-left-success",
          shiny::icon("circle-check"), " ",
          shiny::tags$b("Nota T\u00e9cnica - \u00cdndice de Morisita-Horn (Cuantitativo): "),
          "Recomendado obligatoriamente cuando se dispone de datos de ", shiny::tags$b("Abundancia Cuantitativa"), " (conteos de individuos o cobertura). Es insensible a diferencias en el tama\u00f1o de muestra entre parcelas y pondera la similitud seg\u00fan la abundancia de las especies dominantes."
        )
      }
    })

    df_beta_tidy <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      diversidad_beta(df, metodo = metodo_sel(), formato = "tidy")
    })

    mat_beta <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      as.matrix(diversidad_beta(df, metodo = metodo_sel(), formato = "matrix"))
    })

    output$tabla_beta <- DT::renderDT({
      fmt <- ifelse(is.null(input$formato_tabla_beta), "tidy", input$formato_tabla_beta)
      if (fmt == "tidy") {
        df_tidy <- df_beta_tidy()
        lbl_met <- paste0("Similitud (", toupper(metodo_sel()), ")")
        names(df_tidy) <- c("Sitio 1", "Sitio 2", lbl_met, "Disimilitud")
        DT::datatable(df_tidy, options = list(pageLength = 6, scrollX = TRUE), style = "bootstrap4")
      } else {
        mb <- round(mat_beta(), 3)
        DT::datatable(mb, options = list(pageLength = 6, scrollX = TRUE, dom = 't'), style = "bootstrap4")
      }
    })

    # Descarga Beta CSV
    output$dl_beta_csv <- shiny::downloadHandler(
      filename = function() { paste0("diversidad_beta_", metodo_sel(), "_", input$formato_tabla_beta, "_", Sys.Date(), ".csv") },
      content = function(file) {
        fmt <- ifelse(is.null(input$formato_tabla_beta), "tidy", input$formato_tabla_beta)
        if (fmt == "tidy") {
          utils::write.csv(df_beta_tidy(), file, row.names = FALSE)
        } else {
          mb <- as.data.frame(mat_beta())
          utils::write.csv(mb, file, row.names = TRUE)
        }
      }
    )

    # Descarga Beta Excel
    output$dl_beta_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("diversidad_beta_", metodo_sel(), "_", input$formato_tabla_beta, "_", Sys.Date(), ".xlsx") },
      content = function(file) {
        fmt <- ifelse(is.null(input$formato_tabla_beta), "tidy", input$formato_tabla_beta)
        data_to_save <- if (fmt == "tidy") df_beta_tidy() else {
          mb <- as.data.frame(mat_beta())
          cbind(Sitio = rownames(mb), mb)
        }
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(data_to_save, file)
        } else {
          utils::write.csv(data_to_save, file, row.names = FALSE)
        }
      }
    )

    output$plot_beta <- plotly::renderPlotly({
      sim_jac <- mat_beta()
      shiny::req(sim_jac)

      vis_type <- ifelse(is.null(input$tipo_vis_beta), "heatmap", input$tipo_vis_beta)

      if (vis_type == "dendrograma") {
        disim_mat <- 1 - sim_jac
        hc <- stats::hclust(stats::as.dist(disim_mat), method = "average")

        if (requireNamespace("ggdendro", quietly = TRUE)) {
          ddata <- ggdendro::dendro_data(hc, type = "rectangle")
          p <- ggplot2::ggplot(ddata$segments) +
            ggplot2::geom_segment(ggplot2::aes(x = x, y = y, xend = xend, yend = yend), color = fv_pal[["marca"]], linewidth = 0.9) +
            ggplot2::geom_text(data = ddata$labels, ggplot2::aes(x = x, y = y, label = label), hjust = 1, angle = 90, size = 3.8, color = fv_pal[["tinta"]]) +
            ggplot2::scale_y_continuous(limits = c(-0.05, max(ddata$segments$y, 0.5) * 1.15), name = "Disimilitud (1 - Similitud)") +
            fv_chart_theme() +
            ggplot2::labs(
              title = paste0("Dendrograma de Agrupamiento Jer\u00e1rquico UPGMA (", toupper(metodo_sel()), ")"),
              x = "Sitio / Parcela"
            ) +
            ggplot2::theme(axis.text.x = ggplot2::element_blank(), axis.ticks.x = ggplot2::element_blank())
        } else {
          p <- ggplot2::ggplot() + ggplot2::labs(title = "ggdendro no disponible")
        }
        return(plotly::ggplotly(p))
      } else {
        df_grid <- expand.grid(Sitio1 = rownames(sim_jac), Sitio2 = colnames(sim_jac))
        df_grid$Similitud <- as.vector(sim_jac)

        p <- ggplot2::ggplot(df_grid, ggplot2::aes(x = Sitio1, y = Sitio2, fill = Similitud)) +
          ggplot2::geom_tile(color = "white") +
          ggplot2::scale_fill_viridis_c(option = "viridis", limits = c(0, 1)) +
          fv_chart_theme() +
          ggplot2::labs(title = paste0("Matriz de Similitud - \u00cdndice de ", toupper(metodo_sel()), " (0 a 1)"), x = "Sitio / Parcela", y = "Sitio / Parcela") +
          ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

        return(plotly::ggplotly(p))
      }
    })

    output$plot_acumulacion <- plotly::renderPlotly({
      df <- datos_modulo()
      shiny::req(df)

      sa <- curva_acumulacion(df, metodo = "random")
      df_acc <- data.frame(Sitios = sa$sites, Riqueza = sa$richness, SD = sa$sd)

      p <- ggplot2::ggplot(df_acc, ggplot2::aes(x = Sitios, y = Riqueza)) +
        ggplot2::geom_ribbon(ggplot2::aes(ymin = pmax(0, Riqueza - SD), ymax = Riqueza + SD), fill = fv_pal[["menta"]], alpha = 0.7) +
        ggplot2::geom_line(color = fv_pal[["marca"]], linewidth = 1.2) +
        ggplot2::geom_point(color = fv_pal[["agua"]], size = 3) +
        fv_chart_theme() +
        ggplot2::labs(
          title = "Curva Especie-\u00c1rea (Acumulaci\u00f3n Permutada)",
          x = "N\u00famero de Muestras/Sitios",
          y = "Riqueza de Especies (S)"
        )

      plotly::ggplotly(p)
    })

    output$tabla_estimadores <- shiny::renderTable({
      df <- datos_modulo()
      shiny::req(df)
      estimadores_riqueza(df)
    }, digits = 2)

    clench_resumen <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      if (length(unique(df$sitio)) < 2) return(NULL)
      tryCatch(modelo_clench(df), error = function(e) NULL)
    })

    output$resumen_representatividad <- shiny::renderUI({
      cl <- clench_resumen()
      shiny::validate(shiny::need(!is.null(cl), "No fue posible ajustar el modelo de Clench con el inventario activo."))

      rep_pct <- round(cl$representatividad_pct, 1)
      estado <- if (is.na(rep_pct)) {
        list(label = "No evaluable", class = "bg-secondary text-white", icon = "circle-question")
      } else if (rep_pct < 70) {
        list(label = "Insuficiente", class = "bg-danger text-white", icon = "triangle-exclamation")
      } else if (rep_pct <= 85) {
        list(label = "Aceptable", class = "bg-warning text-dark", icon = "circle-info")
      } else {
        list(label = "Robusto", class = "bg-success text-white", icon = "circle-check")
      }

      shiny::div(
        class = "d-flex justify-content-between align-items-stretch gap-3 flex-wrap",
        shiny::div(class = "metric-card p-3 rounded bg-light border", shiny::div(class = "metric-value", cl$riqueza_observada), shiny::div(class = "metric-label", "Riqueza Observada")),
        shiny::div(class = "metric-card p-3 rounded bg-light border", shiny::div(class = "metric-value", round(cl$asintota_estimada, 1)), shiny::div(class = "metric-label", "Riqueza Asintotica")),
        shiny::div(class = "metric-card p-3 rounded bg-light border", shiny::div(class = "metric-value", paste0(rep_pct, "%")), shiny::div(class = "metric-label", "Representatividad")),
        shiny::div(
          class = paste("metric-card p-3 rounded border d-flex flex-column justify-content-center", estado$class),
          shiny::div(class = "h4 font-weight-bold mb-1", shiny::icon(estado$icon), " ", estado$label),
          shiny::div(class = "small", "Semaforo tecnico del esfuerzo de muestreo")
        )
      )
    })

    inext_calc <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)

      mat <- long_to_comm(df)
      if (is.null(mat) || nrow(mat) < 1 || ncol(mat) < 2) return(NULL)

      t_mat <- t(mat)
      q_val <- ifelse(is.null(input$inext_orden_q), 0, as.numeric(input$inext_orden_q))
      nboot_val <- ifelse(is.null(input$inext_nboot), 10, as.numeric(input$inext_nboot))

      if (ncol(t_mat) > 20 || nrow(t_mat) > 100) {
        nboot_val <- min(nboot_val, 10)
      }

      if (requireNamespace("iNEXT", quietly = TRUE)) {
        tryCatch({
          iNEXT::iNEXT(t_mat, q = q_val, datatype = "abundance", nboot = nboot_val)
        }, error = function(e) NULL)
      } else {
        NULL
      }
    })

    output$plot_inext <- plotly::renderPlotly({
      res <- inext_calc()
      shiny::req(res)

      type_val <- ifelse(is.null(input$inext_tipo_curva), 1, as.numeric(input$inext_tipo_curva))

      if (requireNamespace("iNEXT", quietly = TRUE)) {
        p <- suppressWarnings(iNEXT::ggiNEXT(res, type = type_val))
        if (!is.null(res$iNextEst$size_based$Assemblage)) {
          n_assemblages <- length(unique(res$iNextEst$size_based$Assemblage))
          if (n_assemblages > 6) {
            p <- p + ggplot2::scale_shape_manual(values = rep(16, n_assemblages))
          }
        }
        p <- p +
          fv_chart_theme() +
          ggplot2::labs(
            title = paste0("Curva iNEXT (Tipo ", type_val, ") - Rarefacci\u00f3n & Extrapolaci\u00f3n"),
            subtitle = "Metodolog\u00eda de Chao et al. basada en N\u00fameros de Hill"
          )
        plotly::ggplotly(p)
      } else {
        p <- ggplot2::ggplot() + ggplot2::labs(title = "El paquete iNEXT no est\u00e1 disponible.")
        plotly::ggplotly(p)
      }
    })

    output$tabla_inext <- DT::renderDT({
      res <- inext_calc()
      shiny::req(res, res$AsyEst)

      df_asy <- res$AsyEst
      names(df_asy) <- c("Sitio", "M\u00e9trica de Diversidad", "Observado", "Estimador Asint\u00f3tico", "Error Est\u00e1ndar (SE)", "L\u00edmite Inf. 95%", "L\u00edmite Sup. 95%")
      DT::datatable(df_asy, options = list(pageLength = 6, scrollX = TRUE), style = "bootstrap4")
    })

    # Descarga iNEXT CSV
    output$dl_inext_csv <- shiny::downloadHandler(
      filename = function() { paste0("inext_estimaciones_asintoticas_q", input$inext_orden_q, "_", Sys.Date(), ".csv") },
      content = function(file) {
        res <- inext_calc()
        shiny::req(res, res$AsyEst)
        utils::write.csv(res$AsyEst, file, row.names = FALSE)
      }
    )

    # Descarga iNEXT Excel
    output$dl_inext_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("inext_estimaciones_asintoticas_q", input$inext_orden_q, "_", Sys.Date(), ".xlsx") },
      content = function(file) {
        res <- inext_calc()
        shiny::req(res, res$AsyEst)
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(res$AsyEst, file)
        } else {
          utils::write.csv(res$AsyEst, file, row.names = FALSE)
        }
      }
    )

    df_whittaker <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      por_sitio <- ifelse(is.null(input$whittaker_agrupacion), TRUE, input$whittaker_agrupacion == "por_sitio")
      curva_whittaker(df, por_sitio = por_sitio)
    })

    output$plot_whittaker <- plotly::renderPlotly({
      df <- datos_modulo()
      shiny::req(df)
      sc <- ifelse(is.null(input$whittaker_scale), "logabun", input$whittaker_scale)
      ps <- ifelse(is.null(input$whittaker_agrupacion), TRUE, input$whittaker_agrupacion == "por_sitio")
      n_lab <- ifelse(is.null(input$whittaker_top_labels), 3, as.numeric(input$whittaker_top_labels))

      p <- plot_whittaker(df, scale = sc, por_sitio = ps, top_n_labels = n_lab)
      plotly::ggplotly(p)
    })

    output$tabla_whittaker <- DT::renderDT({
      df_w <- df_whittaker()
      shiny::req(df_w)
      if ("abundance" %in% names(df_w)) df_w$abundance <- round(df_w$abundance, 1)
      if ("proportion" %in% names(df_w)) df_w$proportion <- round(df_w$proportion, 2)
      if ("accumfreq" %in% names(df_w)) df_w$accumfreq <- round(df_w$accumfreq, 2)
      if ("logabun" %in% names(df_w)) df_w$logabun <- round(df_w$logabun, 3)
      if ("rankfreq" %in% names(df_w)) df_w$rankfreq <- round(df_w$rankfreq, 2)

      names(df_w) <- c("Sitio/Grupo", "Especie", "Rango (Rank)", "Abundancia Abs.", "Proporci\u00f3n (%)", "Frec. Acumulada (%)", "Log10 Abundancia", "Rango Rel. (%)")
      DT::datatable(df_w, options = list(pageLength = 6, scrollX = TRUE), style = "bootstrap4")
    })

    ocurrencia_resumen <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      mat <- long_to_comm(df)
      freq_sp <- colSums(mat > 0)
      abund_sp <- colSums(mat, na.rm = TRUE)
      n_sites <- nrow(mat)

      res <- data.frame(
        Especie = names(freq_sp),
        Sitios_Ocupados = as.integer(freq_sp),
        Ocurrencia_pct = round((freq_sp / n_sites) * 100, 2),
        Abundancia_Total = as.numeric(abund_sp),
        Categoria = ifelse(freq_sp == 1, "Unica en un sitio",
                    ifelse(abund_sp == 1, "Singleton",
                    ifelse(abund_sp == 2, "Doubleton", "Compartida / frecuente"))),
        stringsAsFactors = FALSE
      )
      res[order(res$Sitios_Ocupados, res$Abundancia_Total), ]
    })

    output$tabla_ocurrencia <- DT::renderDT({
      DT::datatable(
        ocurrencia_resumen(),
        options = list(pageLength = 8, scrollX = TRUE),
        rownames = FALSE,
        style = "bootstrap4"
      )
    })

    completitud_sitio <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)
      mat <- long_to_comm(df)
      rows <- lapply(seq_len(nrow(mat)), function(i) {
        abund <- mat[i, ]
        n <- sum(abund, na.rm = TRUE)
        s_obs <- sum(abund > 0, na.rm = TRUE)
        f1 <- sum(abund == 1, na.rm = TRUE)
        cobertura <- if (n > 0) pmax(0, 1 - (f1 / n)) * 100 else NA_real_
        data.frame(
          Sitio = rownames(mat)[i],
          N_individuos = as.numeric(n),
          Riqueza_observada = as.integer(s_obs),
          Singleton = as.integer(f1),
          Cobertura_muestral_pct = round(cobertura, 2),
          Estado = ifelse(is.na(cobertura), "No evaluable",
                   ifelse(cobertura < 70, "Submuestreo probable",
                   ifelse(cobertura <= 85, "Completitud aceptable", "Completitud robusta"))),
          stringsAsFactors = FALSE
        )
      })
      do.call(rbind, rows)
    })

    output$tabla_completitud_sitio <- DT::renderDT({
      DT::datatable(
        completitud_sitio(),
        options = list(pageLength = 8, scrollX = TRUE),
        rownames = FALSE,
        style = "bootstrap4"
      )
    })

    output$plot_completitud_sitio <- plotly::renderPlotly({
      df_c <- completitud_sitio()
      shiny::req(df_c)
      p <- ggplot2::ggplot(df_c, ggplot2::aes(x = Sitio, y = Cobertura_muestral_pct, fill = Estado)) +
        ggplot2::geom_col(alpha = 0.9) +
        ggplot2::geom_hline(yintercept = c(70, 85), linetype = "dashed", color = fv_pal[["neutro"]]) +
        fv_scale_fill(c("Submuestreo probable", "Completitud aceptable", "Completitud robusta", "No evaluable")) +
        fv_chart_theme() +
        ggplot2::labs(
          title = "Completitud muestral estimada por sitio",
          x = "Sitio / Parcela",
          y = "Cobertura muestral (%)",
          fill = "Estado"
        ) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
      plotly::ggplotly(p)
    })

    # Descarga Whittaker CSV
    output$dl_whittaker_csv <- shiny::downloadHandler(
      filename = function() { paste0("whittaker_rank_abundance_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(df_whittaker(), file, row.names = FALSE) }
    )

    # Descarga Whittaker Excel
    output$dl_whittaker_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("whittaker_rank_abundance_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(df_whittaker(), file)
        } else {
          utils::write.csv(df_whittaker(), file, row.names = FALSE)
        }
      }
    )

    # Descarga Ocurrencia y Rareza CSV
    output$dl_ocurrencia_csv <- shiny::downloadHandler(
      filename = function() { paste0("ocurrencia_rareza_especies_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(ocurrencia_resumen(), file, row.names = FALSE) }
    )

    # Descarga Ocurrencia y Rareza Excel
    output$dl_ocurrencia_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("ocurrencia_rareza_especies_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(ocurrencia_resumen(), file)
        } else {
          utils::write.csv(ocurrencia_resumen(), file, row.names = FALSE)
        }
      }
    )

    # Descarga Completitud por Sitio CSV
    output$dl_completitud_csv <- shiny::downloadHandler(
      filename = function() { paste0("completitud_muestral_sitio_", Sys.Date(), ".csv") },
      content = function(file) { utils::write.csv(completitud_sitio(), file, row.names = FALSE) }
    )

    # Descarga Completitud por Sitio Excel
    output$dl_completitud_xlsx <- shiny::downloadHandler(
      filename = function() { paste0("completitud_muestral_sitio_", Sys.Date(), ".xlsx") },
      content = function(file) {
        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(completitud_sitio(), file)
        } else {
          utils::write.csv(completitud_sitio(), file, row.names = FALSE)
        }
      }
    )

    codigo_r_text <- shiny::reactive({
      paste0(
        "library(floraveg)\n",
        "library(ggplot2)\n",
        "library(ggdendro)\n",
        "library(iNEXT)\n\n",
        "# 1. Diversidad Alfa Completa\n",
        "alfa <- diversidad_alfa(datos, metodos = 'full', base = 2)\n",
        "print(alfa)\n\n",
        "# 2. Similitud Beta (Jaccard, Sorensen o Morisita-Horn)\n",
        "beta_tidy <- diversidad_beta(datos, metodo = '", metodo_sel(), "', formato = 'tidy')\n",
        "print(beta_tidy)\n\n",
        "# 3. Rarefaccion y Extrapolacion con iNEXT (Hill q = ", ifelse(is.null(input$inext_orden_q), 0, input$inext_orden_q), ")\n",
        "mat <- t(long_to_comm(datos))\n",
        "res_inext <- iNEXT(mat, q = ", ifelse(is.null(input$inext_orden_q), 0, input$inext_orden_q), ", datatype = 'abundance')\n",
        "ggiNEXT(res_inext, type = 1)\n"
      )
    })

    shiny::observeEvent(input$btn_ver_codigo, {
      shiny::showModal(shiny::modalDialog(
        title = shiny::tags$div(shiny::icon("code"), " C\u00f3digo R (speciesdiv + ggplot2 + iNEXT) - Diversidad Alfa, Beta & Rarefacci\u00f3n"),
        size = "l",
        easyClose = TRUE,
        footer = shiny::tagList(
          shiny::actionButton(
            ns("btn_copiar"),
            "Copiar al Portapapeles",
            icon = shiny::icon("copy"),
            class = "btn-success",
            onclick = sprintf("copyCodeToClipboard('%s')", ns("modal_code_div"))
          ),
          shiny::modalButton("Cerrar")
        ),
        shiny::tags$p("Sintaxis R lista para ejecutar en RStudio:"),
        shiny::tags$pre(
          id = ns("modal_code_div"),
          class = "code-block-scroll",
          codigo_r_text()
        )
      ))
    })

  })
}
