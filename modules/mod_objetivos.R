# modules/mod_objetivos.R

mod_objetivos_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(6,
        box(width = 12, status = "primary", solidHeader = TRUE,
            title = "Objetivo general",
            p("Analizar la evolución histórica de las tasas de interés de colocación en Colombia
              durante el período 1998–2025, identificar patrones y diferencias entre modalidades
              de crédito, y generar proyecciones de corto plazo mediante un modelo ARIMA.")
        ),
        box(width = 12, status = "success", solidHeader = TRUE,
            title = "Objetivos específicos",
            tags$ol(
              tags$li("Describir la distribución estadística de cada modalidad de crédito."),
              tags$li("Identificar y contextualizar los principales quiebres estructurales de las series."),
              tags$li("Evaluar la correlación entre las distintas tasas de colocación."),
              tags$li("Ajustar un modelo ARIMA sobre la tasa total de colocación."),
              tags$li("Proyectar la tasa total a 12 meses con intervalos de confianza."),
              tags$li("Construir una interfaz interactiva para explorar y simular escenarios.")
            )
        )
      ),
      column(6,
        box(width = 12, status = "warning", solidHeader = TRUE,
            title = "Justificación",
            p("El crédito es el principal mecanismo de transmisión de la política monetaria a la
              economía real. Entender cómo se comportan las tasas activas permite a:"),
            tags$ul(
              tags$li(strong("Hogares:"), " planificar deudas de consumo y vivienda."),
              tags$li(strong("Empresas:"), " evaluar el costo de capital y proyectos de inversión."),
              tags$li(strong("Reguladores:"), " monitorear la efectividad de la política monetaria."),
              tags$li(strong("Investigadores:"), " estudiar ciclos crediticios y estabilidad financiera.")
            ),
            hr(),
            p("Este análisis contribuye a la transparencia del sistema financiero colombiano y
              a la educación económica basada en datos oficiales del Banco de la República.")
        )
      )
    )
  )
}

mod_objetivos_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {})
}
