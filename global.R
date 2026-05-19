# global.R

# ── Fix Windows: rutas temporales con espacios en el nombre de usuario ────────
if (.Platform$OS.type == "windows") {
  tmp_dir <- "C:/Temp/RShiny"
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
  Sys.setenv(TMPDIR = tmp_dir, TMP = tmp_dir, TEMP = tmp_dir)
}
# Silenciar warnings informativos de p-value en ADF/KPSS
options(warn = -1)

library(shiny)
library(shinyWidgets)
library(plotly)
library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)
library(readxl)
library(DT)
library(ggcorrplot)
library(tseries)
library(zoo)
library(forecast)

source("modules/mod_introduccion.R")
source("modules/mod_contexto.R")
source("modules/mod_problema.R")
source("modules/mod_objetivos.R")
source("modules/mod_marco_teorico.R")
source("modules/mod_metodologia.R")
source("modules/mod_resultados.R")
source("modules/mod_arima.R")
source("modules/mod_rolling.R")
source("modules/mod_conclusiones.R")

datos_raw <- read_excel("data/tasas_interes.xlsx",
                        sheet = "Series de datos", skip = 5,
                        col_names = c("Fecha","Consumo","Tesoreria","Ordinarios",
                                      "Preferenciales","BancoRepublica","SinTesoreria","Total"))
datos <- datos_raw %>%
  mutate(
    Fecha = as.Date(suppressWarnings(as.numeric(Fecha)),
                    origin = "1899-12-30")
  ) %>%
  filter(!is.na(Fecha), !is.na(Total)) %>%
  mutate(across(c(Consumo,Tesoreria,Ordinarios,Preferenciales,
                  BancoRepublica,SinTesoreria,Total), as.numeric)) %>%
  filter(!is.na(Total)) %>%
  arrange(Fecha)

COLORES_SERIES <- c(
  "Consumo"        = "#5B8DB8",
  "Tesoreria"      = "#E07B5D",
  "Ordinarios"     = "#6BAF92",
  "Preferenciales" = "#C97FBE",
  "BancoRepublica" = "#E8B84B",
  "SinTesoreria"   = "#7D9EC0",
  "Total"          = "#fcd34d"
)

# ── Reemplazo de box() de shinydashboard ─────────────────────
# Permite usar box() sin cargar shinydashboard
box <- function(..., width = 12, title = NULL, solidHeader = FALSE,
                status = NULL, collapsible = FALSE, collapsed = FALSE,
                height = NULL, footer = NULL, background = NULL) {
  content <- list(...)
  
  header <- if (!is.null(title)) {
    tags$div(class = "box-header",
      tags$h3(class = "box-title", title)
    )
  }
  
  body <- tags$div(class = "box-body", content)
  foot <- if (!is.null(footer)) tags$div(class = "box-footer", footer)
  
  col_class <- if (!is.null(width)) paste0("col-sm-", width) else "col-sm-12"
  
  tags$div(
    class = col_class,
    tags$div(
      class = "box",
      style = if (!is.null(height)) paste0("height:", height) else NULL,
      header,
      body,
      foot
    )
  )
}

# valueBox sin shinydashboard
valueBox <- function(value, subtitle, icon = NULL, color = "blue", width = 4, href = NULL) {
  col_class <- paste0("col-sm-", width)
  tags$div(class = col_class,
    tags$div(class = "value-box",
      style = "display:flex; align-items:stretch; min-height:80px; border-radius:10px; overflow:hidden;",
      if (!is.null(icon)) tags$div(class = "value-box-icon",
        style = "width:80px; display:flex; align-items:center; justify-content:center; font-size:28px;",
        icon),
      tags$div(class = "value-box-content",
        style = "padding:14px 16px; flex:1;",
        tags$p(class = "value-box-number", style = "margin:0 0 4px;", value),
        tags$p(class = "value-box-text",   style = "margin:0;", subtitle)
      )
    )
  )
}

tabItems <- function(...) tags$div(class = "tab-items", ...)
tabItem  <- function(tabName, ...) tags$div(id = tabName, ...)

# ── Precalculo de modelos ARIMA (una sola vez al iniciar) ─────
# Evita que el servidor recalcule en cada sesion
message("Precalculando modelos ARIMA...")

serie_global    <- datos$Total[!is.na(datos$Total)]
fechas_global   <- datos$Fecha[!is.na(datos$Total)]
n_global        <- length(serie_global)
n_train_global  <- floor(n_global * 0.8)

train_global    <- serie_global[1:n_train_global]
test_global     <- serie_global[(n_train_global + 1):n_global]
fechas_tr_global <- fechas_global[1:n_train_global]
fechas_te_global <- fechas_global[(n_train_global + 1):n_global]

modelo_110_global <- suppressWarnings(arima(train_global, order = c(1, 1, 0)))
modelo_011_global <- suppressWarnings(arima(train_global, order = c(0, 1, 1)))
modelo_013_global <- suppressWarnings(arima(train_global, order = c(0, 1, 3)))

# Grid search precalculado
grid_global <- local({
  candidatos <- list(c(1,1,0), c(0,1,1), c(0,1,3),
                     c(1,1,1), c(2,1,0), c(0,1,2))
  resultados <- lapply(candidatos, function(ord) {
    tryCatch({
      m <- suppressWarnings(arima(train_global, order = ord))
      data.frame(
        Orden = paste0("ARIMA(", paste(ord, collapse=","), ")"),
        AIC   = round(AIC(m), 2),
        BIC   = round(BIC(m), 2)
      )
    }, error = function(e) NULL)
  })
  do.call(rbind, Filter(Negate(is.null), resultados)) %>% arrange(AIC)
})

message("Modelos ARIMA listos.")
