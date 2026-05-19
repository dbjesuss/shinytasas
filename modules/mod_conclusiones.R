# modules/mod_conclusiones.R

mod_conclusiones_ui <- function(id) {
  ns <- NS(id)
  fluidPage(

    fluidRow(
      column(8,

        box(width = 12, solidHeader = TRUE,
            title = "Lo que encontramos",
          p("Colombia lleva casi tres decadas construyendo un sistema financiero mas estable,
            y las tasas de colocacion lo reflejan. El pico que se vivio entre 1998 y 1999,
            cuando las tasas superaron el 50%, fue el resultado de una crisis bancaria profunda
            que transformo la forma en que el pais regula y supervisa su sector financiero.
            Desde entonces la tendencia ha sido de descenso gradual, con algunos repuntes
            puntuales que coinciden con momentos de tension global o decisiones de politica
            monetaria interna."),
          p("Lo que mas llama la atencion al revisar los datos es la brecha persistente entre
            las distintas modalidades de credito. Los creditos de consumo son consistentemente
            los mas caros para el usuario final, mientras que los creditos preferenciales
            —destinados a empresas con alta solvencia— se mantienen varios puntos por debajo.
            Esa diferencia no es un dato menor: habla de como el riesgo percibido moldea el
            precio del dinero y de que no todos los colombianos ni todas las empresas acceden
            al credito en las mismas condiciones."),
          p("El ciclo restrictivo que empezo en 2022 fue el mas rapido de los ultimos veinte
            anos. En menos de dos anos las tasas subieron mas de diez puntos porcentuales,
            una respuesta agresiva del Banco de la Republica frente a la inflacion mas alta
            que habia vivido el pais en decadas. Ver ese movimiento graficado contra toda la
            historia de la serie le da una dimension que los titulares de prensa no transmiten.")
        ),

        box(width = 12, solidHeader = TRUE,
            title = "Sobre el modelo ARIMA",
          p("Ajustar un modelo ARIMA sobre la tasa total fue el ejercicio central de este
            trabajo en terminos cuantitativos. El modelo ARIMA(0,1,3) resulto ser el mejor
            de los dos evaluados, aunque sus metricas en el conjunto de prueba muestran que
            predecir esta serie con precision no es sencillo. El MAPE elevado y el R² negativo
            no son un fracaso del modelo sino una caracteristica de la serie: una variable
            financiera que responde a decisiones de politica, shocks externos y expectativas
            de mercado es dificil de predecir con modelos lineales univariados."),
          p("Lo que si hace bien el modelo es capturar la tendencia de fondo. Cuando la tasa
            lleva varios meses subiendo, el modelo la proyecta subiendo. Cuando se estabiliza,
            el modelo tiende a aplanarse. Para un horizonte de uno o dos meses, eso puede
            ser suficientemente util como punto de referencia. Para horizontes mas largos,
            o para capturar cambios bruscos de direccion, haria falta incorporar variables
            externas o explorar arquitecturas mas flexibles como los modelos de machine learning.")
        )

      ),
      column(4,

        box(width = 12, solidHeader = TRUE,
            title = "Para seguir explorando",
          p("Este analisis trabaja con promedios del sistema. Eso es util para entender
            el comportamiento agregado del mercado, pero oculta diferencias importantes
            entre entidades. Un banco con alta exposicion al credito de consumo tendra
            un perfil de tasas muy distinto a uno especializado en credito corporativo.
            Si los datos desagregados por entidad estuvieran disponibles publicamente,
            el analisis gana mucho."),
          p("Tambien quedaron por fuera variables que claramente influyen en las tasas:
            la inflacion, el tipo de cambio, el crecimiento del PIB, la cartera vencida.
            Incorporarlas en un modelo multivariado —VAR, VECM o incluso un modelo de
            machine learning— permitiria entender no solo hacia donde van las tasas sino
            por que se mueven."),
          hr(),
          tags$div(
            style = "font-size:11.5px; color:#5c5040;",
            tags$span(style="color:#a89472; font-weight:600;", "Fuente de datos"), br(),
            "Banco de la Republica de Colombia", br(),
            "Series Estadisticas — Tasas de Interes (Colocacion)", br(), br(),
            tags$a(href="https://www.banrep.gov.co", target="_blank",
                   style="color:#f59e0b;", "www.banrep.gov.co"), br(), br(),
            em("Descargado: febrero de 2026")
          )
        )

      )
    )
  )
}

mod_conclusiones_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {
    df <- reactive({ if (is.reactive(datos)) datos() else datos })
  })
}
