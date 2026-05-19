# ui.R — Navbar horizontal + tema Obsidian Gold

navbarPage(
  title = tags$span(
    style = "color:#fcd34d; font-weight:700; font-size:14px; letter-spacing:0.5px;",
    "Tasas de Interes — Colombia"
  ),
  id = "navbar",
  collapsible = TRUE,
  windowTitle = "Tasas Colombia",
  header = tags$head(
    # Fondo negro ANTES de que cargue Bootstrap
    tags$style(HTML("
      html,body{background:#0c0a09!important;color:#f0ebe0!important;}
      .container-fluid,.tab-content,.tab-pane{background:#0c0a09!important;}
    ")),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1.0"),
    tags$link(rel = "stylesheet", type = "text/css", href = "poppins.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
      tags$script(src = "fix_dropdown.js"),
    tags$style(HTML("
      .shiny-spinner-output-container > .load-container.load1 > .loader {
        border: 3px solid rgba(245,158,11,0.15) !important;
        border-top-color: #f59e0b !important;
        width: 36px !important; height: 36px !important;
      }
      .shiny-spinner-output-container .load-container {
        background: rgba(12,10,9,0.9) !important;
        border-radius: 8px !important;
      }
      #shiny-notification-panel { background: #1a1714 !important; }
      .shiny-progress-container .shiny-progress .progress-bar {
        background: linear-gradient(90deg, #d97706, #fcd34d) !important;
      }
    ")),
    # Barra de filtro global
    tags$div(
      id = "global-filter-bar",
      style = paste0(
        "background:#1a1714; border-bottom:1px solid rgba(245,158,11,0.2);",
        "padding:6px 24px; display:flex; align-items:center; gap:16px;"
      ),
      tags$span(
        style = "color:#a89472; font-size:11px; font-weight:600; letter-spacing:0.6px; white-space:nowrap;",
        "PERIODO:"
      ),
      tags$div(
        style = "flex:1; max-width:420px;",
        shiny::sliderInput("fecha_global", label = NULL,
                    min        = as.Date("1998-04-01"),
                    max        = as.Date("2025-08-01"),
                    value      = c(as.Date("1998-04-01"), as.Date("2025-08-01")),
                    timeFormat = "%Y", step = 90, width = "100%")
      ),
      tags$span(
        style = "color:#5c5040; font-size:10.5px;",
        "Filtra todos los graficos del app"
      )
    )
  ),

  tabPanel("Introduccion",   mod_introduccion_ui("introduccion")),
  tabPanel("Contexto",       mod_contexto_ui("contexto")),
  tabPanel("Problema",       mod_problema_ui("problema")),
  tabPanel("Objetivos",      mod_objetivos_ui("objetivos")),
  tabPanel("Marco Teorico",  mod_marco_teorico_ui("marco_teorico")),
  tabPanel("Metodologia",    mod_metodologia_ui("metodologia")),
  tabPanel("Resultados EDA", mod_resultados_ui("resultados")),
  tabPanel("ARIMA",          mod_arima_ui("arima")),
  tabPanel("Rolling",        mod_rolling_ui("rolling")),
  tabPanel("Conclusiones",   mod_conclusiones_ui("conclusiones"))
)
