# modules/mod_metodologia.R

mod_metodologia_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(6,
        box(width = 12, solidHeader = TRUE,
            title = "Los datos",
          p("La informacion utilizada en este analisis proviene del sistema de series estadisticas
            del Banco de la Republica de Colombia, la entidad encargada de publicar mensualmente
            las tasas de interes activas del sistema financiero del pais."),
          p("El archivo original contiene observaciones mensuales que van desde abril de 1998 hasta
            agosto de 2025, lo que representa casi tres decadas de historia crediticia en Colombia.
            En total se trabaja con 329 registros y siete series distintas, cada una correspondiente
            a una modalidad de credito diferente: consumo, tesoreria, ordinarios, preferenciales,
            la tasa de intervencion del Banco de la Republica, el promedio sin tesoreria y la
            tasa total ponderada."),
          p("Cada observacion representa el promedio ponderado de las tasas cobradas por el conjunto
            del sistema bancario durante ese mes, expresado como porcentaje anual. Esto significa que
            los valores no corresponden a un banco en particular sino al comportamiento agregado del
            mercado.")
        )
      ),
      column(6,
        box(width = 12, solidHeader = TRUE,
            title = "Como se preparo la informacion",
          p("El archivo descargado del Banco de la Republica viene en formato Excel con cinco filas
            de encabezado antes de los datos reales, y las fechas estan almacenadas como numeros
            seriales de Excel en lugar de fechas legibles. Lo primero que se hizo fue saltar esas
            filas al momento de la lectura y convertir cada numero serial a su fecha correspondiente."),
          p("Al final del archivo aparecen notas al pie con aclaraciones sobre los datos ausentes.
            Estas filas se eliminaron porque no contienen informacion numerica y habrian generado
            errores en los calculos. De igual forma, se filtraron los registros que tuvieran
            valores faltantes en la tasa total, que es la variable central del analisis."),
          p("El resultado final es un conjunto de datos ordenado cronologicamente, con tipos de
            variables correctos y listo para ser analizado. No se imputaron valores ni se modifico
            ninguna observacion original: lo que se ve en los graficos es exactamente lo que
            publica el Banco de la Republica.")
        )
      )
    ),
    fluidRow(
      column(12,
        box(width = 12, solidHeader = TRUE,
            title = "Que se analiza y como",
          fluidRow(
            column(4,
              tags$div(style = "padding: 4px 0;",
                h4("Analisis exploratorio"),
                p("Se construyeron graficos de las series en el tiempo para entender su evolucion,
                  boxplots para comparar la dispersion entre modalidades, histogramas para ver la
                  forma de cada distribucion, y un mapa de correlacion de Spearman que mide la
                  relacion entre series sin asumir que esa relacion es lineal. Se eligio Spearman
                  sobre Pearson porque varias series presentan valores extremos que distorsionarian
                  el coeficiente clasico.")
              )
            ),
            column(4,
              tags$div(style = "padding: 4px 0;",
                h4("Pruebas de estacionariedad"),
                p("Antes de aplicar cualquier modelo de series de tiempo es necesario verificar
                  si la serie tiene una media y varianza constantes a lo largo del tiempo. Para
                  eso se aplican dos pruebas con hipotesis opuestas: ADF y KPSS. Cuando ambas
                  coinciden en su conclusion el resultado es mas confiable. Si discrepan, suele
                  indicar que la serie tiene quiebres estructurales, algo muy comun en datos
                  financieros de largo plazo.")
              )
            ),
            column(4,
              tags$div(style = "padding: 4px 0;",
                h4("Autocorrelacion"),
                p("La funcion de autocorrelacion (ACF) y la autocorrelacion parcial (PACF) permiten
                  ver si los valores de la serie en un momento dado dependen de sus valores pasados
                  y hasta que punto. Estas graficas se muestran tanto para la serie original como
                  para la primera diferencia, de modo que se pueda comparar el comportamiento antes
                  y despues de transformarla.")
              )
            )
          )
        )
      )
    )
  )
}

mod_metodologia_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {})
}
