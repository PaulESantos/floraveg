# M\u00f3dulo Shiny: Modelo de Datos de la Base de Datos de Origen
mod_modelo_datos_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "card p-4 mb-4 shadow-sm border-0",
      style = "border-left: 5px solid #1b4d3e !important;",
      shiny::h3(class = "text-success font-weight-bold mb-2", shiny::icon("database"), " Modelo de Datos de la Base de Datos de Origen"),
      shiny::p(class = "text-muted lead",
        "Estructura estandarizada de la base de datos de origen requerida para los an\u00e1lisis de flora y vegetaci\u00f3n."
      )
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-primary text-white mb-3", shiny::icon("table"), " 1. Diccionario de Campos de la Base de Datos"),
      shiny::p("Especificaci\u00f3n t\u00e9cnica de las columnas esperadas en el inventario flor\u00edstico:"),
      DT::DTOutput(ns("tabla_diccionario"))
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-success text-white mb-3", shiny::icon("diagram-project"), " 2. Esquema, Relaciones & Reglas de Validaci\u00f3n BD"),
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shiny::div(
            class = "p-3 bg-light rounded border h-100",
            shiny::h6(class = "font-weight-bold text-dark mb-2", "Entidades Principales:"),
            shiny::tags$ul(
              shiny::tags$li(shiny::tags$b("Sitio / Parcela: "), "Unidad muestral geogr\u00e1fica o de monitoreo."),
              shiny::tags$li(shiny::tags$b("Tax\u00f3n (Especie): "), "Nombre cient\u00edfico estandarizado (G\u00e9nero + ep\u00edteto)."),
              shiny::tags$li(shiny::tags$b("Medici\u00f3n Dasom\u00e9trica: "), "Atributos f\u00edsicos (DAP, Altura, Di\u00e1metro Copa).")
            )
          )
        ),
        shiny::column(
          width = 6,
          shiny::div(
            class = "alert alert-info h-100, mb-0",
            shiny::h6(class = "alert-heading font-weight-bold", shiny::icon("circle-info"), " Reglas de Validaci\u00f3n BD:"),
            shiny::tags$ul(
              class = "mb-0 pl-3",
              shiny::tags$li("Los campos 'sitio', 'especie' y 'abundancia' son estrictamente OBLIGATORIOS."),
              shiny::tags$li("La abundancia representa el n\u00famero de individuos (\u2265 1) o la presencia (1) / ausencia (0)."),
              shiny::tags$li("Valores de DAP y Altura deben ser estrictamente positivos (> 0)."),
              shiny::tags$li("Los nombres de sitio y especie no deben contener caracteres nulos.")
            )
          )
        )
      )
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-dark text-white mb-3", shiny::icon("check-double"), " 3. Estructura Modelo de Ejemplo en Formato Tabular"),
      shiny::p("Vista previa del esquema relacional integrado para registros flor\u00edsticos de campo:"),
      DT::DTOutput(ns("tabla_ejemplo_modelo"))
    )
  )
}

mod_modelo_datos_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    output$tabla_diccionario <- DT::renderDT({
      dicc <- data.frame(
        Campo = c("sitio", "especie", "abundancia", "dap_cm", "altura_m", "dc_m"),
        Tipo = c("Texto / Factor", "Texto / Factor", "Entero / Num\u00e9rico", "Num\u00e9rico (cm)", "Num\u00e9rico (m)", "Num\u00e9rico (m)"),
        Requerido = c("OBLIGATORIO", "OBLIGATORIO", "OBLIGATORIO", "Recomendado", "Opcional", "Opcional"),
        Descripcion = c(
          "C\u00f3digo o identificador \u00fanico de la parcela, transecto o punto de muestreo.",
          "Nombre cient\u00edfico de la especie vegetal registrada (ej: Cedrela odorata).",
          "N\u00famero de individuos contabilizados o registro de presencia (1) / ausencia (0).",
          "Di\u00e1metro a la altura del pecho medido a 1.30m del suelo (en cent\u00edmetros).",
          "Altura total o maderable del \u00e1rbol/individuo (en metros).",
          "Di\u00e1metro promedio de la copa del individuo (en metros)."
        ),
        stringsAsFactors = FALSE
      )

      dt_obj <- DT::datatable(
        dicc,
        options = list(pageLength = 6, dom = 't', scrollX = TRUE),
        rownames = FALSE,
        style = "bootstrap4"
      )

      DT::formatStyle(
        dt_obj,
        'Requerido',
        target = 'cell',
        backgroundColor = DT::styleEqual(
          c("OBLIGATORIO", "Recomendado", "Opcional"),
          c("#ffcccc", "#fff2cc", "#e6f2ff")
        ),
        fontWeight = 'bold'
      )
    })

    output$tabla_ejemplo_modelo <- DT::renderDT({
      df_modelo <- data.frame(
        sitio = c("Parcela_01", "Parcela_01", "Parcela_02", "Parcela_02", "Parcela_03"),
        especie = c("Cedrela odorata", "Swietenia macrophylla", "Ceiba pentandra", "Inga edulis", "Dipteryx micrantha"),
        abundancia = c(4, 2, 1, 8, 3),
        dap_cm = c(45.2, 62.1, 115.0, 18.4, 85.6),
        altura_m = c(22.5, 28.0, 34.2, 12.0, 26.8),
        dc_m = c(8.5, 11.2, 16.0, 5.4, 10.1),
        stringsAsFactors = FALSE
      )

      DT::datatable(
        df_modelo,
        options = list(pageLength = 5, dom = 't', scrollX = TRUE),
        rownames = FALSE,
        style = "bootstrap4"
      )
    })

  })
}
