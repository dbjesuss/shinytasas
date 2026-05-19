# server.R
function(input, output, session) {

  datos_filtrados <- reactive({
    req(input$fecha_global)
    datos %>%
      filter(Fecha >= input$fecha_global[1],
             Fecha <= input$fecha_global[2])
  })

  mod_introduccion_server("introduccion",  datos_filtrados, NULL)
  mod_contexto_server("contexto",          datos_filtrados, NULL)
  mod_problema_server("problema",          datos_filtrados, NULL)
  mod_objetivos_server("objetivos",        datos_filtrados, NULL)
  mod_marco_teorico_server("marco_teorico",datos_filtrados, NULL)
  mod_metodologia_server("metodologia",    datos_filtrados, NULL)
  mod_resultados_server("resultados",      datos_filtrados, NULL)
  mod_arima_server("arima",               datos_filtrados, NULL)
  mod_rolling_server("rolling",           datos_filtrados, NULL)
  mod_conclusiones_server("conclusiones",  datos_filtrados, NULL)
}
