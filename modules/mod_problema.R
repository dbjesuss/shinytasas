# modules/mod_problema.R

mod_problema_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(12,
        box(width = 12, status = "danger", solidHeader = TRUE,
            title = "Planteamiento del problema",
            p("Las tasas de interés de colocación determinan el acceso y el costo del crédito para hogares
              y empresas en Colombia. Su alta volatilidad histórica —especialmente visible en la crisis de
              1998–1999 y en el ciclo restrictivo de 2021–2023— genera incertidumbre en la planificación
              financiera y en la inversión productiva."),
            p("La pregunta central de análisis es:"),
            tags$blockquote(
              style = "border-left: 4px solid #d9534f; padding-left: 16px; font-style: italic; color: #333;",
              "¿Cómo han evolucionado las tasas de interés de colocación en Colombia entre 1998 y 2025,
               qué diferencias existen entre modalidades de crédito, y es posible proyectar su
               comportamiento a corto plazo mediante modelos de series de tiempo?"
            )
        )
      )
    ),
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Brecha entre modalidades de crédito — Exploración interactiva",
            fluidRow(
              column(4,
                tags$div(
                  style = "position:relative; z-index:200;",
                  tags$div(
                    style = "background:#1a1714; border:1px solid rgba(245,158,11,0.18); border-radius:8px; padding:14px; margin-bottom:10px;",
                    selectInput(ns("serie1"), "Serie A:",
                                choices  = c("Consumo","Tesoreria","Ordinarios",
                                             "Preferenciales","BancoRepublica","SinTesoreria","Total"),
                                selected = "Consumo",
                )
                  )
                ),
                tags$div(
                  style = "position:relative; z-index:100;",
                  tags$div(
                    style = "background:#1a1714; border:1px solid rgba(245,158,11,0.18); border-radius:8px; padding:14px; margin-bottom:10px;",
                    selectInput(ns("serie2"), "Serie B:",
                                choices  = c("Consumo","Tesoreria","Ordinarios",
                                             "Preferenciales","BancoRepublica","SinTesoreria","Total"),
                                selected = "BancoRepublica",
                )
                  )
                ),
                tags$div(
                  style = "background:#1a1714; border:1px solid rgba(245,158,11,0.18); border-radius:8px; padding:14px;",
                  sliderInput(ns("rango"), "Período:",
                              min        = as.Date("1998-04-01"),
                              max        = as.Date("2025-08-01"),
                              value      = c(as.Date("1998-04-01"), as.Date("2025-08-01")),
                              timeFormat = "%Y", step = 365)
                )
              ),
              column(8,
                plotlyOutput(ns("grafico_brecha"), height = "380px")
              )
            )
        )
      )
    )
  )
}

mod_problema_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {
    df <- reactive({ if (is.reactive(datos)) datos() else datos })

    datos_filtrado <- reactive({
      df() %>%
        filter(Fecha >= input$rango[1], Fecha <= input$rango[2])
    })

    output$grafico_brecha <- renderPlotly({
      df <- datos_filtrado()
      s1 <- input$serie1
      s2 <- input$serie2

      colores <- c("#f59e0b", "#fcd34d", "#d97706", "#a89472",
                   "#fcd34d", "#92400e", "#f59e0b")
      nombres <- c("Consumo","Tesoreria","Ordinarios","Preferenciales",
                   "BancoRepublica","SinTesoreria","Total")
      col1 <- colores[match(s1, nombres)]
      col2 <- colores[match(s2, nombres)]

      plot_ly() %>%
        add_trace(data = df, x = ~Fecha, y = ~get(s1),
                  type = "scatter", mode = "lines",
                  name = s1, line = list(color = col1, width = 2),
                  hovertemplate = paste0(s1, ": %{y:.2f}%<extra></extra>")) %>%
        add_trace(data = df, x = ~Fecha, y = ~get(s2),
                  type = "scatter", mode = "lines",
                  name = s2, line = list(color = col2, width = 2, dash = "dash"),
                  hovertemplate = paste0(s2, ": %{y:.2f}%<extra></extra>")) %>%
        layout(
          title = list(text = paste("Comparación:", s1, "vs", s2), font = list(size = 13)),
          xaxis = list(title = "Fecha", showgrid = FALSE),
          yaxis = list(title = "Tasa (%)"),
          legend = list(orientation = "h", y = -0.15),
          paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"),
          plot_bgcolor  = "rgba(0,0,0,0)"
        )
    })

  })
}
