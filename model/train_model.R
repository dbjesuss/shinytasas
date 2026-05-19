# model/train_model.R — Entrenamiento del modelo ARIMA para tasa Total

library(readxl)
library(dplyr)
library(lubridate)
library(forecast)

# Carga de datos
datos_raw <- read_excel("data/tasas_interes.xlsx",
                        sheet = "Series de datos",
                        skip = 5,
                        col_names = c("Fecha", "Consumo", "Tesoreria",
                                      "Ordinarios", "Preferenciales",
                                      "BancoRepublica", "SinTesoreria", "Total"))

datos <- datos_raw %>%
  mutate(Fecha = as.Date(as.numeric(Fecha), origin = "1899-12-30")) %>%
  filter(!is.na(Fecha), !is.na(Total)) %>%
  mutate(Total = as.numeric(Total)) %>%
  filter(!is.na(Total)) %>%
  arrange(Fecha)

# Serie temporal mensual
ts_total <- ts(datos$Total,
               start = c(year(min(datos$Fecha)), month(min(datos$Fecha))),
               frequency = 12)

# Ajuste automático ARIMA
set.seed(42)
modelo_arima <- auto.arima(ts_total, seasonal = TRUE, stepwise = TRUE, approximation = TRUE)

# Guardar modelo
saveRDS(modelo_arima, "model/modelo_arima.rds")
message("Modelo ARIMA entrenado y guardado en model/modelo_arima.rds")
message(summary(modelo_arima))
