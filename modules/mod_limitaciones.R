# modules/mod_limitaciones.R

mod_limitaciones_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(6,
        box(width=12, status="danger", solidHeader=TRUE,
            title="Limitaciones del estudio",
            tags$ol(
              tags$li(strong("Datos promedio agregados:"), " las tasas publicadas por el Banco de la República
                son promedios ponderados; no reflejan la dispersión entre entidades financieras individuales."),
              tags$li(strong("Modelo univariado:"), " el modelo ARIMA analiza únicamente la tasa total.
                No incorpora variables macroeconómicas exógenas como inflación, tasa de cambio o PIB."),
              tags$li(strong("Quiebres estructurales:"), " los eventos atípicos (crisis 1999, COVID-19,
                ciclo 2022–2023) pueden deteriorar la capacidad predictiva del modelo."),
              tags$li(strong("Horizonte limitado:"), " los pronósticos ARIMA son confiables principalmente
                en el corto plazo (1–6 meses). A mayor horizonte, los intervalos de confianza se amplían significativamente."),
              tags$li(strong("Datos faltantes:"), " algunas series presentan valores ausentes en períodos
                específicos, lo que puede afectar los estimadores de correlación."),
              tags$li(strong("Estacionalidad:"), " aunque ", code("auto.arima()"), " puede detectar estacionalidad,
                las tasas de interés no siempre presentan patrones estacionales robustos.")
            )
        )
      ),
      column(6,
        box(width=12, status="warning", solidHeader=TRUE,
            title="Recomendaciones para trabajo futuro",
            tags$ul(
              tags$li("Incorporar modelos multivariados (VAR, VECM) que incluyan inflación y tasa de política."),
              tags$li("Aplicar modelos con cambios de régimen (Markov-Switching) para capturar quiebres estructurales."),
              tags$li("Desagregar el análisis por entidad financiera cuando los datos estén disponibles."),
              tags$li("Evaluar modelos de machine learning (LSTM, Prophet) para series de tiempo no lineales."),
              tags$li("Extender el análisis a tasas pasivas (captación) para calcular el spread financiero.")
            )
        )
      )
    )
  )
}

mod_limitaciones_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {})
}
