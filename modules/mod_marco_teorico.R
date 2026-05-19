# modules/mod_marco_teorico.R

mod_marco_teorico_ui <- function(id) {
  ns <- NS(id)
  fluidPage(

    # ── Fila 1: Intro + Tabla ─────────────────────────────────────────────────
    fluidRow(
      column(5,
        box(width = 12, solidHeader = TRUE, title = "Series de tiempo financieras",
          p("Una serie de tiempo es estacionaria cuando su media, varianza y autocovarianza
            son constantes en el tiempo. Esta propiedad es esencial para modelar y pronosticar.
            Se verifican dos pruebas formales con hipótesis opuestas: ", strong("ADF"), " y ",
            strong("KPSS"), ", aplicadas sobre la serie original y la primera diferencia.")
        )
      ),
      column(7,
        box(width = 12, solidHeader = TRUE, title = "Tabla de operacionalización de variables",
          DTOutput(ns("tabla_variables"))
        )
      )
    ),

    # ── Fila 2: Series (grande, cada una full-width) ──────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Serie original — Tasa Total de Colocación",
          plotlyOutput(ns("plot_serie_orig"), height = "300px")
        )
      )
    ),
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Primera diferencia (d = 1)",
          plotlyOutput(ns("plot_serie_diff"), height = "300px")
        )
      )
    ),

    # ── Fila 3: ADF ───────────────────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Test ADF — Augmented Dickey-Fuller",
          p(strong("H\u2080:"), " la serie tiene raíz unitaria (no estacionaria).  ",
            strong("H\u2081:"), " la serie es estacionaria.  Se rechaza H\u2080 si p-valor < 0.05."),
          fluidRow(
            column(6, uiOutput(ns("card_adf_orig"))),
            column(6, uiOutput(ns("card_adf_diff")))
          )
        )
      )
    ),

    # ── Fila 4: KPSS ──────────────────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Test KPSS — Kwiatkowski-Phillips-Schmidt-Shin",
          p(strong("H\u2080:"), " la serie es estacionaria.  ",
            strong("H\u2081:"), " la serie tiene raíz unitaria.  Se rechaza H\u2080 si p-valor < 0.05."),
          fluidRow(
            column(6, uiOutput(ns("card_kpss_orig"))),
            column(6, uiOutput(ns("card_kpss_diff")))
          )
        )
      )
    ),

    # ── Fila 5: Interpretación conjunta ───────────────────────────────────────
    fluidRow(
      column(12, uiOutput(ns("interpretacion_conjunta")))
    ),

    # ── Fila 6: Controles ACF/PACF ────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "ACF y PACF — controles",
          fluidRow(
            column(4,
              tags$div(
                style = "position:relative; z-index:200;",
                tags$div(
                  style = "background:#1a1714; border:1px solid rgba(245,158,11,0.18); border-radius:8px; padding:14px;",
                  selectInput(ns("serie_acf"), "Serie:",
                              choices   = c("Total","Consumo","BancoRepublica",
                                            "Ordinarios","Preferenciales",
                                            "Tesoreria","SinTesoreria"),
                              selected  = "Total",
              )
                )
              )
            ),
            column(4,
              tags$div(
                style = "background:#1a1714; border:1px solid rgba(245,158,11,0.18); border-radius:8px; padding:14px;",
                sliderInput(ns("n_lags"), "Número de rezagos:", min = 6, max = 48, value = 24, step = 1)
              )
            ),
            column(4,
              br(),
              tags$div(style="font-size:12px; color:#a89472; background:#1a1714; padding:10px; border-radius:5px; border:1px solid rgba(245,158,11,0.18);",
                "Las bandas punteadas representan los límites de confianza al 95%.",
                br(), "Barras doradas: autocorrelación significativa."
              )
            )
          )
        )
      )
    ),

    # ── Fila 7: ACF Original (grande) ─────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "ACF — Serie Original",
          plotlyOutput(ns("acf_orig"), height = "320px"),
          tags$div(style="font-size:12px; color:#a89472; margin-top:8px; padding:10px; background:#1a1714; border-radius:5px;",
            strong("Interpretación: "), "Decaimiento lento y gradual → serie no estacionaria.
            Muchas barras significativas fuera de la banda indican alta persistencia temporal."
          )
        )
      )
    ),

    # ── Fila 8: PACF Original (grande) ────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "PACF — Serie Original",
          plotlyOutput(ns("pacf_orig"), height = "320px"),
          tags$div(style="font-size:12px; color:#a89472; margin-top:8px; padding:10px; background:#1a1714; border-radius:5px;",
            strong("Interpretación: "), "Un corte abrupto en rezago p sugiere un proceso AR(p).
            Decaimiento gradual indica presencia de componente MA."
          )
        )
      )
    ),

    # ── Fila 9: ACF Primera Diferencia (grande) ───────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "ACF — Primera Diferencia (\u0394)",
          plotlyOutput(ns("acf_diff"), height = "320px"),
          tags$div(style="font-size:12px; color:#a89472; margin-top:8px; padding:10px; background:#1a1714; border-radius:5px;",
            strong("Interpretación: "), "Al diferenciar, el decaimiento se vuelve rápido si la serie
            se vuelve estacionaria. El número de barras significativas después del corte indica el orden q (MA)."
          )
        )
      )
    ),

    # ── Fila 10: PACF Primera Diferencia (grande) ─────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "PACF — Primera Diferencia (\u0394)",
          plotlyOutput(ns("pacf_diff"), height = "320px"),
          tags$div(style="font-size:12px; color:#a89472; margin-top:8px; padding:10px; background:#1a1714; border-radius:5px;",
            strong("Interpretación: "), "En la serie diferenciada, una sola barra significativa en rezago 1
            sugiere AR(1). Si el patrón desaparece respecto a la serie original, se confirma que d=1 fue suficiente."
          )
        )
      )
    )

  )
}

mod_marco_teorico_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {
    df <- reactive({ if (is.reactive(datos)) datos() else datos })

    # ── Tabla variables ───────────────────────────────────────────────────────
    output$tabla_variables <- renderDT({
      tabla <- data.frame(
        Variable    = c("Fecha","Consumo","Tesoreria","Ordinarios",
                        "Preferenciales","BancoRepublica","SinTesoreria","Total"),
        Descripcion = c("Fecha fin de mes","Créditos de consumo","Créditos de tesorería",
                        "Créditos ordinarios","Créditos preferenciales",
                        "Tasa Banco República","Promedio sin tesorería","Tasa total ponderada"),
        Unidad = c("Año-mes", rep("% anual", 7)),
        Fuente = rep("Banco de la República", 8)
      )
      datatable(tabla, rownames = FALSE,
                options = list(dom = "t", pageLength = 10, scrollX = TRUE),
                class = "stripe hover")
    })

    # ── Series reactivas ──────────────────────────────────────────────────────
    serie_orig  <- reactive({ x <- df()$Total; x[!is.na(x)] })
    serie_diff  <- reactive({ diff(serie_orig()) })
    fechas_orig <- reactive({ df()$Fecha[!is.na(df()$Total)] })
    fechas_diff <- reactive({ fechas_orig()[-1] })

    # ── Gráfico serie original ────────────────────────────────────────────────
    output$plot_serie_orig <- renderPlotly({
      plot_ly(x = fechas_orig(), y = serie_orig(),
              type = "scatter", mode = "lines",
              line = list(color = "#f59e0b", width = 2.2),
              hovertemplate = "%{x|%b %Y}: %{y:.2f}%<extra></extra>") %>%
        layout(xaxis = list(title = "", showgrid = FALSE),
               yaxis = list(title = "Tasa (%)", gridcolor = "rgba(245,158,11,0.1)"),
               paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"), plot_bgcolor  = "#0c0a09",
               margin = list(l=50, r=20, t=10, b=40))
    })

    # ── Gráfico primera diferencia ────────────────────────────────────────────
    output$plot_serie_diff <- renderPlotly({
      plot_ly() %>%
        add_lines(x = fechas_diff(), y = serie_diff(),
                  line = list(color = "#d97706", width = 2.2),
                  hovertemplate = "%{x|%b %Y}: %{y:.3f}<extra></extra>") %>%
        add_lines(x = fechas_diff(), y = rep(0, length(serie_diff())),
                  line = list(color = "#999", dash = "dash", width = 1),
                  showlegend = FALSE) %>%
        layout(xaxis = list(title = "", showgrid = FALSE),
               yaxis = list(title = "\u0394 Tasa (%)", gridcolor = "rgba(245,158,11,0.1)"),
               showlegend = FALSE,
               paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"), plot_bgcolor  = "#0c0a09",
               margin = list(l=50, r=20, t=10, b=40))
    })

    # ── Helper card test ──────────────────────────────────────────────────────
    test_card <- function(label, stat, pval, param, es_estac, bg) {
      # Badge más brillante y legible sobre fondo oscuro
      bc <- if (es_estac) "rgba(34,197,94,0.18)"  else "rgba(239,68,68,0.18)"
      bbo <- if (es_estac) "rgba(34,197,94,0.55)"  else "rgba(239,68,68,0.55)"
      bt <- if (es_estac) "ESTACIONARIA"  else "NO ESTACIONARIA"
      bf <- if (es_estac) "#4ade80"       else "#f87171"   # verde neón / rojo neón
      bico <- if (es_estac) "#4ade80"     else "#f87171"

      tags$div(
        style = paste0("background:", bg, "; border:1px solid ", bbo,
                       "; border-radius:8px; padding:16px; margin-bottom:8px;"),
        tags$div(style = "font-weight:600; color:#f0ebe0; margin-bottom:12px; font-size:13px;", label),
        tags$div(style = "display:flex; gap:28px; flex-wrap:wrap;",
          tags$div(
            tags$span(style="color:#5c5040; font-size:10px; letter-spacing:.5px; text-transform:uppercase;", "Estadístico"), br(),
            tags$span(style=paste0("font-weight:700; font-size:18px; color:", bico, ";"), round(stat, 4))
          ),
          tags$div(
            tags$span(style="color:#5c5040; font-size:10px; letter-spacing:.5px; text-transform:uppercase;", "p-valor"), br(),
            tags$span(style="font-weight:700; font-size:18px; color:#fcd34d;", round(pval, 4))
          ),
          tags$div(
            tags$span(style="color:#5c5040; font-size:10px; letter-spacing:.5px; text-transform:uppercase;", "Parámetro"), br(),
            tags$span(style="font-weight:700; font-size:18px; color:#a89472;", param)
          )
        ),
        br(),
        tags$span(
          style = paste0(
            "background:", bc, ";",
            "color:", bf, ";",
            "border: 1px solid ", bbo, ";",
            "padding:5px 14px; border-radius:20px;",
            "font-size:12px; font-weight:700; letter-spacing:.5px;"
          ),
          bt
        )
      )
    }

    # ── Tests reactivos ───────────────────────────────────────────────────────
    adf_orig_r  <- reactive({ suppressWarnings(tseries::adf.test(serie_orig(),  alternative = "stationary")) })
    adf_diff_r  <- reactive({ suppressWarnings(tseries::adf.test(serie_diff(),  alternative = "stationary")) })
    kpss_orig_r <- reactive({ suppressWarnings(tseries::kpss.test(serie_orig(), null = "Level")) })
    kpss_diff_r <- reactive({ suppressWarnings(tseries::kpss.test(serie_diff(), null = "Level")) })

    output$card_adf_orig <- renderUI({
      r <- adf_orig_r()
      test_card("Serie Original", r$statistic, r$p.value, r$parameter,
                es_estac = r$p.value < 0.05, bg = "rgba(245,158,11,0.06)")
    })
    output$card_adf_diff <- renderUI({
      r <- adf_diff_r()
      test_card("Primera Diferencia (d=1)", r$statistic, r$p.value, r$parameter,
                es_estac = r$p.value < 0.05, bg = "rgba(245,158,11,0.10)")
    })
    output$card_kpss_orig <- renderUI({
      r <- kpss_orig_r()
      test_card("Serie Original", r$statistic, r$p.value, r$parameter,
                es_estac = r$p.value >= 0.05, bg = "rgba(245,158,11,0.06)")
    })
    output$card_kpss_diff <- renderUI({
      r <- kpss_diff_r()
      test_card("Primera Diferencia (d=1)", r$statistic, r$p.value, r$parameter,
                es_estac = r$p.value >= 0.05, bg = "rgba(245,158,11,0.10)")
    })

    # ── Interpretación conjunta ───────────────────────────────────────────────
    output$interpretacion_conjunta <- renderUI({
      adf_o  <- adf_orig_r()$p.value  < 0.05
      kpss_o <- kpss_orig_r()$p.value >= 0.05
      adf_d  <- adf_diff_r()$p.value  < 0.05
      kpss_d <- kpss_diff_r()$p.value >= 0.05

      linea1 <- if (!adf_o && !kpss_o) {
        "Serie original: ADF y KPSS coinciden — NO estacionaria en niveles."
      } else if (adf_o && kpss_o) {
        "Serie original: ADF y KPSS coinciden — ESTACIONARIA en niveles."
      } else {
        "Serie original: ADF y KPSS discrepan — posibles quiebres estructurales (crisis 1999, COVID 2020). Aplicar d = 1 como precaución."
      }
      linea2 <- if (adf_d && kpss_d) {
        "Primera diferencia: ambos tests confirman ESTACIONARIEDAD. Se puede usar d = 1 para modelar."
      } else {
        "Primera diferencia: revisar resultados individuales. Puede requerirse d = 2 o tratamiento de outliers."
      }

      tags$div(style = "background:rgba(245,158,11,0.06); border-left:4px solid #f59e0b;
                        border-radius:6px; padding:16px 20px; margin: 0 15px 16px 15px;",
        tags$strong(style = "color:#fcd34d; font-size:13px;",
                    "Interpretación conjunta ADF + KPSS"),
        br(), br(),
        tags$p(style = "margin:0; color:#f5f0e8; font-size:13px;", linea1),
        tags$p(style = "margin:6px 0 0 0; color:#f5f0e8; font-size:13px;", linea2)
      )
    })

    # ── Helper plotly ACF/PACF ────────────────────────────────────────────────
    acf_plotly <- function(x, n_lags, es_pacf = FALSE) {
      n  <- length(x)
      ci <- qnorm(0.975) / sqrt(n)
      if (es_pacf) {
        vals <- pacf(x, lag.max = n_lags, plot = FALSE)$acf[,1,1]
      } else {
        vals <- acf(x,  lag.max = n_lags, plot = FALSE)$acf[-1,1,1]
      }
      lags    <- seq_len(n_lags)
      colores <- ifelse(abs(vals) > ci, "#f59e0b", "#78350f")

      plot_ly() %>%
        add_bars(x = lags, y = vals,
                 marker = list(color = colores,
                               line = list(color = colores, width = 0.3)),
                 hovertemplate = paste0("Rezago %{x}<br>",
                                        if(es_pacf) "PACF" else "ACF",
                                        ": %{y:.4f}<extra></extra>")) %>%
        add_lines(x = c(0.5, n_lags + 0.5), y = c( ci,  ci),
                  line = list(color = "#5c5040", dash = "dot", width = 1.5),
                  showlegend = FALSE) %>%
        add_lines(x = c(0.5, n_lags + 0.5), y = c(-ci, -ci),
                  line = list(color = "#5c5040", dash = "dot", width = 1.5),
                  showlegend = FALSE) %>%
        add_lines(x = c(0.5, n_lags + 0.5), y = c(0, 0),
                  line = list(color = "#ddd", width = 0.8),
                  showlegend = FALSE) %>%
        layout(
          xaxis = list(title = "Rezago", showgrid = FALSE, zeroline = FALSE,
                       tickmode = "linear", dtick = 4),
          yaxis = list(title = if(es_pacf) "PACF" else "ACF",
                       range = c(min(-0.15, min(vals) - 0.05),
                                 max( 0.15, max(vals) + 0.05)),
                       zeroline = FALSE, gridcolor = "rgba(245,158,11,0.1)"),
          bargap = 0.25,
          paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"), plot_bgcolor  = "#0c0a09",
          margin = list(l=50, r=20, t=10, b=40),
          showlegend = FALSE
        )
    }

    # ── Gráficos ACF/PACF ─────────────────────────────────────────────────────
    serie_sel <- reactive({
      x <- df()[[input$serie_acf]]
      x[!is.na(x)]
    })
    serie_sel_diff <- reactive({ diff(serie_sel()) })

    output$acf_orig  <- renderPlotly({ acf_plotly(serie_sel(),      input$n_lags, es_pacf = FALSE) })
    output$pacf_orig <- renderPlotly({ acf_plotly(serie_sel(),      input$n_lags, es_pacf = TRUE)  })
    output$acf_diff  <- renderPlotly({ acf_plotly(serie_sel_diff(), input$n_lags, es_pacf = FALSE) })
    output$pacf_diff <- renderPlotly({ acf_plotly(serie_sel_diff(), input$n_lags, es_pacf = TRUE)  })

  })
}
