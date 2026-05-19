# modules/mod_arima.R

mod_arima_ui <- function(id) {
  ns <- NS(id)
  fluidPage(

    # ── Intro ──────────────────────────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Construccion del modelo ARIMA",
          p("Con base en los resultados de las pruebas ADF y KPSS, y en los graficos ACF y PACF,
            se confirma que trabajar con la primera diferencia (d = 1) es la decision mas robusta.
            Se realiza una busqueda automatica del mejor orden mediante Grid Search por AIC,
            evaluando combinaciones de p = 0:3, d = 0:1, q = 0:3. Los tres modelos candidatos
            son ARIMA(1,1,0), ARIMA(0,1,1) y ARIMA(0,1,3), comparados por MAE, RMSE, MAPE, R2, AIC y BIC.")
        )
      )
    ),

    # ── Division serie ────────────────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Division de la serie — Entrenamiento (80%) y Prueba (20%)",
          fluidRow(
            column(4, uiOutput(ns("kpi_division"))),
            column(8, plotlyOutput(ns("plot_division"), height = "300px"))
          )
        )
      )
    ),

    # ── Grid Search ───────────────────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Busqueda del mejor orden — Grid Search por AIC",
          fluidRow(
            column(6, uiOutput(ns("kpi_mejor_modelo"))),
            column(6, DTOutput(ns("tabla_grid")))
          )
        )
      )
    ),

    # ── Summaries ─────────────────────────────────────────────────────────────
    fluidRow(
      column(4,
        box(width = 12, solidHeader = TRUE, title = "ARIMA(1,1,0)",
            uiOutput(ns("summary_110")))
      ),
      column(4,
        box(width = 12, solidHeader = TRUE, title = "ARIMA(0,1,1)",
            uiOutput(ns("summary_011")))
      ),
      column(4,
        box(width = 12, solidHeader = TRUE, title = "ARIMA(0,1,3)",
            uiOutput(ns("summary_013")))
      )
    ),

    # ── Metricas ──────────────────────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Comparacion de metricas — MAE, RMSE, MAPE, R2, AIC, BIC",
          DTOutput(ns("tabla_metricas"))
        )
      )
    ),

    # ── Visualizacion predicciones ────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Visualizacion de predicciones",
          fluidRow(
            column(3,
              tags$div(
                style = "background:#1a1714; border:1px solid rgba(245,158,11,0.18); border-radius:8px; padding:14px;",
                radioButtons(ns("modelo_sel"), "Modelo:",
                             choices  = c("ARIMA(1,1,0)" = "110",
                                          "ARIMA(0,1,1)" = "011",
                                          "ARIMA(0,1,3)" = "013"),
                             selected = "013")
              ),
              br(),
              tags$div(style = "font-size:11.5px; color:#a89472; padding:4px;",
                tags$span(style="color:#fcd34d; font-weight:600;", "Dorado: "), "Entrenamiento", br(),
                tags$span(style="color:#f87171; font-weight:600;", "Rojo: "),    "Valores reales", br(),
                tags$span(style="color:#f59e0b; font-weight:600;", "Ambar: "),   "Prediccion", br(),
                tags$span(style="color:#5c5040;",                  "Banda: "),   "IC 95%"
              )
            ),
            column(9,
              plotlyOutput(ns("plot_pred"), height = "400px")
            )
          )
        )
      )
    ),

    # ── Analisis de residuos ──────────────────────────────────────────────────
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Analisis de residuos — ARIMA(0,1,3)",

          # Fila 1: 3 cajitas de estadísticas
          fluidRow(
            column(4, uiOutput(ns("stats_residuos"))),
            column(4, uiOutput(ns("shapiro_result"))),
            column(4, uiOutput(ns("ljungbox_result")))
          ),

          tags$div(style="margin-top:16px;"),

          # Fila 2: gráficas más grandes con título
          fluidRow(
            column(6, plotlyOutput(ns("plot_res_tiempo"), height = "260px")),
            column(6, plotlyOutput(ns("plot_res_hist"),   height = "260px"))
          ),
          fluidRow(
            column(6, plotlyOutput(ns("plot_res_acf"),    height = "260px")),
            column(6, plotlyOutput(ns("plot_res_qq"),     height = "260px"))
          )
        )
      )
    ),

    # ── Interpretacion ────────────────────────────────────────────────────────
    fluidRow(
      column(6,
        box(width = 12, solidHeader = TRUE, title = "Que logra el modelo",
          tags$div(
            style = "background:rgba(245,158,11,0.06); border-left:3px solid #f59e0b; border-radius:0 8px 8px 0; padding:14px;",
            p("El modelo ARIMA(0,1,3), seleccionado por tener el menor AIC en el grid search,
              describe la dinamica general de la serie y logra errores absolutos moderados en el
              periodo de entrenamiento. La diferenciacion de orden 1 garantiza que se trabaja
              con una serie estacionaria, cumpliendo el supuesto fundamental del modelo.")
          )
        )
      ),
      column(6,
        box(width = 12, solidHeader = TRUE, title = "Limitaciones identificadas",
          tags$div(
            style = "background:rgba(239,68,68,0.06); border-left:3px solid rgba(239,68,68,0.5); border-radius:0 8px 8px 0; padding:14px;",
            p("El MAPE elevado y el R2 negativo en el conjunto de prueba muestran que
              las predicciones no capturan bien la variabilidad real. El analisis de residuos
              confirma que no se comportan como ruido blanco: la prueba Shapiro-Wilk rechaza
              la normalidad y el Ljung-Box detecta autocorrelacion residual. Se recomienda
              explorar modelos no lineales como SVM o LSTM.")
          )
        )
      )
    )
  )
}

mod_arima_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {

    df <- reactive({ if (is.reactive(datos)) datos() else datos })

    # ── Series — usar objetos precalculados en global.R ────────────────────────
    serie_r   <- reactive({ serie_global })
    fechas_r  <- reactive({ fechas_global })
    train_r   <- reactive({ train_global })
    test_r    <- reactive({ test_global })
    fechas_tr <- reactive({ fechas_tr_global })
    fechas_te <- reactive({ fechas_te_global })

    # ── Modelos — reutilizar los precalculados en global.R ─────────────────────
    modelo_110 <- reactive({ modelo_110_global })
    modelo_011 <- reactive({ modelo_011_global })
    modelo_013 <- reactive({ modelo_013_global })

    modelo_activo <- reactive({
      switch(input$modelo_sel,
        "110" = modelo_110_global,
        "011" = modelo_011_global,
        "013" = modelo_013_global
      )
    })

    # ── KPI division ───────────────────────────────────────────────────────────
    output$kpi_division <- renderUI({
      n_train <- length(train_r())
      n_test  <- length(test_r())
      tags$div(
        class = "kpi-card",
        tags$div(class="kpi-label", "Observaciones totales"),
        tags$div(class="kpi-value",
          tags$span(style="font-size:30px; font-weight:700; color:#fcd34d;",
                    length(serie_r()))),
        br(),
        tags$div(style="display:flex; gap:20px; margin-top:4px;",
          tags$div(
            tags$div(class="kpi-label", "Entrenamiento 80%"),
            tags$span(style="font-size:22px; font-weight:700; color:#f59e0b;", n_train),
            tags$span(style="color:#5c5040; font-size:11px;", " obs.")
          ),
          tags$div(
            tags$div(class="kpi-label", "Prueba 20%"),
            tags$span(style="font-size:22px; font-weight:700; color:#d97706;", n_test),
            tags$span(style="color:#5c5040; font-size:11px;", " obs.")
          )
        )
      )
    })

    # ── Plot division ──────────────────────────────────────────────────────────
    output$plot_division <- renderPlotly({
      corte <- as.character(tail(fechas_tr(), 1))
      plot_ly() %>%
        add_lines(x = fechas_tr(), y = train_r(),
                  name = "Entrenamiento",
                  line = list(color="#fcd34d", width=1.8),
                  hovertemplate = "%{x|%b %Y}: %{y:.2f}%<extra></extra>") %>%
        add_lines(x = fechas_te(), y = test_r(),
                  name = "Prueba",
                  line = list(color="#f87171", width=2),
                  hovertemplate = "%{x|%b %Y}: %{y:.2f}%<extra></extra>") %>%
        layout(
          shapes = list(list(
            type="line", xref="x", yref="paper",
            x0=corte, x1=corte, y0=0, y1=1,
            line=list(color="#5c5040", dash="dash", width=1)
          )),
          xaxis  = list(title="", showgrid=FALSE, tickfont=list(color="#a89472")),
          yaxis  = list(title="Tasa (%)", gridcolor="rgba(245,158,11,0.1)",
                        tickfont=list(color="#a89472")),
          legend = list(orientation="h", y=-0.2, font=list(color="#a89472")),
          paper_bgcolor="#0c0a09", plot_bgcolor="#0c0a09",
          font=list(color="#a89472", family="Poppins"),
          margin=list(l=50,r=20,t=10,b=40)
        )
    })

    # ── Grid Search — reutilizar el precalculado en global.R ──────────────────
    grid_results <- reactive({ grid_global })

    output$kpi_mejor_modelo <- renderUI({
      gr <- grid_results()
      mejor <- gr$Orden[1]
      tags$div(
        class = "kpi-card",
        tags$div(class="kpi-label", "Mejor modelo (menor AIC)"),
        tags$div(class="kpi-value",
          tags$span(style="font-size:26px; font-weight:700; color:#fcd34d;", mejor)),
        tags$div(class="kpi-delta",
          tags$span(style="color:#a89472;",
            paste0("AIC: ", gr$AIC[1], "  |  BIC: ", gr$BIC[1])))
      )
    })

    output$tabla_grid <- renderDT({
      datatable(grid_results(), rownames=FALSE,
                options=list(dom="t", pageLength=10, order=list(list(1,"asc"))),
                class="stripe hover") %>%
        formatStyle("Orden", fontWeight="bold", color="#fcd34d") %>%
        formatStyle("AIC", color="#f59e0b")
    })

    # ── Summaries estilizados ──────────────────────────────────────────────────
    render_summary_ui <- function(modelo_fn) {
      renderUI({
        m   <- modelo_fn()
        cf  <- coef(m)
        se  <- sqrt(diag(m$var.coef))
        aic <- round(AIC(m), 2)
        bic <- round(BIC(m), 2)
        sig <- round(m$sigma2, 4)
        ll  <- round(m$loglik, 2)
        rows <- lapply(names(cf), function(nm) {
          tags$div(
            style="padding:6px 8px; margin-bottom:4px; border-radius:6px; background:rgba(245,158,11,0.05); border-left:2px solid rgba(245,158,11,0.3);",
            tags$div(style="color:#a89472; font-size:10px; letter-spacing:0.4px; margin-bottom:2px;", nm),
            tags$div(style="color:#fcd34d; font-weight:700; font-size:13px; font-family:monospace;",
              round(cf[[nm]],4),
              tags$span(style="color:#5c5040; font-size:10px; font-weight:400;",
                paste0("  ± ", round(se[[nm]],4)))
            )
          )
        })
        tags$div(style="font-size:11.5px;",
          do.call(tags$div, rows),
          tags$div(style="margin-top:10px; display:grid; grid-template-columns:1fr 1fr; gap:6px;",
            tags$div(style="background:rgba(245,158,11,0.06); border-radius:6px; padding:6px 10px;",
              tags$div(style="color:#5c5040; font-size:10px;", "AIC"),
              tags$div(style="color:#f59e0b; font-weight:700;", aic)),
            tags$div(style="background:rgba(245,158,11,0.06); border-radius:6px; padding:6px 10px;",
              tags$div(style="color:#5c5040; font-size:10px;", "BIC"),
              tags$div(style="color:#f59e0b; font-weight:700;", bic)),
            tags$div(style="background:rgba(245,158,11,0.06); border-radius:6px; padding:6px 10px;",
              tags$div(style="color:#5c5040; font-size:10px;", "sigma²"),
              tags$div(style="color:#fcd34d; font-weight:700;", sig)),
            tags$div(style="background:rgba(245,158,11,0.06); border-radius:6px; padding:6px 10px;",
              tags$div(style="color:#5c5040; font-size:10px;", "log-lik"),
              tags$div(style="color:#fcd34d; font-weight:700;", ll))
          )
        )
      })
    }
    output$summary_110 <- render_summary_ui(modelo_110)
    output$summary_011 <- render_summary_ui(modelo_011)
    output$summary_013 <- render_summary_ui(modelo_013)

    # ── Metricas ───────────────────────────────────────────────────────────────
    output$tabla_metricas <- renderDT({
      test <- as.numeric(test_r()); h <- length(test)
      metricas <- function(modelo, nombre) {
        pred <- as.numeric(forecast(modelo, h=h)$mean)
        data.frame(
          Modelo = nombre,
          MAE    = round(mean(abs(test-pred)), 4),
          RMSE   = round(sqrt(mean((test-pred)^2)), 4),
          MAPE   = paste0(round(mean(abs((test-pred)/test))*100, 2), "%"),
          R2     = round(1 - sum((test-pred)^2)/sum((test-mean(test))^2), 4),
          AIC    = round(AIC(modelo), 2),
          BIC    = round(BIC(modelo), 2)
        )
      }
      tabla <- rbind(
        metricas(modelo_110(), "ARIMA(1,1,0)"),
        metricas(modelo_011(), "ARIMA(0,1,1)"),
        metricas(modelo_013(), "ARIMA(0,1,3)")
      )
      datatable(tabla, rownames=FALSE,
                options=list(dom="t", pageLength=5),
                class="stripe hover") %>%
        formatStyle("Modelo", fontWeight="bold", color="#fcd34d") %>%
        formatStyle("MAPE",   color="#f59e0b", fontWeight="600")
    })

    # ── Plot predicciones ──────────────────────────────────────────────────────
    output$plot_pred <- renderPlotly({
      test   <- test_r(); h <- length(test)
      modelo <- modelo_activo()
      nombre <- paste0("ARIMA(", switch(input$modelo_sel,"110"="1,1,0","011"="0,1,1","013"="0,1,3"), ")")
      fc     <- forecast(modelo, h=h)
      pred   <- as.numeric(fc$mean)
      lo95   <- as.numeric(fc$lower[,2])
      hi95   <- as.numeric(fc$upper[,2])
      fte    <- fechas_te()

      # Banda IC 95% como polígono cerrado
      x_band <- c(fte, rev(fte))
      y_band <- c(hi95, rev(lo95))
      plot_ly() %>%
        add_polygons(x=x_band, y=y_band,
                     name="IC 95%",
                     fillcolor="rgba(92,80,64,0.25)",
                     line=list(color="transparent"),
                     hoverinfo="skip") %>%
        add_lines(x=fechas_tr(), y=train_r(),
                  name="Entrenamiento",
                  line=list(color="#fcd34d", width=1.5),
                  hovertemplate="%{x|%b %Y}: %{y:.2f}%<extra></extra>") %>%
        add_lines(x=fte, y=as.numeric(test),
                  name="Prueba real",
                  line=list(color="#f87171", width=2),
                  hovertemplate="%{x|%b %Y}: %{y:.2f}%<extra></extra>") %>%
        add_lines(x=fte, y=pred,
                  name=nombre,
                  line=list(color="#f59e0b", width=2, dash="dash"),
                  hovertemplate="%{x|%b %Y}: %{y:.2f}%<extra></extra>") %>%
        layout(
          title  = list(text=paste0("Prediccion vs Valores Reales — ",nombre),
                        font=list(size=12,color="#fcd34d")),
          xaxis  = list(title="", showgrid=FALSE, tickfont=list(color="#a89472")),
          yaxis  = list(title="Tasa Colocacion Total (%)",
                        gridcolor="rgba(245,158,11,0.1)",
                        tickfont=list(color="#a89472")),
          legend = list(orientation="h", y=-0.15, font=list(color="#a89472")),
          paper_bgcolor="#0c0a09", plot_bgcolor="#0c0a09",
          font=list(color="#a89472", family="Poppins")
        )
    })

    # ── Residuos ───────────────────────────────────────────────────────────────
    residuos_r <- reactive({ as.numeric(residuals(modelo_013())) })

    cajita_stat <- function(titulo, icono, valor_principal, valor_secundario, color_val="#fcd34d", color_bg="rgba(245,158,11,0.06)", badge_txt=NULL, badge_color=NULL) {
      tags$div(
        style=paste0("background:", color_bg, "; border:1px solid rgba(245,158,11,0.18); border-radius:10px; padding:16px; height:100%; min-height:110px;"),
        tags$div(style="color:#a89472; font-size:10px; letter-spacing:0.6px; font-weight:600; margin-bottom:8px; text-transform:uppercase;",
          paste0(icono, " ", titulo)),
        tags$div(style=paste0("color:", color_val, "; font-size:22px; font-weight:700; font-family:monospace; margin-bottom:4px;"),
          valor_principal),
        tags$div(style="color:#5c5040; font-size:11px;", valor_secundario),
        if (!is.null(badge_txt)) tags$div(
          style=paste0("margin-top:8px; display:inline-block; background:", badge_color, "22; color:", badge_color, "; border:1px solid ", badge_color, "55; border-radius:4px; padding:2px 8px; font-size:10.5px; font-weight:700;"),
          badge_txt
        )
      )
    }

    output$stats_residuos <- renderUI({
      res <- residuos_r()
      cajita_stat(
        titulo = "Estadisticas",
        icono  = "≈",
        valor_principal = round(mean(res), 5),
        valor_secundario = paste0("Desv. Est.: ", round(sd(res), 4))
      )
    })

    output$shapiro_result <- renderUI({
      sw         <- suppressWarnings(shapiro.test(residuos_r()))
      es_normal  <- sw$p.value >= 0.05
      color      <- if(es_normal) "#4ade80" else "#f87171"
      badge_txt  <- if(es_normal) "Normal ✓" else "No normal ✗"
      cajita_stat(
        titulo          = "Shapiro-Wilk",
        icono           = "∿",
        valor_principal = paste0("W = ", round(sw$statistic, 4)),
        valor_secundario = paste0("p-valor = ", signif(sw$p.value, 4)),
        color_val       = color,
        badge_txt       = badge_txt,
        badge_color     = color
      )
    })

    output$ljungbox_result <- renderUI({
      lb       <- suppressWarnings(Box.test(residuos_r(), lag=20, type="Ljung-Box"))
      es_ruido <- lb$p.value >= 0.05
      color    <- if(es_ruido) "#4ade80" else "#f87171"
      badge_txt <- if(es_ruido) "Sin autocorr. ✓" else "Autocorr. detectada ✗"
      cajita_stat(
        titulo          = "Ljung-Box",
        icono           = "○",
        valor_principal = paste0("X² = ", round(lb$statistic, 4)),
        valor_secundario = paste0("p-valor = ", signif(lb$p.value, 4)),
        color_val       = color,
        badge_txt       = badge_txt,
        badge_color     = color
      )
    })


    # Residuos en el tiempo
    output$plot_res_tiempo <- renderPlotly({
      res <- residuos_r()
      plot_ly(x=seq_along(res), y=res, type="scatter", mode="lines",
              line=list(color="#f59e0b", width=1.2),
              hovertemplate="Obs %{x}: %{y:.4f}<extra></extra>") %>%
        add_lines(x=c(1,length(res)), y=c(0,0),
                  line=list(color="#5c5040", dash="dash", width=1),
                  showlegend=FALSE) %>%
        layout(title=list(text="Residuos en el tiempo", font=list(size=13,color="#fcd34d"), x=0.04),
               xaxis=list(title="", showgrid=FALSE, tickfont=list(color="#a89472")),
               yaxis=list(title="", gridcolor="rgba(245,158,11,0.08)",
                          tickfont=list(color="#a89472")),
               paper_bgcolor="#0c0a09", plot_bgcolor="#0c0a09",
               font=list(color="#a89472"), margin=list(l=40,r=10,t=40,b=30),
               showlegend=FALSE)
    })

    # Histograma de residuos
    output$plot_res_hist <- renderPlotly({
      res <- residuos_r()
      plot_ly(x=res, type="histogram", nbinsx=25,
              marker=list(color="rgba(245,158,11,0.4)",
                          line=list(color="#0c0a09", width=0.5)),
              hovertemplate="Rango: %{x:.3f}<br>n: %{y}<extra></extra>") %>%
        layout(title=list(text="Histograma de residuos", font=list(size=13,color="#fcd34d"), x=0.04),
               xaxis=list(title="", tickfont=list(color="#a89472")),
               yaxis=list(title="", gridcolor="rgba(245,158,11,0.08)",
                          tickfont=list(color="#a89472")),
               paper_bgcolor="#0c0a09", plot_bgcolor="#0c0a09",
               font=list(color="#a89472"), margin=list(l=40,r=10,t=40,b=30))
    })

    # ACF de residuos
    output$plot_res_acf <- renderPlotly({
      res <- residuos_r()
      n   <- length(res)
      ci  <- qnorm(0.975) / sqrt(n)
      ac  <- acf(res, lag.max=30, plot=FALSE)$acf[-1,1,1]
      lags <- seq_along(ac)
      cols <- ifelse(abs(ac) > ci, "#f59e0b", "#3d2e1a")
      plot_ly() %>%
        add_bars(x=lags, y=ac,
                 marker=list(color=cols, line=list(color=cols, width=0.3)),
                 hovertemplate="Lag %{x}: %{y:.4f}<extra></extra>") %>%
        add_lines(x=c(0.5,30.5), y=c(ci,ci),
                  line=list(color="#5c5040",dash="dot",width=1.2),showlegend=FALSE) %>%
        add_lines(x=c(0.5,30.5), y=c(-ci,-ci),
                  line=list(color="#5c5040",dash="dot",width=1.2),showlegend=FALSE) %>%
        layout(title=list(text="ACF de residuos", font=list(size=13,color="#fcd34d"), x=0.04),
               xaxis=list(title="Rezago", showgrid=FALSE, tickfont=list(color="#a89472")),
               yaxis=list(title="", gridcolor="rgba(245,158,11,0.08)",
                          tickfont=list(color="#a89472")),
               bargap=0.3,
               paper_bgcolor="#0c0a09", plot_bgcolor="#0c0a09",
               font=list(color="#a89472"), margin=list(l=40,r=10,t=40,b=30),
               showlegend=FALSE)
    })

    # QQ-Plot
    output$plot_res_qq <- renderPlotly({
      res  <- residuos_r()
      qq   <- qqnorm(res, plot.it=FALSE)
      qqdf <- data.frame(teo=qq$x, emp=qq$y)
      # Línea de referencia
      q1   <- quantile(res, 0.25); q3 <- quantile(res, 0.75)
      t1   <- qnorm(0.25); t3 <- qnorm(0.75)
      slope <- (q3-q1)/(t3-t1); intercept <- q1 - slope*t1
      x_ref <- range(qqdf$teo)
      y_ref <- slope * x_ref + intercept

      plot_ly() %>%
        add_trace(x=qqdf$teo, y=qqdf$emp,
                  type="scatter", mode="markers",
                  marker=list(color="#f59e0b", size=4, opacity=0.7),
                  hovertemplate="Teo: %{x:.2f}<br>Emp: %{y:.2f}<extra></extra>") %>%
        add_lines(x=x_ref, y=y_ref,
                  line=list(color="#f87171", width=1.5, dash="dash"),
                  showlegend=FALSE) %>%
        layout(title=list(text="QQ-Plot de residuos", font=list(size=13,color="#fcd34d"), x=0.04),
               xaxis=list(title="Cuantiles teoricos", tickfont=list(color="#a89472"),
                          showgrid=FALSE),
               yaxis=list(title="Cuantiles empiricos",
                          gridcolor="rgba(245,158,11,0.08)",
                          tickfont=list(color="#a89472")),
               paper_bgcolor="#0c0a09", plot_bgcolor="#0c0a09",
               font=list(color="#a89472"), margin=list(l=50,r=10,t=40,b=40),
               showlegend=FALSE)
    })

  })
}
