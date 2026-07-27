# M\u00f3dulo Shiny: \u00c1rea Basal, Volumen Maderable y Biomasa A\u00e9rea (Densidad por Especie/G\u00e9nero + ggplot2)
mod_biomasa_volumen_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "card p-3 mb-4 shadow-sm border-0 bg-light d-flex justify-content-between align-items-center flex-row",
      shiny::div(
        shiny::h4(class = "text-success font-weight-bold mb-0", shiny::icon("weight-hanging"), " \u00c1rea Basal, Volumen Maderable & Biomasa A\u00e9rea"),
        shiny::p(class = "text-muted small mb-0", "C\u00e1lculos dasom\u00e9tricos con asignaci\u00f3n de densidad b\u00e1sica de madera por especie, g\u00e9nero, plantilla Excel o ingreso manual.")
      ),
      shiny::div(
        class = "d-flex align-items-center gap-2",
        shiny::actionButton(ns("btn_ver_codigo"), "Ver C\u00f3digo R", icon = shiny::icon("code"), class = "btn-outline-success btn-sm font-weight-bold me-2"),
        shiny::checkboxInput(ns("usar_modo_independiente"), "Modo Independiente", value = FALSE)
      )
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-primary text-white mb-3", shiny::icon("sliders"), " 1. Par\u00e1metros de C\u00e1lculo Dasom\u00e9trico & Densidad de Madera"),
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shiny::radioButtons(
            ns("modo_densidad"),
            "Estrategia de Asignaci\u00f3n de Densidad de Madera (\u03c1):",
            choices = c(
              "Base de Referencia Neotropical (Especie / G\u00e9nero)" = "especifica",
              "Flujo Guiado seg\u00fan N\u00b0 de Especies (<10 Manual / \u226510 Plantilla Excel)" = "auto_smart",
              "Ingreso / Edici\u00f3n Manual por Especie (Casilleros)" = "manual",
              "Plantilla Excel Personalizada (Descargar \u2192 Completar \u2192 Cargar)" = "template_excel",
              "Factor Est\u00e1ndar Fijo para Todas las Especies" = "estandar"
            ),
            selected = "especifica"
          )
        ),
        shiny::column(3, shiny::numericInput(ns("factor_forma"), "Factor de Forma (Fm):", value = 0.70, min = 0.1, max = 1.0, step = 0.05)),
        shiny::column(3, shiny::numericInput(ns("densidad_madera"), "Factor Est\u00e1ndar / Fallback (g/cm\u00b3):", value = 0.60, min = 0.1, max = 1.2, step = 0.05))
      ),
      shiny::uiOutput(ns("opciones_densidad_extra")),
      shiny::uiOutput(ns("resumen_densidad_info"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-success text-white mb-3", shiny::icon("table"), " 2. Resumen Dasom\u00e9trico y Biomasa por Parcela"),
      DT::DTOutput(ns("tabla_biomasa"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-dark text-white mb-3", shiny::icon("chart-bar"), " 3. Estimaci\u00f3n de Volumen Maderable y Biomasa (ggplot2)"),
      plotly::plotlyOutput(ns("plot_biomasa"), height = "450px")
    )
  )
}

mod_biomasa_volumen_server <- function(id, datos_reactive = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    datos_modulo <- shiny::reactive({
      if (isTRUE(input$usar_modo_independiente) || is.null(datos_reactive)) {
        set.seed(42)
        sitios <- paste0("Parcela_", rep(1:4, each = 15))
        especies <- c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra",
                      "Guarea guidonia", "Inga edulis", "Dipteryx micrantha", "Desconocida sp.")
        data.frame(
          sitio = sitios,
          especie = sample(especies, 60, replace = TRUE),
          dap_cm = round(stats::runif(60, 10, 90), 1),
          altura_m = round(stats::runif(60, 6, 30), 1),
          stringsAsFactors = FALSE
        )
      } else {
        shiny::req(datos_reactive())
        standardize_inventory(datos_reactive())
      }
    })

    # Renderizado din\u00e1mico de controles seg\u00fan estrategia o N\u00b0 de especies
    output$opciones_densidad_extra <- shiny::renderUI({
      modo <- input$modo_densidad
      df <- datos_modulo()

      if (is.null(modo)) return(NULL)
      shiny::req(df, "especie" %in% names(df))

      sps <- sort(unique(stats::na.omit(as.character(df$especie))))
      n_sp <- length(sps)

      # Determinar si se activa modo manual o plantilla excel
      is_manual <- modo == "manual" || (modo == "auto_smart" && n_sp < 10)
      is_template <- modo == "template_excel" || modo == "custom_file" || (modo == "auto_smart" && n_sp >= 10)

      if (is_template) {
        shiny::div(
          class = "p-3 my-2 bg-light border rounded",
          shiny::div(
            class = "alert alert-secondary py-2 px-3 mb-3 small",
            shiny::icon("circle-info"), " ",
            shiny::strong(paste0("Se detectaron ", n_sp, " especies \u00fanicas (\u2265 10). ")),
            "Para garantizar la consistencia taxon\u00f3mica a nivel de especie y g\u00e9nero, se recomienda utilizar la plantilla Excel."
          ),
          shiny::div(
            class = "d-flex align-items-center gap-3 flex-wrap mb-3",
            shiny::downloadButton(
              ns("btn_download_template"),
              "1. Descargar Plantilla Excel (.xlsx)",
              class = "btn-success font-weight-bold",
              icon = shiny::icon("file-download")
            )
          ),
          shiny::fileInput(
            ns("file_densidades_custom"),
            "2. Cargar Plantilla Completada (.xlsx / .csv):",
            accept = c(".xlsx", ".xls", ".csv"),
            buttonLabel = "Examinar...",
            placeholder = "Sin archivo cargado"
          ),
          shiny::tags$p(
            class = "text-muted small mb-0",
            shiny::icon("lightbulb"),
            " Nota: Los registros que deje en blanco o sin valor recibir\u00e1n autom\u00e1ticamente el factor est\u00e1ndar por defecto."
          )
        )
      } else if (is_manual) {
        if (n_sp == 0) return(NULL)

        def_val <- ifelse(is.null(input$densidad_madera), 0.60, input$densidad_madera)
        initial_dens <- obtener_densidad_madera(sps, default = def_val)

        cols <- lapply(seq_along(sps), function(i) {
          sp <- sps[i]
          val <- initial_dens[i]
          shiny::column(
            width = 4,
            shiny::div(
              class = "mb-2 p-2 border rounded bg-white shadow-sm",
              shiny::tags$label(class = "small font-weight-bold text-truncate d-block text-dark", sp),
              shiny::numericInput(
                ns(paste0("sp_dens_", i)),
                label = NULL,
                value = val,
                min = 0.05,
                max = 1.50,
                step = 0.01
              )
            )
          )
        })

        shiny::div(
          class = "mt-2 mb-3 p-3 bg-light rounded border",
          shiny::div(
            class = "alert alert-secondary py-2 px-3 mb-2 small",
            shiny::icon("circle-info"), " ",
            shiny::strong(paste0("Se detectaron ", n_sp, " especies \u00fanicas (< 10). ")),
            "Puede ingresar o ajustar directamente el valor de densidad para cada una."
          ),
          shiny::h6(class = "text-primary font-weight-bold mb-2", shiny::icon("pen-to-square"), " Ingrese / Ajuste la densidad b\u00e1sica (g/cm\u00b3) por especie:"),
          shiny::fluidRow(cols)
        )
      } else {
        NULL
      }
    })

    # Handler para descargar la plantilla Excel prellenada con especies y generos
    output$btn_download_template <- shiny::downloadHandler(
      filename = function() {
        paste0("plantilla_densidades_madera_", Sys.Date(), ".xlsx")
      },
      content = function(file) {
        df <- datos_modulo()
        sps <- sort(unique(stats::na.omit(as.character(df$especie))))
        if (length(sps) == 0) sps <- c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra")

        def_val <- ifelse(is.null(input$densidad_madera), 0.60, input$densidad_madera)
        ref_dens <- obtener_densidad_madera(sps, default = NA_real_)
        generos <- sub(" .*", "", sps)

        template_df <- data.frame(
          especie = sps,
          genero = generos,
          densidad_madera = ref_dens,
          stringsAsFactors = FALSE
        )

        if (requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(template_df, file)
        } else {
          utils::write.csv(template_df, file, row.names = FALSE)
        }
      }
    )

    # Lectura y parseo del archivo personalizado/plantilla cargado por el usuario
    custom_file_densities <- shiny::reactive({
      shiny::req(input$file_densidades_custom)
      file_path <- input$file_densidades_custom$datapath
      ext <- tolower(tools::file_ext(file_path))

      tryCatch({
        if (ext %in% c("csv", "txt")) {
          df_custom <- utils::read.csv(file_path, stringsAsFactors = FALSE)
        } else if (ext %in% c("xlsx", "xls") && requireNamespace("readxl", quietly = TRUE)) {
          df_custom <- readxl::read_excel(file_path)
        } else {
          return(NULL)
        }
        names(df_custom) <- tolower(trimws(names(df_custom)))
        sp_col <- names(df_custom)[names(df_custom) %in% c("especie", "especies", "species", "sp", "nombre_cientifico")][1]
        gen_col <- names(df_custom)[names(df_custom) %in% c("genero", "g\u00e9nero", "genus")][1]
        dens_col <- names(df_custom)[names(df_custom) %in% c("densidad_madera", "densidad", "wd", "wood_density", "rho")][1]

        if (!is.na(sp_col) && !is.na(dens_col)) {
          sps <- as.character(df_custom[[sp_col]])
          dens_vals <- suppressWarnings(as.numeric(df_custom[[dens_col]]))

          db_sp <- stats::setNames(dens_vals, sps)
          db_gen <- NULL
          if (!is.na(gen_col)) {
            gens <- as.character(df_custom[[gen_col]])
            valid_gen <- !is.na(gens) & !is.na(dens_vals)
            if (any(valid_gen)) {
              db_gen <- stats::setNames(dens_vals[valid_gen], gens[valid_gen])
            }
          }
          return(list(db_sp = db_sp, db_gen = db_gen))
        }
        return(NULL)
      }, error = function(e) NULL)
    })

    # Lectura de los inputs manuales por especie
    manual_densities <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df, "especie" %in% names(df))
      sps <- sort(unique(stats::na.omit(as.character(df$especie))))
      def_val <- ifelse(is.null(input$densidad_madera), 0.60, input$densidad_madera)
      initial_dens <- obtener_densidad_madera(sps, default = def_val)

      vec <- stats::setNames(initial_dens, sps)
      for (i in seq_along(sps)) {
        inp_id <- paste0("sp_dens_", i)
        val <- input[[inp_id]]
        if (!is.null(val) && !is.na(val) && is.numeric(val)) {
          vec[sps[i]] <- val
        }
      }
      vec
    })

    densidad_info <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)

      modo <- ifelse(is.null(input$modo_densidad), "especifica", input$modo_densidad)
      def_val <- ifelse(is.null(input$densidad_madera), 0.60, input$densidad_madera)
      sps <- sort(unique(stats::na.omit(as.character(df$especie))))
      n_sp <- length(sps)

      is_manual <- modo == "manual" || (modo == "auto_smart" && n_sp < 10)
      is_template <- modo == "template_excel" || modo == "custom_file" || (modo == "auto_smart" && n_sp >= 10)

      if (is_template) {
        custom_res <- custom_file_densities()
        if (!is.null(custom_res)) {
          db_sp <- custom_res$db_sp
          db_gen <- custom_res$db_gen

          dens_vec <- rep(as.numeric(def_val), nrow(df))
          generos <- sub(" .*", "", as.character(df$especie))

          for (i in seq_along(df$especie)) {
            sp <- as.character(df$especie[i])
            gen <- generos[i]

            if (!is.na(sp) && sp %in% names(db_sp) && !is.na(db_sp[[sp]])) {
              dens_vec[i] <- as.numeric(db_sp[[sp]])
            } else if (!is.null(db_gen) && !is.na(gen) && gen %in% names(db_gen) && !is.na(db_gen[[gen]])) {
              dens_vec[i] <- as.numeric(db_gen[[gen]])
            } else {
              dens_vec[i] <- as.numeric(def_val)
            }
          }
          orig <- paste0("Plantilla Excel ('", input$file_densidades_custom$name, "') - Coincidencia Especie/G\u00e9nero con fallback est\u00e1ndar (", def_val, " g/cm\u00b3)")
        } else {
          dens_vec <- obtener_densidad_madera(df$especie, default = def_val)
          orig <- "Base Neotropical (Esperando carga de Plantilla Excel...)"
        }
      } else if (is_manual) {
        man_db <- manual_densities()
        dens_vec <- obtener_densidad_madera(df$especie, db_densidades = man_db, default = def_val)
        orig <- "Valores de densidad ingresados/editados manualmente por especie"
      } else if (modo == "especifica" && "especie" %in% names(df)) {
        dens_vec <- obtener_densidad_madera(df$especie, default = def_val)
        orig <- "Base de referencia Neotropical (Especie / G\u00e9nero + Fallback)"
      } else if ("densidad_madera" %in% names(df)) {
        dens_vec <- suppressWarnings(as.numeric(df$densidad_madera))
        dens_vec[is.na(dens_vec)] <- def_val
        orig <- "Columna propia del dataset ('densidad_madera')"
      } else {
        dens_vec <- rep(def_val, nrow(df))
        orig <- paste0("Factor est\u00e1ndar fijo (", def_val, " g/cm\u00b3)")
      }

      list(vector = dens_vec, origen = orig)
    })

    output$resumen_densidad_info <- shiny::renderUI({
      info <- densidad_info()
      dens_vec <- info$vector
      avg_dens <- round(mean(dens_vec, na.rm = TRUE), 3)

      shiny::div(
        class = "alert alert-info py-2 px-3 mt-2 mb-0 d-flex justify-content-between align-items-center",
        shiny::span(
          shiny::icon("circle-info"), " ",
          shiny::strong("Estrategia activa: "), info$origen
        ),
        shiny::span(
          class = "badge bg-dark text-white p-2",
          paste0("Densidad Media Calculada: ", avg_dens, " g/cm\u00b3")
        )
      )
    })

    df_bio <- shiny::reactive({
      df <- datos_modulo()
      shiny::req(df)

      fm <- ifelse(is.null(input$factor_forma), 0.70, input$factor_forma)
      info <- densidad_info()
      df$dens_assigned <- info$vector

      if (!"dap_cm" %in% names(df)) return(NULL)
      df$ab_m2 <- area_basal(dap_cm = df$dap_cm, unidad_salida = "m2")

      if ("altura_m" %in% names(df)) {
        df$vol_m3 <- volumen_maderable(df$ab_m2, df$altura_m, factor_forma = fm)
        df$biomasa_ton <- biomasa_aerea(densidad_madera = df$dens_assigned, volumen_m3 = df$vol_m3)
      } else {
        df$vol_m3 <- NA_real_
        df$biomasa_ton <- NA_real_
      }

      res <- stats::aggregate(
        cbind(ab_m2, vol_m3, biomasa_ton, dens_assigned) ~ sitio,
        data = df,
        FUN = function(x) c(sum = sum(x, na.rm = TRUE), mean = mean(x, na.rm = TRUE))
      )

      df_res <- data.frame(
        Sitio = res$sitio,
        Area_Basal_m2 = round(res$ab_m2[, "sum"], 4),
        Volumen_m3 = round(res$vol_m3[, "sum"], 3),
        Densidad_Prom_g_cm3 = round(res$dens_assigned[, "mean"], 3),
        Biomasa_t = round(res$biomasa_ton[, "sum"], 3),
        stringsAsFactors = FALSE
      )

      df_res
    })

    output$tabla_biomasa <- DT::renderDT({
      shiny::req(df_bio())
      df_show <- df_bio()
      names(df_show) <- c("Sitio", "\u00c1rea Basal Total (m\u00b2)", "Volumen Maderable (m\u00b3)", "Densidad Promedio (g/cm\u00b3)", "Biomasa A\u00e9rea (t)")
      DT::datatable(df_show, options = list(pageLength = 6, scrollX = TRUE), style = "bootstrap4")
    })

    output$plot_biomasa <- plotly::renderPlotly({
      df_b <- df_bio()
      shiny::req(df_b)

      df_long <- data.frame(
        Sitio = rep(df_b$Sitio, 2),
        Metrica = rep(c("Volumen (m3)", "Biomasa (t)"), each = nrow(df_b)),
        Valor = c(df_b$Volumen_m3, df_b$Biomasa_t)
      )

      p <- ggplot2::ggplot(df_long, ggplot2::aes(x = Sitio, y = Valor, fill = Metrica)) +
        ggplot2::geom_col(position = "dodge", alpha = 0.9) +
        ggplot2::scale_fill_manual(values = c("Volumen (m3)" = "#1b4d3e", "Biomasa (t)" = "#52b788")) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "Estimaci\u00f3n de Volumen Maderable y Biomasa por Sitio",
          x = "Sitio / Parcela",
          y = "Valor Estimado",
          fill = "M\u00e9trica"
        )

      plotly::ggplotly(p)
    })

    codigo_r_text <- shiny::reactive({
      fm <- ifelse(is.null(input$factor_forma), 0.70, input$factor_forma)
      modo <- ifelse(is.null(input$modo_densidad), "especifica", input$modo_densidad)
      def_val <- ifelse(is.null(input$densidad_madera), 0.60, input$densidad_madera)

      paste0(
        "library(floraveg)\n",
        "library(ggplot2)\n\n",
        "# 1. Area basal y volumen maderable\n",
        "datos$ab_m2 <- area_basal(dap_cm = datos$dap_cm, unidad_salida = 'm2')\n",
        "datos$vol_m3 <- volumen_maderable(datos$ab_m2, datos$altura_m, factor_forma = ", fm, ")\n\n",
        "# 2. Asignacion de densidad de madera (especie / genero, manual o plantilla excel)\n",
        if (modo == "especifica") {
          paste0("datos$densidad <- obtener_densidad_madera(datos$especie, default = ", def_val, ")\n")
        } else if (modo %in% c("template_excel", "custom_file", "auto_smart")) {
          paste0("# Cargar plantilla Excel completada por el usuario\n",
                 "db_custom <- readxl::read_excel('plantilla_densidades_madera.xlsx')\n",
                 "db_vec <- setNames(db_custom$densidad_madera, db_custom$especie)\n",
                 "datos$densidad <- obtener_densidad_madera(datos$especie, db_densidades = db_vec, default = ", def_val, ")\n")
        } else if (modo == "manual") {
          paste0("# Densidades especificadas manualmente por especie\n",
                 "datos$densidad <- obtener_densidad_madera(datos$especie, default = ", def_val, ")\n")
        } else {
          paste0("datos$densidad <- ", def_val, "\n")
        },
        "datos$biomasa_ton <- biomasa_aerea(densidad_madera = datos$densidad, volumen_m3 = datos$vol_m3)\n\n",
        "# 3. Resumen por sitio\n",
        "resumen <- aggregate(cbind(vol_m3, biomasa_ton) ~ sitio, data = datos, FUN = sum)\n",
        "print(resumen)\n\n",
        "# 4. Grafico comparativo con ggplot2\n",
        "df_long <- data.frame(\n",
        "  Sitio = rep(resumen$sitio, 2),\n",
        "  Metrica = rep(c('Volumen (m3)', 'Biomasa (t)'), each = nrow(resumen)),\n",
        "  Valor = c(resumen$vol_m3, resumen$biomasa_ton)\n",
        ")\n",
        "ggplot(df_long, aes(x = Sitio, y = Valor, fill = Metrica)) +\n",
        "  geom_col(position = 'dodge') +\n",
        "  scale_fill_manual(values = c('Volumen (m3)' = '#1b4d3e', 'Biomasa (t)' = '#52b788')) +\n",
        "  theme_minimal()\n"
      )
    })

    shiny::observeEvent(input$btn_ver_codigo, {
      shiny::showModal(shiny::modalDialog(
        title = shiny::tags$div(shiny::icon("code"), " C\u00f3digo R (ggplot2) - Biomasa & Volumen"),
        size = "l",
        easyClose = TRUE,
        footer = shiny::tagList(
          shiny::actionButton(
            ns("btn_copiar"),
            "Copiar al Portapapeles",
            icon = shiny::icon("copy"),
            class = "btn-success",
            onclick = sprintf("copyCodeToClipboard('%s')", ns("modal_code_bio"))
          ),
          shiny::modalButton("Cerrar")
        ),
        shiny::tags$p("Sintaxis R en ggplot2 lista para ejecutar en RStudio:"),
        shiny::tags$pre(
          id = ns("modal_code_bio"),
          style = "background-color: #1e293b; color: #38bdf8; padding: 1rem; border-radius: 8px; max-height: 400px; overflow-y: auto;",
          codigo_r_text()
        )
      ))
    })

  })
}
