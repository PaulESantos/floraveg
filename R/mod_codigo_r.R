# M\u00f3dulo Shiny: Generador & Visor de C\u00f3digo R Reproducible (ggplot2)
mod_codigo_r_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      class = "card p-4 mb-4 shadow-sm border-0",
      style = "border-left: 5px solid #2d6a4f !important;",
      shiny::h3(class = "text-success font-weight-bold mb-2", shiny::icon("code"), " Recuperador de C\u00f3digo R Reproducible (Script Din\u00e1mico)"),
      shiny::p(class = "text-muted lead mb-0",
        "Obt\u00e9n la sintaxis R ejecutable y reactiva para reproducir exactamente de forma transparente los an\u00e1lisis y gr\u00e1ficos generados con su inventario activo."
      )
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-dark text-white mb-3", shiny::icon("sliders"), " Configuraci\u00f3n del Script"),
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shiny::selectInput(
            ns("sel_modulo_codigo"),
            "Seleccionar An\u00e1lisis:",
            choices = c(
              "Script Completo Integrado" = "completo",
              "1. Carga & Estructuraci\u00f3n de Datos" = "carga",
              "2. Diversidad Alfa, Beta & Rarefacci\u00f3n (iNEXT)" = "diversidad",
              "3. Estructura & Dasometr\u00eda (ggplot2)" = "estructura",
              "4. \u00c1rea Basal, Volumen & Biomasa (ggplot2)" = "biomasa",
              "5. \u00cdndice de Valor de Importancia - IVI (ggplot2)" = "ivi"
            ),
            selected = "completo"
          )
        ),
        shiny::column(
          width = 3,
          shiny::actionButton(
            ns("btn_copiar_codigo"),
            "Copiar al Portapapeles",
            icon = shiny::icon("copy"),
            class = "btn-primary w-100 mt-4 font-weight-bold",
            onclick = sprintf("copyCodeToClipboard('%s')", ns("codigo_r_viewer"))
          )
        ),
        shiny::column(
          width = 3,
          shiny::downloadButton(ns("btn_download_code"), "Descargar Script R (.R)", class = "btn-success w-100 mt-4", icon = shiny::icon("download"))
        )
      )
    ),
    shiny::div(
      class = "card p-3 mb-4 shadow-sm",
      shiny::h4(class = "card-header bg-primary text-white mb-3 d-flex justify-content-between align-items-center",
         shiny::span(shiny::icon("terminal"), " Sintaxis R Generada (Reactiva a su Inventario Activo)"),
         shiny::span(class = "badge badge-light text-dark", "R Base / ggplot2 / floraveg / iNEXT")
      ),
      shiny::verbatimTextOutput(ns("codigo_r_viewer")),
      shiny::div(
        class = "text-muted small mt-2",
        shiny::icon("lightbulb"), " Tip: Este c\u00f3digo R est\u00e1 listo para ser copiado o descargado y ejecutado directamente en RStudio."
      )
    )
  )
}

mod_codigo_r_server <- function(id, datos_reactive = NULL) {
  shiny::moduleServer(id, function(input, output, session) {

    datos_script <- shiny::reactive({
      if (is.null(datos_reactive)) {
        obtener_datos_ejemplo()
      } else {
        shiny::req(datos_reactive())
        standardize_inventory(datos_reactive())
      }
    })

    generar_script_r <- shiny::reactive({
      mod <- input$sel_modulo_codigo
      df <- datos_script()

      n_rows <- nrow(df)
      n_sites <- length(unique(df$sitio))
      n_sp <- length(unique(df$especie))
      has_dap <- "dap_cm" %in% names(df)
      has_alt <- "altura_m" %in% names(df)

      header <- paste0(
        "# ==========================================================================\n",
        "# Script Reproducible de Analisis de Flora y Vegetacion (floraveg)\n",
        "# Generado dinamicamente para el inventario activo (", n_rows, " registros, ", n_sites, " parcelas, ", n_sp, " especies)\n",
        "# Fecha: ", Sys.Date(), "\n",
        "# ==========================================================================\n\n",
        "# 1. Cargar paquetes requeridos\n",
        "library(floraveg)\n",
        "library(ggplot2)\n",
        "library(iNEXT)\n\n"
      )

      code_carga <- paste0(
        "# --- 1. Carga, Estandarizacion y Validacion de Datos ---\n",
        "# Cargar datos del inventario (reemplazar la ruta por tu archivo local .csv/.xlsx si corresponde)\n",
        "datos <- data.frame(\n",
        "  sitio = c(", paste(utils::head(paste0("'", df$sitio, "'"), 8), collapse = ", "), ", ...),\n",
        "  especie = c(", paste(utils::head(paste0("'", df$especie, "'"), 8), collapse = ", "), ", ...),\n",
        "  abundancia = c(", paste(utils::head(df$abundancia, 8), collapse = ", "), ", ...)",
        if (has_dap) paste0(",\n  dap_cm = c(", paste(utils::head(df$dap_cm, 8), collapse = ", "), ", ...)") else "",
        if (has_alt) paste0(",\n  altura_m = c(", paste(utils::head(df$altura_m, 8), collapse = ", "), ", ...)") else "",
        "\n)\n\n",
        "# Estandarizar y validar consistencia del esquema BD\n",
        "datos <- standardize_inventory(datos)\n",
        "validate_inventario(datos)\n\n"
      )

      code_div <- paste0(
        "# --- 2. Analisis de Diversidad Alfa, Beta y Rarefaccion ---\n",
        "# Diversidad Alfa completa\n",
        "alfa <- diversidad_alfa(datos, metodos = 'full', base = 2)\n",
        "print(alfa)\n\n",
        "# Similitud Beta en Formato Tidy u Objeto Matriz (Jaccard / Sorensen / Morisita-Horn)\n",
        "beta_tidy <- diversidad_beta(datos, metodo = 'jaccard', formato = 'tidy')\n",
        "print(head(beta_tidy))\n\n",
        "# Curvas de Rarefaccion y Extrapolacion con iNEXT (Hill q = 0, 1, 2)\n",
        "mat_comm <- t(long_to_comm(datos))\n",
        "res_inext <- iNEXT(mat_comm, q = 0, datatype = 'abundance', nboot = 10)\n",
        "ggiNEXT(res_inext, type = 1) + theme_minimal()\n\n"
      )

      code_est <- paste0(
        "# --- 3. Estructura Vegetacional & Distribucion Diametrica ---\n",
        "abund <- abundancia(datos, tipo = 'ambas')\n",
        "frec  <- frecuencia(datos)\n",
        if (has_dap) {
          paste0(
            "dd    <- distribucion_diametrica(datos$dap_cm, ancho_clase = 10)\n",
            "ggplot(dd$tabla_clases, aes(x = Clase, y = frecuencia)) +\n",
            "  geom_col(fill = '#2d6a4f', color = '#1b4d3e') +\n",
            "  theme_minimal() +\n",
            "  labs(title = 'Distribucion Diametrica (J-Invertida)', x = 'Clase DAP (cm)', y = 'Frecuencia')\n\n"
          )
        } else {
          "# Nota: DAP no provisto en el inventario actual.\n\n"
        }
      )

      code_bio <- paste0(
        "# --- 4. Area Basal, Volumen Maderable & Biomasa Aerea ---\n",
        if (has_dap) {
          paste0(
            "datos$ab_m2 <- area_basal(dap_cm = datos$dap_cm, unidad_salida = 'm2')\n",
            if (has_alt) {
              paste0(
                "datos$vol_m3 <- volumen_maderable(datos$ab_m2, datos$altura_m, factor_forma = 0.70)\n",
                "datos$densidad <- obtener_densidad_madera(datos$especie, default = 0.60)\n",
                "datos$biomasa_t <- biomasa_aerea(densidad_madera = datos$densidad, volumen_m3 = datos$vol_m3)\n\n",
                "resumen_bio <- aggregate(cbind(vol_m3, biomasa_t) ~ sitio, data = datos, FUN = sum)\n",
                "print(resumen_bio)\n\n"
              )
            } else {
              "# Nota: Altura no provista. Se calculo Area Basal pero no Volumen ni Biomasa.\n\n"
            }
          )
        } else {
          "# Nota: DAP no provisto. Se requiere DAP para calcular Area Basal, Volumen y Biomasa.\n\n"
        }
      )

      code_ivi <- paste0(
        "# --- 5. Indice de Valor de Importancia (IVI) ---\n",
        "tabla_ivi <- calc_ivi(datos)\n",
        "print(head(tabla_ivi, 10))\n\n"
      )

      out <- header
      if (mod == "completo") {
        out <- paste0(out, code_carga, code_div, code_est, code_bio, code_ivi)
      } else if (mod == "carga") {
        out <- paste0(out, code_carga)
      } else if (mod == "diversidad") {
        out <- paste0(out, code_div)
      } else if (mod == "estructura") {
        out <- paste0(out, code_est)
      } else if (mod == "biomasa") {
        out <- paste0(out, code_bio)
      } else if (mod == "ivi") {
        out <- paste0(out, code_ivi)
      }
      out
    })

    output$codigo_r_viewer <- shiny::renderText({
      generar_script_r()
    })

    output$btn_download_code <- shiny::downloadHandler(
      filename = function() {
        paste0("script_floraveg_", input$sel_modulo_codigo, "_", Sys.Date(), ".R")
      },
      content = function(file) {
        writeLines(generar_script_r(), file)
      }
    )

  })
}
