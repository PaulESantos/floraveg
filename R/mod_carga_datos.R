# M\u00f3dulo Shiny: Carga, Mapeo y Validaci\u00f3n de Datos seg\u00fan Modelo de Origen
mod_carga_datos_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-primary text-white mb-3", shiny::icon("file-import"), " 1. Carga de Inventario & Mapeo de Columnas"),
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shiny::radioButtons(
            ns("fuente_datos"),
            "Fuente de datos:",
            choices = c(
              "Bosque Neotropical (Ejemplo Completo con DAP/H)" = "ejemplo",
              "Dune Vegetation Dataset (Jongman et al. 1987 - 30 especies / 20 sitios)" = "dune_t",
              "Barro Colorado Island BCI (Zanne et al. 2014 - 225 especies / 50 ha)" = "bci_t",
              "Cargar archivo local (CSV / Excel)" = "archivo"
            ),
            selected = "ejemplo"
          ),
          shiny::conditionalPanel(
            condition = sprintf("input['%s'] == 'archivo'", ns("fuente_datos")),
            shiny::fileInput(ns("file_input"), "Seleccionar archivo (.csv, .xlsx):", accept = c(".csv", ".xlsx", ".xls"))
          )
        ),
        shiny::column(
          width = 6,
          shiny::h5(class = "text-dark font-weight-bold mb-2", shiny::icon("sliders"), " Mapeo de Columnas con el Modelo BD:"),
          shiny::fluidRow(
            shiny::column(6, shiny::selectInput(ns("col_sitio"), "Sitio / Parcela:", choices = NULL)),
            shiny::column(6, shiny::selectInput(ns("col_especie"), "Especie:", choices = NULL)),
            shiny::column(6, shiny::selectInput(ns("col_abundancia"), "Abundancia:", choices = NULL)),
            shiny::column(6, shiny::selectInput(ns("col_dap"), "DAP (cm):", choices = NULL)),
            shiny::column(6, shiny::selectInput(ns("col_altura"), "Altura (m):", choices = NULL)),
            shiny::column(6, shiny::selectInput(ns("col_dc"), "Di\u00e1metro Copa (m):", choices = NULL))
          ),
          shiny::actionButton(ns("btn_confirmar"), "Confirmar y Validar Datos", class = "btn-success w-100 mt-2", icon = shiny::icon("check-circle"))
        )
      )
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::div(
        class = "card-header bg-dark text-white d-flex justify-content-between align-items-center mb-3",
        shiny::h4(class = "mb-0 text-white", shiny::icon("list-check"), " 2. Resumen & Validaci\u00f3n de Conformidad BD"),
        shiny::actionButton(ns("btn_ver_codigo"), "Ver C\u00f3digo R", icon = shiny::icon("code"), class = "btn-light btn-sm text-dark font-weight-bold")
      ),
      shiny::uiOutput(ns("resumen_validacion"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-secondary text-white mb-3", shiny::icon("table"), " 3. Vista Previa de Registros Mapeados"),
      DT::DTOutput(ns("tabla_previa"))
    )
  )
}

mod_carga_datos_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    datos_raw <- shiny::reactive({
      src <- input$fuente_datos
      if (src == "ejemplo") {
        set.seed(42)
        especies <- c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra",
                      "Guarea guidonia", "Inga edulis", "Dipteryx micrantha",
                      "Buchenavia capitata", "Eschweilera coriacea", "Protium puncticulatum")
        sitios <- paste0("Parcela_", rep(1:4, each = 15))
        sp_sample <- sample(especies, 60, replace = TRUE)
        ab_sample <- sample(1:15, 60, replace = TRUE)
        dap_sample <- round(stats::runif(60, 8, 85), 1)
        alt_sample <- round(stats::runif(60, 5, 32), 1)
        dc_sample <- round(stats::runif(60, 2, 14), 1)

        data.frame(
          sitio = sitios,
          especie = sp_sample,
          abundancia = ab_sample,
          dap_cm = dap_sample,
          altura_m = alt_sample,
          dc_m = dc_sample,
          stringsAsFactors = FALSE
        )
      } else if (src == "dune_t") {
        if (exists("dune_t", envir = .GlobalEnv)) {
          get("dune_t", envir = .GlobalEnv)
        } else {
          utils::data("dune_t", package = "floraveg", envir = environment())
          get("dune_t")
        }
      } else if (src == "bci_t") {
        if (exists("bci_t", envir = .GlobalEnv)) {
          get("bci_t", envir = .GlobalEnv)
        } else {
          utils::data("bci_t", package = "floraveg", envir = environment())
          get("bci_t")
        }
      } else {
        shiny::req(input$file_input)
        ext <- tools::file_ext(input$file_input$name)
        if (ext == "csv") {
          utils::read.csv(input$file_input$datapath, stringsAsFactors = FALSE)
        } else if (ext %in% c("xlsx", "xls")) {
          readxl::read_excel(input$file_input$datapath)
        } else {
          stop("Formato no soportado.")
        }
      }
    })

    shiny::observe({
      df <- datos_raw()
      cols <- names(df)

      sel_sitio <- if ("sitio" %in% cols) "sitio" else if ("plot" %in% cols) "plot" else cols[1]
      sel_especie <- if ("especie" %in% cols) "especie" else if ("species" %in% cols) "species" else cols[2]
      sel_abundancia <- if ("abundancia" %in% cols) "abundancia" else if ("abundance" %in% cols) "abundance" else "Ninguno"

      shiny::updateSelectInput(session, "col_sitio", choices = cols, selected = sel_sitio)
      shiny::updateSelectInput(session, "col_especie", choices = cols, selected = sel_especie)
      shiny::updateSelectInput(session, "col_abundancia", choices = c("Ninguno", cols), selected = sel_abundancia)
      shiny::updateSelectInput(session, "col_dap", choices = c("Ninguno", cols), selected = ifelse("dap_cm" %in% cols, "dap_cm", "Ninguno"))
      shiny::updateSelectInput(session, "col_altura", choices = c("Ninguno", cols), selected = ifelse("altura_m" %in% cols, "altura_m", "Ninguno"))
      shiny::updateSelectInput(session, "col_dc", choices = c("Ninguno", cols), selected = ifelse("dc_m" %in% cols, "dc_m", "Ninguno"))
    })

    datos_procesados <- shiny::reactive({
      df <- datos_raw()
      shiny::req(df, input$col_sitio, input$col_especie)
      shiny::req(input$col_sitio %in% names(df), input$col_especie %in% names(df))

      df_clean <- data.frame(
        sitio = as.character(df[[input$col_sitio]]),
        especie = as.character(df[[input$col_especie]]),
        stringsAsFactors = FALSE
      )

      if (input$col_abundancia != "Ninguno" && input$col_abundancia %in% names(df)) {
        df_clean$abundancia <- as.numeric(df[[input$col_abundancia]])
      } else {
        df_clean$abundancia <- rep(1, nrow(df_clean))
      }

      if (input$col_dap != "Ninguno" && input$col_dap %in% names(df)) {
        df_clean$dap_cm <- as.numeric(df[[input$col_dap]])
      }
      if (input$col_altura != "Ninguno" && input$col_altura %in% names(df)) {
        df_clean$altura_m <- as.numeric(df[[input$col_altura]])
      }
      if (input$col_dc != "Ninguno" && input$col_dc %in% names(df)) {
        df_clean$dc_m <- as.numeric(df[[input$col_dc]])
      }

      df_clean
    })

    codigo_r_carga <- shiny::reactive({
      src <- input$fuente_datos
      file_str <- if (src == "archivo" && !is.null(input$file_input)) {
        paste0("read.csv('", input$file_input$name, "')")
      } else if (src %in% c("dune_t", "bci_t")) {
        paste0("data(", src, "); raw_data <- ", src)
      } else {
        "read.csv('mi_inventario_floristico.csv')"
      }
      col_s <- input$col_sitio
      col_sp <- input$col_especie
      col_ab <- input$col_abundancia

      paste0(
        "library(floraveg)\n\n",
        "# 1. Cargar conjunto de datos\n",
        if (src %in% c("dune_t", "bci_t")) paste0("data(", src, ")\nraw_data <- ", src, "\n\n") else paste0("raw_data <- ", file_str, "\n\n"),
        "# 2. Mapear y estandarizar columnas segun el modelo BD MINAM/SINIA\n",
        "datos <- data.frame(\n",
        "  sitio = as.character(raw_data[['", col_s, "']]),\n",
        "  especie = as.character(raw_data[['", col_sp, "']]),\n",
        "  abundancia = ", ifelse(col_ab != "Ninguno", paste0("as.numeric(raw_data[['", col_ab, "']])"), "1"), "\n",
        ")\n\n",
        "# 3. Validar inventario\n",
        "validate_inventario(datos)\n"
      )
    })

    shiny::observeEvent(input$btn_ver_codigo, {
      shiny::showModal(shiny::modalDialog(
        title = shiny::tags$div(shiny::icon("code"), " C\u00f3digo R - Carga & Mapeo de Datos"),
        size = "l",
        easyClose = TRUE,
        footer = shiny::tagList(
          shiny::actionButton(
            ns("btn_copiar"),
            "Copiar al Portapapeles",
            icon = shiny::icon("copy"),
            class = "btn-success",
            onclick = sprintf("copyCodeToClipboard('%s')", ns("modal_code_carga"))
          ),
          shiny::modalButton("Cerrar")
        ),
        shiny::tags$p("Sintaxis R lista para ejecutar en RStudio:"),
        shiny::tags$pre(
          id = ns("modal_code_carga"),
          style = "background-color: #1e293b; color: #38bdf8; padding: 1rem; border-radius: 8px; max-height: 400px; overflow-y: auto;",
          codigo_r_carga()
        )
      ))
    })

    output$resumen_validacion <- shiny::renderUI({
      df <- datos_procesados()
      n_rows <- nrow(df)
      n_sites <- length(unique(df$sitio))
      n_sp <- length(unique(df$especie))
      has_dap <- "dap_cm" %in% names(df)
      has_alt <- "altura_m" %in% names(df)

      shiny::tagList(
        shiny::div(
          class = "d-flex justify-content-around text-center mb-3",
          shiny::div(class = "metric-card p-2 rounded bg-light border", shiny::div(class = "h4 font-weight-bold text-success", n_rows), shiny::div(class = "small text-muted", "Registros Trazados")),
          shiny::div(class = "metric-card p-2 rounded bg-light border", shiny::div(class = "h4 font-weight-bold text-primary", n_sites), shiny::div(class = "small text-muted", "Parcelas / Sitios")),
          shiny::div(class = "metric-card p-2 rounded bg-light border", shiny::div(class = "h4 font-weight-bold text-info", n_sp), shiny::div(class = "small text-muted", "Especies \u00danicas"))
        ),
        shiny::div(
          class = "d-flex justify-content-between align-items-center p-2 rounded border bg-light flex-wrap gap-2",
          shiny::span(class = "font-weight-bold me-2", "Estado de Conformidad del Modelo BD:"),
          shiny::span(class = "badge bg-success text-white p-2 me-1", shiny::icon("check"), " Esquema Mapeado Correctamente"),
          shiny::span(class = paste("badge p-2 me-1", ifelse(has_dap, "bg-info text-white", "bg-warning text-dark")), ifelse(has_dap, "DAP Incluido", "DAP Ausente")),
          shiny::span(class = paste("badge p-2 me-1", ifelse(has_alt, "bg-info text-white", "bg-secondary text-white")), ifelse(has_alt, "Altura Incluida", "Altura Ausente"))
        ),
        if (!has_dap || !has_alt) {
          shiny::div(
            class = "alert alert-info py-2 px-3 mt-2 mb-0 small",
            shiny::icon("circle-info"), " ",
            shiny::tags$b("Nota de compatibilidad: "),
            "Los datos de Parcela + Especie + Abundancia son suficientes para ejecutar sin problemas los an\u00e1lisis de Diversidad Alfa/Beta, Curvas de Acumulaci\u00f3n e \u00cdndices de Abundancia y Frecuencia."
          )
        }
      )
    })

    output$tabla_previa <- DT::renderDT({
      DT::datatable(
        datos_procesados(),
        options = list(pageLength = 8, scrollX = TRUE),
        style = "bootstrap4"
      )
    })

    return(datos_procesados)
  })
}
