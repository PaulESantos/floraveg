# UI para la aplicación Shiny de floraveg (Navegación Horizontal + Pestaña / Botón Terminar Sesión)
ui <- page_fluid(
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#1b4d3e",
    secondary = "#2d6a4f"
  ),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$script(src = "copy_code.js"),
    tags$style(HTML("
      .card-header-tabs .nav-link {
        font-weight: 500;
        color: #2d6a4f;
        padding: 10px 14px;
      }
      .card-header-tabs .nav-link.active {
        background-color: #1b4d3e !important;
        color: #ffffff !important;
        font-weight: bold;
        border-radius: 6px 6px 0 0;
      }
    "))
  ),
  # Header Bar Superior Principal
  div(
    class = "navbar navbar-expand-lg navbar-dark bg-dark px-4 py-2 mb-3 shadow-sm d-flex justify-content-between align-items-center",
    div(
      class = "d-flex align-items-center",
      img(src = "logo.png", height = "32px", class = "me-2", error = "this.style.display='none'"),
      span(class = "navbar-brand font-weight-bold text-white mb-0 h4", "floraveg: Evaluador de Flora y Vegetación")
    ),
    div(
      class = "d-flex align-items-center gap-2",
      #span(class = "badge bg-success text-white px-3 py-2 me-2", icon("leaf"), " Guía MINAM 2015"),
      actionButton("btn_salir_app", "Terminar Sesión", icon = icon("power-off"), class = "btn-danger btn-sm font-weight-bold")
    )
  ),
  # Navegación Horizontal de Módulos directamente bajo la barra superior
  navset_card_tab(
    id = "main_nav",
    title = span(class = "text-success font-weight-bold me-2", icon("layer-group"), " Módulos de Análisis:"),
    nav_panel("1. Esquema & Modelo BD", icon = icon("sitemap"), mod_modelo_datos_ui("modelo_datos")),
    nav_panel("2. Carga & Mapeo de Datos", icon = icon("file-import"), mod_carga_datos_ui("carga")),
    nav_panel("3. Diversidad Alfa & Beta", icon = icon("leaf"), mod_diversidad_ui("diversidad")),
    nav_panel("4. Estructura & DAP", icon = icon("tree"), mod_estructura_ui("estructura")),
    nav_panel("5. Biomasa & Volumen", icon = icon("weight-hanging"), mod_biomasa_volumen_ui("biomasa")),
    nav_panel("6. IVI (Importancia Ecológica)", icon = icon("chart-pie"), mod_ivi_ui("ivi")),
    nav_panel("7. Reporte Técnico & Código R", icon = icon("file-pdf"), mod_reporte_ui("reporte"))
  )
)
