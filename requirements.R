# requirements.R — sin shinydashboard
paquetes <- c(
  "shiny", "shinyWidgets",
  "plotly", "ggplot2", "dplyr", "tidyr",
  "lubridate", "readxl", "DT",
  "ggcorrplot", "tseries", "zoo", "forecast"
)
instalar_si_falta <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE))
    install.packages(pkg, dependencies = TRUE)
}
invisible(lapply(paquetes, instalar_si_falta))
message("Todos los paquetes instalados correctamente.")
