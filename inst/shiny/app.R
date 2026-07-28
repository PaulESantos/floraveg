# Entry point universal para Shiny Server, shinyapps.io y ejecucion local
source("global.R", local = TRUE)
source("ui.R", local = TRUE)
source("server.R", local = TRUE)

shinyApp(ui = ui, server = server)
