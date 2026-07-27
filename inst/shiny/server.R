# Lógica del servidor para la aplicación Shiny de floraveg
server <- function(input, output, session) {
  # Módulo 1: Modelo de Datos BD
  mod_modelo_datos_server("modelo_datos")

  # Módulo 2: Carga y validación
  datos_reactivos <- mod_carga_datos_server("carga")

  # Módulo 3: Diversidad (Ejecutable de forma independiente)
  mod_diversidad_server("diversidad", datos_reactivos)

  # Módulo 4: Estructura (Ejecutable de forma independiente)
  mod_estructura_server("estructura", datos_reactivos)

  # Módulo 5: Biomasa y Volumen (Ejecutable de forma independiente)
  mod_biomasa_volumen_server("biomasa", datos_reactivos)

  # Módulo 6: IVI (Ejecutable de forma independiente)
  mod_ivi_server("ivi", datos_reactivos)

  # Módulo 7: Reportes Técnicos & Código R Reproducible
  mod_reporte_server("reporte", datos_reactivos)

  # Modal de confirmación para terminar sesión (desde el botón del header superior)
  observeEvent(input$btn_salir_app, {
    showModal(modalDialog(
      title = tags$div(class = "text-danger font-weight-bold", icon("triangle-exclamation"), " Confirmar Cierre de Sesión"),
      tags$p("¿Está seguro de que desea finalizar la sesión del evaluador floraveg y cerrar la aplicación?"),
      tags$p(class = "text-muted small", "Esta acción detendrá el servidor local R Shiny."),
      size = "m",
      easyClose = TRUE,
      footer = tagList(
        modalButton("Cancelar"),
        actionButton("btn_confirmar_salir", "Sí, Terminar Sesión", class = "btn-danger font-weight-bold", icon = icon("power-off"))
      )
    ))
  })

  # Detener la aplicación Shiny
  observeEvent(input$btn_confirmar_salir, {
    removeModal()
    showNotification("Finalizando sesión de floraveg...", type = "warning", duration = 2)
    shiny::stopApp()
  })
}
