# modules/mod_prediccion.R

mod_prediccion_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(3,
        box(width = 12, status = "primary", solidHeader = TRUE,
            title = "Parámetros del pronóstico",
            sliderInput(ns("horizonte"), "Horizonte (meses):",
                        min=1, max=36, value=12, step=1),
            hr(),
            h5("Información del modelo"),
            verbatimTextOutput(ns("info_modelo")),
            hr(),
            h5("Métricas de ajuste"),
            tableOutput(ns("metricas"))
        )
      ),
      column(9,
        box(width = 12, status = "success", solidHeader = TRUE,
            title = "Pronóstico — Tasa Total de Colocación",
            plotlyOutput(ns("grafico_pronostico"), height = "420px")
        )
      )
    ),
    fluidRow(
      column(12,
        box(width = 12, status = "info", solidHeader = TRUE,
            title = "Valores proyectados",
            DTOutput(ns("tabla_pronostico"))
        )
      )
    )
  )
}

mod_prediccion_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {

    # Pronóstico reactivo
    pronostico <- reactive({
      forecast(modelo, h = input$horizonte, level = c(80, 95))
    })

    # Info del modelo
    output$info_modelo <- renderText({
      paste0("Modelo: ", modelo$method, "\n",
             "Orden AR:  ", paste(modelo$arma[1], collapse=""), "\n",
             "Difs:      ", modelo$arma[6], "\n",
             "Orden MA:  ", paste(modelo$arma[2], collapse=""), "\n",
             "AIC:       ", round(modelo$aic, 2))
    })

    # Métricas
    output$metricas <- renderTable({
      acc <- accuracy(modelo)
      data.frame(
        Métrica = c("RMSE","MAE","MAPE"),
        Valor   = round(c(acc[,"RMSE"], acc[,"MAE"], acc[,"MAPE"]), 3)
      )
    }, striped=TRUE, hover=TRUE, bordered=TRUE)

    # Gráfico
    output$grafico_pronostico <- renderPlotly({
      fc <- pronostico()
      n_hist <- 60  # últimos 5 años de histórico

      fecha_inicio <- min(datos$Fecha)
      n_obs        <- nrow(datos)
      fechas_hist  <- datos$Fecha
      valores_hist <- datos$Total

      # Fechas de pronóstico
      ultima_fecha <- max(datos$Fecha)
      fechas_fc    <- seq.Date(ultima_fecha, by="month", length.out=input$horizonte+1)[-1]

      # Convertir forecast a vectores
      fc_media  <- as.numeric(fc$mean)
      fc_lo80   <- as.numeric(fc$lower[,1])
      fc_hi80   <- as.numeric(fc$upper[,1])
      fc_lo95   <- as.numeric(fc$lower[,2])
      fc_hi95   <- as.numeric(fc$upper[,2])

      plot_ly() %>%
        # Histórico completo (gris)
        add_trace(x=fechas_hist, y=valores_hist,
                  type="scatter", mode="lines",
                  name="Histórico",
                  line=list(color="#AAAAAA", width=1.5),
                  hovertemplate="%{x|%b %Y}: %{y:.2f}%<extra></extra>") %>%
        # IC 95%
        add_ribbons(x=c(fechas_fc, rev(fechas_fc)),
                    ymin=fc_lo95, ymax=fc_hi95,
                    name="IC 95%",
                    fillcolor="rgba(91,141,184,0.2)",
                    line=list(color="transparent")) %>%
        # IC 80%
        add_ribbons(x=c(fechas_fc, rev(fechas_fc)),
                    ymin=fc_lo80, ymax=fc_hi80,
                    name="IC 80%",
                    fillcolor="rgba(91,141,184,0.35)",
                    line=list(color="transparent")) %>%
        # Pronóstico central
        add_trace(x=fechas_fc, y=fc_media,
                  type="scatter", mode="lines+markers",
                  name="Pronóstico",
                  line=list(color="#f59e0b", width=2.5, dash="dash"),
                  marker=list(color="#f59e0b", size=5),
                  hovertemplate="%{x|%b %Y}: %{y:.2f}%<extra></extra>") %>%
        layout(
          title=paste0("Pronóstico ARIMA — Tasa Total (",input$horizonte," meses)"),
          xaxis=list(title="Fecha", showgrid=FALSE),
          yaxis=list(title="Tasa (%)"),
          legend=list(orientation="h", y=-0.15),
          paper_bgcolor="#0c0a09", font=list(color="#a89472"),
          plot_bgcolor ="#0c0a09"
        )
    })

    # Tabla de valores
    output$tabla_pronostico <- renderDT({
      fc <- pronostico()
      ultima_fecha <- max(datos$Fecha)
      fechas_fc    <- seq.Date(ultima_fecha, by="month", length.out=input$horizonte+1)[-1]

      df <- data.frame(
        Mes           = format(fechas_fc, "%B %Y"),
        Pronostico    = round(as.numeric(fc$mean), 3),
        IC_80_Inf     = round(as.numeric(fc$lower[,1]), 3),
        IC_80_Sup     = round(as.numeric(fc$upper[,1]), 3),
        IC_95_Inf     = round(as.numeric(fc$lower[,2]), 3),
        IC_95_Sup     = round(as.numeric(fc$upper[,2]), 3)
      )
      datatable(df, rownames=FALSE,
                colnames=c("Mes","Pronóstico (%)","IC 80% Inf","IC 80% Sup","IC 95% Inf","IC 95% Sup"),
                options=list(pageLength=12, scrollX=TRUE, dom="tip"),
                class="stripe hover")
    })

  })
}
