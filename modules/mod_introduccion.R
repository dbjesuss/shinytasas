# modules/mod_introduccion.R

mod_introduccion_ui <- function(id) {
  ns <- NS(id)
  fluidPage(

    # ── KPI cards dinámicas (punto 1) ─────────────────────────────────────────
    fluidRow(
      column(12,
        tags$p(style = "color:#888; font-size:11px; margin-bottom:4px; letter-spacing:0.4px;",
               "INDICADORES — período seleccionado")
      )
    ),
    fluidRow(
      # Tasa actual
      column(3,
        tags$div(class = "kpi-card",
          tags$div(class = "kpi-label", "Tasa Total — último mes"),
          tags$div(class = "kpi-value", uiOutput(ns("kpi_actual"))),
          tags$div(class = "kpi-delta", uiOutput(ns("kpi_delta_mes")))
        )
      ),
      # Cambio anual
      column(3,
        tags$div(class = "kpi-card",
          tags$div(class = "kpi-label", "Cambio vs. año anterior"),
          tags$div(class = "kpi-value", uiOutput(ns("kpi_delta_anio"))),
          tags$div(class = "kpi-delta", uiOutput(ns("kpi_anio_label")))
        )
      ),
      # Media del período
      column(3,
        tags$div(class = "kpi-card",
          tags$div(class = "kpi-label", "Media del período"),
          tags$div(class = "kpi-value", uiOutput(ns("kpi_media"))),
          tags$div(class = "kpi-delta", style = "color:#999;",
                   uiOutput(ns("kpi_rango_label")))
        )
      ),
      # Observaciones
      column(3,
        tags$div(class = "kpi-card",
          tags$div(class = "kpi-label", "Observaciones"),
          tags$div(class = "kpi-value", uiOutput(ns("kpi_obs"))),
          tags$div(class = "kpi-delta", style = "color:#999;", uiOutput(ns("kpi_obs_label")))
        )
      )
    ),

    br(),

    # ── Gauge + descripción (punto 5) ─────────────────────────────────────────
    fluidRow(
      column(5,
        box(width = 12, solidHeader = TRUE,
            title = "Tasa actual vs. promedio histórico",
          plotlyOutput(ns("gauge_tasa"), height = "280px"),
          uiOutput(ns("gauge_interpretacion"))
        )
      ),
      column(7,
        box(width = 12, solidHeader = TRUE,
            title = "¿Qué son las tasas de interés de colocación?",
          p("Las ", strong("tasas de interés de colocación"), " son las tasas que los bancos
            comerciales cobran a sus clientes por los créditos que otorgan. Reflejan el costo
            del crédito en la economía y son uno de los principales indicadores del sistema
            financiero colombiano."),
          p("El Banco de la República publica mensualmente estas tasas desagregadas
            por tipo de crédito, permitiendo analizar la evolución del mercado crediticio
            desde abril de 1998 hasta la actualidad."),
          hr(),
          tags$ul(
            tags$li(strong("Créditos de consumo:"), " financiamiento de bienes y servicios para hogares."),
            tags$li(strong("Créditos de tesorería:"), " créditos de muy corto plazo para empresas."),
            tags$li(strong("Créditos ordinarios:"), " créditos comerciales estándar."),
            tags$li(strong("Créditos preferenciales:"), " créditos para empresas de alta solvencia."),
            tags$li(strong("Tasa Banco de la República:"), " tasa de referencia de política monetaria."),
            tags$li(strong("Tasa sin tesorería:"), " promedio excluyendo créditos de tesorería."),
            tags$li(strong("Tasa total:"), " promedio ponderado de todas las modalidades.")
          )
        )
      )
    )
  )
}

mod_introduccion_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {

    # datos es un reactive
    df <- reactive({ datos() })

    # ── KPI: tasa actual ──────────────────────────────────────────────────────
    output$kpi_actual <- renderUI({
      d  <- df()
      v  <- tail(d$Total, 1)
      tags$span(style = "font-size:32px; font-weight:700; color:#f0ebe0;",
                paste0(format(round(v, 2), nsmall=2), "%"))
    })

    output$kpi_delta_mes <- renderUI({
      d  <- df()
      if (nrow(d) < 2) return(tags$span("—"))
      actual   <- tail(d$Total, 1)
      anterior <- tail(d$Total, 2)[1]
      delta    <- actual - anterior
      color    <- if (delta > 0) "#c0392b" else "#27ae60"
      flecha   <- if (delta > 0) "▲" else "▼"
      tags$span(style = paste0("color:", color, "; font-size:13px; font-weight:600;"),
                paste0(flecha, " ", format(abs(round(delta, 2)), nsmall=2), " pp vs mes anterior"))
    })

    # ── KPI: cambio anual ─────────────────────────────────────────────────────
    output$kpi_delta_anio <- renderUI({
      d <- df()
      if (nrow(d) < 13) return(tags$span("—", style="font-size:32px; font-weight:700; color:#f0ebe0;"))
      actual   <- tail(d$Total, 1)
      hace_12  <- tail(d$Total, 13)[1]
      delta    <- actual - hace_12
      color    <- if (delta > 0) "#c0392b" else "#27ae60"
      flecha   <- if (delta > 0) "▲" else "▼"
      tags$span(style = paste0("font-size:32px; font-weight:700; color:", color, ";"),
                paste0(flecha, " ", format(abs(round(delta, 2)), nsmall=2), " pp"))
    })

    output$kpi_anio_label <- renderUI({
      d <- df()
      if (nrow(d) < 13) return(NULL)
      fecha_ref <- tail(d$Fecha, 13)[1]
      tags$span(style="color:#999; font-size:12px;",
                paste0("vs. ", format(fecha_ref, "%b %Y")))
    })

    # ── KPI: media del período ────────────────────────────────────────────────
    output$kpi_media <- renderUI({
      m <- mean(df()$Total, na.rm = TRUE)
      tags$span(style = "font-size:32px; font-weight:700; color:#f0ebe0;",
                paste0(format(round(m, 2), nsmall=2), "%"))
    })

    output$kpi_rango_label <- renderUI({
      d <- df()
      tags$span(style="color:#999; font-size:12px;",
                paste0(format(min(d$Fecha), "%Y"), " – ", format(max(d$Fecha), "%Y")))
    })

    # ── KPI: observaciones ────────────────────────────────────────────────────
    output$kpi_obs <- renderUI({
      n <- nrow(df())
      tags$span(style = "font-size:32px; font-weight:700; color:#f0ebe0;", n)
    })

    output$kpi_obs_label <- renderUI({
      d <- df()
      tags$span(style="color:#999; font-size:12px;",
                paste0("meses — ",
                       format(min(d$Fecha), "%b %Y"), " a ",
                       format(max(d$Fecha), "%b %Y")))
    })

    # ── Gauge tasa actual vs promedio (punto 5) ───────────────────────────────
    output$gauge_tasa <- renderPlotly({
      d        <- df()
      actual   <- round(tail(d$Total, 1), 2)
      hist_min <- round(min(d$Total, na.rm=TRUE), 1)
      hist_max <- round(max(d$Total, na.rm=TRUE), 1)
      hist_med <- round(mean(d$Total, na.rm=TRUE), 2)

      plot_ly(
        type  = "indicator",
        mode  = "gauge+number+delta",
        value = actual,
        delta = list(
          reference  = hist_med,
          increasing = list(color = "#ef4444"),
          decreasing = list(color = "#22c55e"),
          valueformat = ".2f",
          suffix = " pp"
        ),
        number = list(suffix = "%", font = list(size = 36, color = "#f0ebe0")),
        gauge  = list(
          axis  = list(range    = list(hist_min - 1, hist_max + 1),
                       ticksuffix = "%",
                       tickfont   = list(size = 10)),
          bar   = list(color = "#f59e0b", thickness = 0.3),
          bgcolor = "white",
          borderwidth = 0,
          steps = list(
            list(range = c(hist_min - 1, hist_med * 0.8),  color = "rgba(34,197,94,0.15)"),
            list(range = c(hist_med * 0.8, hist_med * 1.2), color = "#fff8e7"),
            list(range = c(hist_med * 1.2, hist_max + 1),  color = "rgba(239,68,68,0.15)")
          ),
          threshold = list(
            line  = list(color = "#a89472", width = 2),
            thickness = 0.8,
            value = hist_med
          )
        )
      ) %>%
        layout(
          margin = list(l=20, r=20, t=40, b=10),
          paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"),
          font = list(family = "Inter, sans-serif")
        )
    })

    output$gauge_interpretacion <- renderUI({
      d      <- df()
      actual <- tail(d$Total, 1)
      media  <- mean(d$Total, na.rm=TRUE)
      diff   <- actual - media
      if (abs(diff) < 0.5) {
        msg   <- paste0("La tasa actual (", round(actual,2), "%) está cercana al promedio histórico (",
                        round(media,2), "%) del período seleccionado.")
        color <- "#555"
      } else if (diff > 0) {
        msg   <- paste0("La tasa actual (", round(actual,2), "%) está ", round(diff,2),
                        " pp POR ENCIMA del promedio histórico (", round(media,2), "%).")
        color <- "#c0392b"
      } else {
        msg   <- paste0("La tasa actual (", round(actual,2), "%) está ", round(abs(diff),2),
                        " pp POR DEBAJO del promedio histórico (", round(media,2), "%).")
        color <- "#27ae60"
      }
      tags$p(style = paste0("font-size:12px; color:", color, "; margin:6px 4px 0 4px;
                              text-align:center; font-weight:500;"), msg)
    })

  })
}
