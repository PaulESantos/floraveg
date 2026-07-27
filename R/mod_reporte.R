# M\u00f3dulos Shiny: Reportes e Informe T\u00e9cnico L\u00ednea Base MINAM / SINIA (PDF/HTML + C\u00f3digo R Reproducible)
mod_reporte_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "card p-3 mb-4 shadow-sm border-0 bg-light d-flex justify-content-between align-items-center flex-row",
      shiny::div(
        shiny::h4(class = "text-success font-weight-bold mb-0", shiny::icon("file-pdf"), " Reporte T\u00e9cnico & C\u00f3digo R Reproducible"),
        shiny::p(class = "text-muted small mb-0", "Generaci\u00f3n de informe t\u00e9cnico en PDF/HTML y exportaci\u00f3n de scripts R reproducibles.")
      )
    ),
    # 1. Generaci\u00f3n de Informe T\u00e9cnico PDF/HTML (PRIMERO)
    shiny::div(
      class = "card p-4 mb-4 shadow-sm border-0",
      style = "border-top: 4px solid #1b4d3e !important;",
      shiny::h4(class = "text-success font-weight-bold mb-2", shiny::icon("file-pdf"), " 1. Generaci\u00f3n de Informe T\u00e9cnico"),
      shiny::p(class = "text-muted small mb-3",
        "Exporta un informe consolidado con los indicadores de diversidad alfa/beta, m\u00e9tricas de estructura, IVI, volumen y biomasa calculados."
      ),
      shiny::hr(),
      shiny::div(
        class = "d-flex align-items-center gap-3 flex-wrap bg-light p-3 rounded border",
        shiny::div(
          class = "me-3",
          shiny::radioButtons(
            ns("formato_reporte"),
            "Seleccionar formato de exportaci\u00f3n:",
            choices = c(
              "Documento PDF (.pdf)" = "pdf",
              "P\u00e1gina Web HTML (.html)" = "html"
            ),
            selected = "pdf",
            inline = TRUE
          )
        ),
        shiny::downloadButton(ns("btn_download_report"), "Descargar Informe T\u00e9cnico", class = "btn-primary btn-lg font-weight-bold me-2", icon = shiny::icon("download"))
      )
    ),
    # 2. Recuperador de C\u00f3digo R Reproducible (SEGUNDO)
    mod_codigo_r_ui(ns("codigo_r_sub"))
  )
}

mod_reporte_server <- function(id, datos_reactive = NULL) {
  shiny::moduleServer(id, function(input, output, session) {

    # Modulo de Codigo R Reproducible
    mod_codigo_r_server("codigo_r_sub", datos_reactive)

    datos_modulo <- shiny::reactive({
      if (is.null(datos_reactive)) {
        set.seed(42)
        sitios <- paste0("Parcela_", rep(1:4, each = 15))
        data.frame(
          sitio = sitios,
          especie = sample(c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra"), 60, replace = TRUE),
          abundancia = sample(1:15, 60, replace = TRUE),
          dap_cm = round(stats::runif(60, 10, 90), 1),
          altura_m = round(stats::runif(60, 6, 30), 1),
          stringsAsFactors = FALSE
        )
      } else {
        shiny::req(datos_reactive())
        standardize_inventory(datos_reactive())
      }
    })

    output$btn_download_report <- shiny::downloadHandler(
      filename = function() {
        fmt <- ifelse(is.null(input$formato_reporte), "pdf", input$formato_reporte)
        ext <- ifelse(fmt == "pdf", ".pdf", ".html")
        paste0("informe_linea_base_floraveg_", Sys.Date(), ext)
      },
      content = function(file) {
        if (!rmarkdown::pandoc_available()) {
          possible_pandocs <- c(
            "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools",
            "C:/Program Files/RStudio/resources/app/bin/tools",
            "C:/Program Files/Positron/resources/app/quarto/bin/tools",
            file.path(Sys.getenv("LOCALAPPDATA"), "Pandoc")
          )
          for (p in possible_pandocs) {
            if (dir.exists(p)) {
              rmarkdown::find_pandoc(dir = p)
              if (rmarkdown::pandoc_available()) break
            }
          }
        }

        fmt <- ifelse(is.null(input$formato_reporte), "pdf", input$formato_reporte)
        tempReport <- file.path(tempdir(), "informe_floraveg.Rmd")
        reportSrc <- system.file("shiny", "report", "informe_floraveg.Rmd", package = "floraveg")

        if (file.exists(reportSrc)) {
          file.copy(reportSrc, tempReport, overwrite = TRUE)
        } else if (file.exists("inst/shiny/report/informe_floraveg.Rmd")) {
          file.copy("inst/shiny/report/informe_floraveg.Rmd", tempReport, overwrite = TRUE)
        } else {
          rmd_content <- paste0(
            "---\n",
            "title: 'Informe Tecnico de Flora y Vegetacion'\n",
            "output: ", ifelse(fmt == "pdf", "pdf_document", "html_document"), "\n",
            "---\n\n",
            "# 1. Resumen de Inventario\n",
            "Este informe fue generado automaticamente por el sistema **floraveg**.\n"
          )
          writeLines(rmd_content, tempReport)
        }

        df_data <- datos_modulo()
        output_format_str <- ifelse(fmt == "pdf", "pdf_document", "html_document")

        rmarkdown::render(
          tempReport,
          output_file = file,
          output_format = output_format_str,
          params = list(datos = df_data),
          envir = new.env(parent = globalenv())
        )
      }
    )

  })
}
