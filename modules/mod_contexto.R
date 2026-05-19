# modules/mod_contexto.R

mod_contexto_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Contexto macroeconómico de Colombia",
            p("Las tasas de interés de colocación en Colombia han estado influenciadas por múltiples
              eventos macroeconómicos a lo largo de casi tres décadas. Su evolución refleja los ciclos
              económicos, las crisis financieras y las decisiones de política monetaria del Banco de la República."),
            hr(),
            h4("Hitos históricos clave"),
            fluidRow(
              column(4,
                tags$div(class = "event-card fade-in-card",
                  tags$div(class = "event-icon",
                  tags$svg(
                    xmlns="http://www.w3.org/2000/svg", viewBox="0 0 24 24",
                    width="20", height="20", fill="none",
                    tags$path(
                      d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z",
                      stroke="#fcd34d", `stroke-width`="2",
                      `stroke-linecap`="round", `stroke-linejoin`="round"
                    ),
                    tags$line(x1="12", y1="9", x2="12", y2="13",
                              stroke="#fcd34d", `stroke-width`="2",
                              `stroke-linecap`="round"),
                    tags$line(x1="12", y1="17", x2="12.01", y2="17",
                              stroke="#fcd34d", `stroke-width`="2",
                              `stroke-linecap`="round")
                  )
                ),
                  tags$div(class = "event-body",
                    tags$div(class = "event-title", "Crisis financiera 1998-1999"),
                    tags$div(class = "event-value", "Tasas > 50%"),
                    tags$div(class = "event-desc",  "Colapso del UPAC y crisis bancaria sistémica")
                  )
                )
              ),
              column(4,
                tags$div(class = "event-card fade-in-card",
                  tags$div(class = "event-icon",
                    tags$svg(
                      xmlns="http://www.w3.org/2000/svg", viewBox="0 0 24 24",
                      width="20", height="20", fill="none",
                      tags$polyline(
                        points="23 6 13.5 15.5 8.5 10.5 1 18",
                        stroke="#fcd34d", `stroke-width`="2",
                        `stroke-linecap`="round", `stroke-linejoin`="round"
                      ),
                      tags$polyline(
                        points="17 6 23 6 23 12",
                        stroke="#fcd34d", `stroke-width`="2",
                        `stroke-linecap`="round", `stroke-linejoin`="round"
                      )
                    )
                  ),
                  tags$div(class = "event-body",
                    tags$div(class = "event-title", "Estabilización 2002-2006"),
                    tags$div(class = "event-value", "Tasas ~15%"),
                    tags$div(class = "event-desc",  "Recuperación y consolidación del sistema financiero")
                  )
                )
              ),
              column(4,
                tags$div(class = "event-card fade-in-card",
                  tags$div(class = "event-icon",
                  tags$svg(
                    xmlns="http://www.w3.org/2000/svg", viewBox="0 0 24 24",
                    width="20", height="20", fill="none",
                    tags$path(
                      d="M3 11l.5-3.5A2 2 0 015.47 6h13.06a2 2 0 011.97 1.5L21 11",
                      stroke="#fcd34d", `stroke-width`="2",
                      `stroke-linecap`="round", `stroke-linejoin`="round"
                    ),
                    tags$path(
                      d="M3 11s1 6 9 6 9-6 9-6",
                      stroke="#fcd34d", `stroke-width`="2",
                      `stroke-linecap`="round", `stroke-linejoin`="round"
                    ),
                    tags$line(x1="8", y1="14", x2="16", y2="14",
                              stroke="#fcd34d", `stroke-width`="1.5",
                              `stroke-linecap`="round"),
                    tags$line(x1="9", y1="16.5", x2="15", y2="16.5",
                              stroke="#fcd34d", `stroke-width`="1.5",
                              `stroke-linecap`="round")
                  )
                ),
                  tags$div(class = "event-body",
                    tags$div(class = "event-title", "Pandemia COVID-19"),
                    tags$div(class = "event-value", "2020"),
                    tags$div(class = "event-desc",  "Caída histórica de tasas por estímulo monetario")
                  )
                )
              )
            )
        )
      )
    ),
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Evolución histórica — Tasa Total de Colocación",
            plotlyOutput(ns("grafico_contexto"), height = "400px")
        )
      )
    )
  )
}

mod_contexto_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {
    df <- reactive({ if (is.reactive(datos)) datos() else datos })

    output$grafico_contexto <- renderPlotly({
      anotaciones <- list(
        list(x = "1999-01-01", y = 52, text = "Crisis 1999", showarrow = TRUE,
             arrowcolor = "#fcd34d", arrowhead = 2, ax = 40, ay = -40,
             font = list(size = 10, color = "#fcd34d")),
        list(x = "2008-09-01", y = 20, text = "Crisis global 2008", showarrow = TRUE,
             arrowcolor = "#f59e0b", arrowhead = 2, ax = -60, ay = -30,
             font = list(size = 10, color = "#f59e0b")),
        list(x = "2020-06-01", y = 10, text = "COVID-19", showarrow = TRUE,
             arrowcolor = "#d97706", arrowhead = 2, ax = 40, ay = -40,
             font = list(size = 10, color = "#d97706")),
        list(x = "2022-06-01", y = 16, text = "Ciclo alcista 2022", showarrow = TRUE,
             arrowcolor = "#a89472", arrowhead = 2, ax = -50, ay = -30,
             font = list(size = 10, color = "#a89472"))
      )
      plot_ly(df(), x = ~Fecha, y = ~Total, type = "scatter", mode = "lines",
              line = list(color = "#f59e0b", width = 2.2),
              name = "Tasa Total",
              hovertemplate = "%{x|%b %Y}<br>%{y:.2f}%<extra></extra>") %>%
        layout(
          title       = list(text = "Tasa de Colocación Total (%) — Colombia 1998–2025",
                             font = list(size = 13, color = "#fcd34d")),
          xaxis       = list(title = "", showgrid = FALSE, color = "#a89472",
                             tickfont = list(color = "#a89472")),
          yaxis       = list(title = "Tasa (%)", gridcolor = "rgba(245,158,11,0.1)",
                             color = "#a89472", tickfont = list(color = "#a89472")),
          annotations = anotaciones,
          paper_bgcolor = "#0c0a09",
          plot_bgcolor  = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins")
        )
    })
  })
}
