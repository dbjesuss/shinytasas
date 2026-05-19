# modules/mod_rolling.R

mod_rolling_ui <- function(id) {
  ns <- NS(id)
  fluidPage(

    # ── Introduccion a la tecnica Rolling ────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Tecnica Rolling — Supuestos y Aplicabilidad",
          p("Para aplicar la tecnica de rolling de acuerdo al material escrito por el Dr. Lhiki Rubio
            (ya sea para estadisticos moviles o para pronosticos continuos), es fundamental comprobar
            una serie de supuestos estadisticos que garantizan que los resultados y las predicciones
            sean validos y no dependan de fluctuaciones aleatorias.")
        )
      )
    ),

    # ── Supuestos ─────────────────────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Supuestos del modelo Rolling",
          fluidRow(
            # Supuesto 1
            column(4,
              tags$div(
                style = "background:rgba(245,158,11,0.06); border:1px solid rgba(245,158,11,0.18);
                         border-radius:10px; padding:16px; height:100%; margin-bottom:12px;",
                tags$div(style = "color:#fcd34d; font-size:12px; font-weight:700; letter-spacing:0.5px;
                                  margin-bottom:8px; text-transform:uppercase;",
                  "1. Estacionariedad"),
                tags$p(style = "color:#a89472; font-size:12px; line-height:1.6; margin:0;",
                  "Es el supuesto mas importante. Implica que la media, varianza y autocorrelacion
                  no cambian con el tiempo. Se comprueba con la prueba de Dickey-Fuller Aumentada (ADF).
                  Si el p-valor es mayor a 0.05, la serie debe diferenciarse antes de aplicar el modelo.")
              )
            ),
            # Supuesto 2
            column(4,
              tags$div(
                style = "background:rgba(245,158,11,0.06); border:1px solid rgba(245,158,11,0.18);
                         border-radius:10px; padding:16px; height:100%; margin-bottom:12px;",
                tags$div(style = "color:#fcd34d; font-size:12px; font-weight:700; letter-spacing:0.5px;
                                  margin-bottom:8px; text-transform:uppercase;",
                  "2. Independencia y Ausencia de Autocorrelacion"),
                tags$p(style = "color:#a89472; font-size:12px; line-height:1.6; margin:0;",
                  "El modelo rolling requiere que la serie no sea ruido blanco ni caminata aleatoria.
                  Se analizan los graficos ACF y PACF para identificar patrones predecibles.
                  La prueba de Ljung-Box determina si la autocorrelacion es estadisticamente significativa.")
              )
            ),
            # Supuesto 3
            column(4,
              tags$div(
                style = "background:rgba(245,158,11,0.06); border:1px solid rgba(245,158,11,0.18);
                         border-radius:10px; padding:16px; height:100%; margin-bottom:12px;",
                tags$div(style = "color:#fcd34d; font-size:12px; font-weight:700; letter-spacing:0.5px;
                                  margin-bottom:8px; text-transform:uppercase;",
                  "3. Varianza Constante (Homocedasticidad)"),
                tags$p(style = "color:#a89472; font-size:12px; line-height:1.6; margin:0;",
                  "La magnitud de las fluctuaciones debe ser estable. Si la varianza cambia con el tiempo
                  (heterocedasticidad), el pronostico puede verse distorsionado. Se aplican
                  transformaciones logaritmicas o de potencia para estabilizar la varianza.")
              )
            )
          ),
          fluidRow(
            # Supuesto 4
            column(4,
              tags$div(
                style = "background:rgba(245,158,11,0.06); border:1px solid rgba(245,158,11,0.18);
                         border-radius:10px; padding:16px; height:100%; margin-bottom:12px;",
                tags$div(style = "color:#fcd34d; font-size:12px; font-weight:700; letter-spacing:0.5px;
                                  margin-bottom:8px; text-transform:uppercase;",
                  "4. Normalidad de los Residuos"),
                tags$p(style = "color:#a89472; font-size:12px; line-height:1.6; margin:0;",
                  "En rolling forecast basado en ARIMA, los errores deben seguir una distribucion normal
                  con media cero. Se comprueban con las pruebas Shapiro-Wilk o Kolmogorov-Smirnov.")
              )
            ),
            # Supuesto 5
            column(4,
              tags$div(
                style = "background:rgba(245,158,11,0.06); border:1px solid rgba(245,158,11,0.18);
                         border-radius:10px; padding:16px; height:100%; margin-bottom:12px;",
                tags$div(style = "color:#fcd34d; font-size:12px; font-weight:700; letter-spacing:0.5px;
                                  margin-bottom:8px; text-transform:uppercase;",
                  "5. Tamano de la Ventana y Datos Suficientes"),
                tags$p(style = "color:#a89472; font-size:12px; line-height:1.6; margin:0;",
                  "Se recomienda al menos 50 observaciones para estimar fiablemente la autocorrelacion.
                  El tamano de la ventana (k) y la longitud del paso (l) determinan cuanta informacion
                  historica se considera en cada calculo.")
              )
            ),
            # Conclusion supuestos
            column(4,
              tags$div(
                style = "background:rgba(239,68,68,0.06); border:1px solid rgba(239,68,68,0.25);
                         border-radius:10px; padding:16px; height:100%; margin-bottom:12px;",
                tags$div(style = "color:#f87171; font-size:12px; font-weight:700; letter-spacing:0.5px;
                                  margin-bottom:8px; text-transform:uppercase;",
                  "Conclusion sobre los Supuestos"),
                tags$p(style = "color:#a89472; font-size:12px; line-height:1.6; margin:0;",
                  "Al explorar 242 combinaciones de parametros (p, q en 0-10; d en 1 y 2), todos los
                  p-valores de Ljung-Box resultaron extremadamente bajos. La independencia de errores
                  no puede cumplirse, haciendo que la tecnica rolling no sea pertinente en este contexto.")
              )
            )
          )
        )
      )
    ),

    # ── Evaluacion de supuestos con datos reales ──────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Evaluacion de Supuestos — Serie TasaColocacionTotal",
          fluidRow(
            column(3, uiOutput(ns("kpi_obs"))),
            column(3, uiOutput(ns("kpi_adf"))),
            column(3, uiOutput(ns("kpi_shapiro"))),
            column(3, uiOutput(ns("kpi_ljungbox")))
          )
        )
      )
    ),

    # ── Graficos ACF y PACF ───────────────────────────────────────────────────
    fluidRow(
      column(6,
        box(width = 12, solidHeader = TRUE,
            title = "ACF — Autocorrelacion",
          plotlyOutput(ns("plot_acf"), height = "280px")
        )
      ),
      column(6,
        box(width = 12, solidHeader = TRUE,
            title = "PACF — Autocorrelacion Parcial",
          plotlyOutput(ns("plot_pacf"), height = "280px")
        )
      )
    ),

    # ── Busqueda de parametros ARIMA ──────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Busqueda de parametros ARIMA — p-valores Ljung-Box",
          fluidRow(
            column(8,
              tags$div(
                style = "background:rgba(245,158,11,0.04); border-left:3px solid #f59e0b;
                         border-radius:0 8px 8px 0; padding:14px; margin-bottom:12px;",
                tags$p(style = "color:#a89472; font-size:12.5px; line-height:1.7; margin:0;",
                  "Se fijo el parametro d en 1 y 2, dado que diferenciar indefinidamente implicaria
                  perder informacion relevante. Se exploraron valores de p y q en el rango 0 a 4,
                  generando 50 combinaciones posibles (2 x 5 x 5). En todos los casos los p-valores
                  Ljung-Box resultaron extremadamente bajos, evidenciando autocorrelacion residual
                  persistente. No existe un conjunto de parametros que permita cumplir el supuesto
                  de independencia."
                )
              ),
              DTOutput(ns("tabla_pvalores"))
            ),
            column(4,
              tags$div(
                style = "background:rgba(239,68,68,0.06); border:1px solid rgba(239,68,68,0.25);
                         border-radius:10px; padding:18px;",
                tags$div(style = "color:#f87171; font-size:11px; font-weight:700; letter-spacing:0.6px;
                                  margin-bottom:12px; text-transform:uppercase;",
                  "Supuesto Violado"),
                tags$div(style = "color:#fcd34d; font-size:28px; font-weight:700; margin-bottom:6px;",
                  "Independencia"),
                tags$div(style = "color:#a89472; font-size:11.5px; line-height:1.6;",
                  "La tecnica rolling no es aplicable cuando se viola el supuesto de independencia
                  de los residuos. Con que un supuesto se incumpla, el modelo carece de rigurosidad
                  estadistica."),
                tags$div(
                  style = "margin-top:14px; background:rgba(239,68,68,0.12); border-radius:6px;
                           padding:10px 14px;",
                  tags$div(style = "color:#f87171; font-size:10px; font-weight:700;",
                    "CONCLUSION"),
                  tags$div(style = "color:#a89472; font-size:11px; margin-top:4px;",
                    "Rolling forecast no pertinente para esta serie.")
                )
              )
            )
          )
        )
      )
    ),

  )
}

mod_rolling_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {

    df <- reactive({ if (is.reactive(datos)) datos() else datos })

    serie_r  <- reactive({ serie_global })
    fechas_r <- reactive({ fechas_global })

    # ── Helper cajita KPI ──────────────────────────────────────────────────────
    cajita_rolling <- function(titulo, icono, valor_principal, valor_secundario,
                                color_val = "#fcd34d",
                                color_bg  = "rgba(245,158,11,0.06)",
                                badge_txt = NULL, badge_color = NULL) {
      tags$div(
        style = paste0("background:", color_bg,
                       "; border:1px solid rgba(245,158,11,0.18); border-radius:10px;",
                       " padding:16px; height:100%; min-height:110px;"),
        tags$div(style = "color:#a89472; font-size:10px; letter-spacing:0.6px;
                          font-weight:600; margin-bottom:8px; text-transform:uppercase;",
          paste0(icono, " ", titulo)),
        tags$div(style = paste0("color:", color_val,
                                "; font-size:22px; font-weight:700; font-family:monospace; margin-bottom:4px;"),
          valor_principal),
        tags$div(style = "color:#5c5040; font-size:11px;", valor_secundario),
        if (!is.null(badge_txt)) tags$div(
          style = paste0("margin-top:8px; display:inline-block; background:", badge_color,
                         "22; color:", badge_color, "; border:1px solid ", badge_color,
                         "55; border-radius:4px; padding:2px 8px; font-size:10.5px; font-weight:700;"),
          badge_txt
        )
      )
    }

    # ── KPI: Observaciones ────────────────────────────────────────────────────
    output$kpi_obs <- renderUI({
      n <- length(serie_r())
      cajita_rolling(
        titulo          = "Observaciones",
        icono           = "n",
        valor_principal = n,
        valor_secundario = paste0("Periodo: ", format(min(fechas_r()), "%Y"), " — ",
                                              format(max(fechas_r()), "%Y")),
        color_val       = "#fcd34d"
      )
    })

    # ── KPI: ADF ──────────────────────────────────────────────────────────────
    output$kpi_adf <- renderUI({
      adf  <- suppressWarnings(adf.test(serie_r()))
      es_estacionaria <- adf$p.value < 0.05
      color <- if(es_estacionaria) "#4ade80" else "#f87171"
      badge <- if(es_estacionaria) "Estacionaria ✓" else "No estacionaria ✗"
      cajita_rolling(
        titulo          = "Prueba ADF",
        icono           = "∿",
        valor_principal = paste0("p = ", signif(adf$p.value, 3)),
        valor_secundario = paste0("ADF = ", round(adf$statistic, 3)),
        color_val       = color,
        badge_txt       = badge,
        badge_color     = color
      )
    })

    # ── KPI: Shapiro-Wilk ─────────────────────────────────────────────────────
    output$kpi_shapiro <- renderUI({
      res <- as.numeric(residuals(modelo_013_global))
      sw  <- suppressWarnings(shapiro.test(res))
      es_normal <- sw$p.value >= 0.05
      color <- if(es_normal) "#4ade80" else "#f87171"
      badge <- if(es_normal) "Normal ✓" else "No normal ✗"
      cajita_rolling(
        titulo          = "Shapiro-Wilk (Residuos)",
        icono           = "≈",
        valor_principal = paste0("p = ", signif(sw$p.value, 3)),
        valor_secundario = paste0("W = ", round(sw$statistic, 4)),
        color_val       = color,
        badge_txt       = badge,
        badge_color     = color
      )
    })

    # ── KPI: Ljung-Box ────────────────────────────────────────────────────────
    output$kpi_ljungbox <- renderUI({
      res <- as.numeric(residuals(modelo_013_global))
      lb  <- suppressWarnings(Box.test(res, lag = 20, type = "Ljung-Box"))
      es_independiente <- lb$p.value >= 0.05
      color <- if(es_independiente) "#4ade80" else "#f87171"
      badge <- if(es_independiente) "Sin autocorr. ✓" else "Autocorr. detectada ✗"
      cajita_rolling(
        titulo          = "Ljung-Box (Residuos)",
        icono           = "○",
        valor_principal = paste0("p = ", signif(lb$p.value, 3)),
        valor_secundario = paste0("X² = ", round(lb$statistic, 3), " (lag=20)"),
        color_val       = color,
        badge_txt       = badge,
        badge_color     = color
      )
    })

    # ── ACF ───────────────────────────────────────────────────────────────────
    output$plot_acf <- renderPlotly({
      s  <- serie_r()
      n  <- length(s)
      ci <- qnorm(0.975) / sqrt(n)
      ac <- acf(s, lag.max = 30, plot = FALSE)$acf[-1, 1, 1]
      lags <- seq_along(ac)
      cols <- ifelse(abs(ac) > ci, "#f59e0b", "#3d2e1a")

      plot_ly() %>%
        add_bars(x = lags, y = ac,
                 marker = list(color = cols, line = list(color = cols, width = 0.3)),
                 hovertemplate = "Lag %{x}: %{y:.4f}<extra></extra>") %>%
        add_lines(x = c(0.5, 30.5), y = c(ci, ci),
                  line = list(color = "#5c5040", dash = "dot", width = 1.2),
                  showlegend = FALSE) %>%
        add_lines(x = c(0.5, 30.5), y = c(-ci, -ci),
                  line = list(color = "#5c5040", dash = "dot", width = 1.2),
                  showlegend = FALSE) %>%
        layout(
          title  = list(text = "Autocorrelacion — Serie Total",
                        font = list(size = 12, color = "#fcd34d"), x = 0.04),
          xaxis  = list(title = "Rezago", showgrid = FALSE, tickfont = list(color = "#a89472")),
          yaxis  = list(title = "ACF", gridcolor = "rgba(245,158,11,0.08)",
                        tickfont = list(color = "#a89472")),
          bargap = 0.3,
          paper_bgcolor = "#0c0a09", plot_bgcolor = "#0c0a09",
          font   = list(color = "#a89472", family = "Poppins"),
          margin = list(l = 50, r = 10, t = 40, b = 40),
          showlegend = FALSE
        )
    })

    # ── PACF ──────────────────────────────────────────────────────────────────
    output$plot_pacf <- renderPlotly({
      s  <- serie_r()
      n  <- length(s)
      ci <- qnorm(0.975) / sqrt(n)
      pc <- pacf(s, lag.max = 30, plot = FALSE)$acf[, 1, 1]
      lags <- seq_along(pc)
      cols <- ifelse(abs(pc) > ci, "#fcd34d", "#3d2e1a")

      plot_ly() %>%
        add_bars(x = lags, y = pc,
                 marker = list(color = cols, line = list(color = cols, width = 0.3)),
                 hovertemplate = "Lag %{x}: %{y:.4f}<extra></extra>") %>%
        add_lines(x = c(0.5, 30.5), y = c(ci, ci),
                  line = list(color = "#5c5040", dash = "dot", width = 1.2),
                  showlegend = FALSE) %>%
        add_lines(x = c(0.5, 30.5), y = c(-ci, -ci),
                  line = list(color = "#5c5040", dash = "dot", width = 1.2),
                  showlegend = FALSE) %>%
        layout(
          title  = list(text = "Autocorrelacion Parcial — Serie Total",
                        font = list(size = 12, color = "#fcd34d"), x = 0.04),
          xaxis  = list(title = "Rezago", showgrid = FALSE, tickfont = list(color = "#a89472")),
          yaxis  = list(title = "PACF", gridcolor = "rgba(245,158,11,0.08)",
                        tickfont = list(color = "#a89472")),
          bargap = 0.3,
          paper_bgcolor = "#0c0a09", plot_bgcolor = "#0c0a09",
          font   = list(color = "#a89472", family = "Poppins"),
          margin = list(l = 50, r = 10, t = 40, b = 40),
          showlegend = FALSE
        )
    })

    # ── Tabla de p-valores de la busqueda ─────────────────────────────────────
    # Valores exactos obtenidos del script Python del Rmd (serie completa,
    # statsmodels ARIMA, Ljung-Box lag=10, Shapiro-Wilk).
    # d en {1,2}, p en 0:4, q en 0:4 -> 50 combinaciones.
    rolling_grid <- data.frame(
      p = c(0,0,0,0,0, 1,1,1,1,1, 2,2,2,2,2, 3,3,3,3,3, 4,4,4,4,4,
            0,0,0,0,0, 1,1,1,1,1, 2,2,2,2,2, 3,3,3,3,3, 4,4,4,4,4),
      d = c(rep(1,25), rep(2,25)),
      q = rep(c(0,1,2,3,4), 10),
      p_LjungBox = c(
        2.545917e-12, 3.694652e-11, 1.495891e-10, 1.350154e-05, 5.485228e-06,
        3.032132e-11, 3.803801e-11, 1.171510e-08, 2.958276e-06, 3.593607e-06,
        8.474629e-11, 1.369667e-07, 8.582613e-09, 3.991418e-06, 6.099931e-06,
        8.070591e-05, 3.509251e-05, 8.446851e-05, 1.741277e-05, 3.212051e-05,
        7.784164e-05, 3.741703e-05, 8.245475e-05, 1.375877e-04, 1.503671e-05,
        1.293130e-45, 4.528589e-24, 1.263896e-16, 3.367597e-17, 2.476768e-11,
        1.919084e-38, 1.335382e-19, 7.564416e-17, 2.264072e-15, 5.657127e-12,
        9.067677e-13, 3.760151e-12, 1.381398e-11, 2.187397e-11, 4.352182e-12,
        2.391308e-12, 6.348461e-12, 5.840256e-12, 1.859182e-11, 6.064128e-12,
        3.511412e-12, 2.865923e-12, 8.849127e-14, 6.454141e-12, 3.967062e-12
      ),
      p_Shapiro = c(
        1.603174e-33, 2.339712e-33, 2.693727e-33, 1.726529e-33, 1.650304e-33,
        2.299742e-33, 2.373815e-33, 1.767745e-33, 1.613781e-33, 1.445514e-33,
        2.588934e-33, 4.513412e-33, 2.281104e-33, 1.750337e-33, 1.665377e-33,
        1.158812e-33, 1.095423e-33, 1.733520e-33, 1.687209e-33, 2.138796e-33,
        1.152372e-33, 1.109673e-33, 1.724316e-33, 3.401111e-33, 2.568973e-33,
        2.073504e-32, 7.016028e-33, 6.048862e-33, 6.052350e-33, 5.203070e-33,
        5.927633e-33, 1.354195e-32, 6.033037e-33, 6.632433e-33, 5.432815e-33,
        4.535592e-33, 3.558918e-33, 6.193053e-33, 6.392532e-33, 1.185423e-32,
        3.936369e-33, 3.451536e-33, 2.706976e-33, 7.253968e-33, 1.118373e-32,
        1.120042e-32, 9.785441e-33, 4.794446e-32, 1.240769e-32, 6.942293e-33
      ),
      stringsAsFactors = FALSE
    )
    rolling_grid$Independencia <- ifelse(rolling_grid$p_LjungBox >= 0.05, "OK v", "Falla x")
    rolling_grid$Normalidad    <- ifelse(rolling_grid$p_Shapiro  >= 0.05, "OK v", "Falla x")

    output$tabla_pvalores <- renderDT({
      datatable(rolling_grid, rownames = FALSE,
                options = list(dom = "t", pageLength = 50, ordering = FALSE),
                class = "stripe hover") %>%
        formatStyle(c("p", "d", "q"), fontWeight = "bold", color = "#fcd34d") %>%
        formatStyle("p_LjungBox", color = "#f59e0b") %>%
        formatStyle("p_Shapiro",  color = "#a89472") %>%
        formatStyle("Independencia",
                    color      = styleEqual(c("OK v", "Falla x"), c("#4ade80", "#f87171")),
                    fontWeight = "700") %>%
        formatStyle("Normalidad",
                    color      = styleEqual(c("OK v", "Falla x"), c("#4ade80", "#f87171")),
                    fontWeight = "700")
    })

  })
}
