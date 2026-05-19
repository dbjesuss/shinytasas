# 📊 Tasas de Interés Colombia — Shiny App

Aplicación web interactiva desarrollada en **R Shiny** para el análisis exploratorio, modelado ARIMA y evaluación de la técnica Rolling sobre las tasas de interés de colocación en Colombia (1998–2025). La app implementa un diseño personalizado **Obsidian Gold** (fondo oscuro, acentos dorados) sin depender de `shinydashboard`.

---

## 🗂 Estructura del proyecto

```
shiny_tasas/
│
├── global.R               # Librerías, carga de datos, precómputo de modelos ARIMA
├── ui.R                   # Navbar horizontal + barra de filtro global de fechas
├── server.R               # Orquestación de módulos
│
├── data/
│   └── tasas_interes.xlsx # Fuente de datos (Banco de la República / superfinanciera)
│
├── www/
│   ├── custom.css         # Tema Obsidian Gold (variables CSS, estilos globales)
│   ├── poppins.css        # Fuente local Poppins (sin CDN externo)
│   └── fix_dropdown.js    # Fix para dropdowns en navbar colapsable
│
└── modules/
    ├── mod_introduccion.R
    ├── mod_contexto.R
    ├── mod_problema.R
    ├── mod_objetivos.R
    ├── mod_marco_teorico.R
    ├── mod_metodologia.R
    ├── mod_resultados.R   # EDA: series de tiempo, correlaciones, estacionalidad
    ├── mod_arima.R        # Grid search, diagnóstico, pronóstico ARIMA(0,1,3)
    ├── mod_rolling.R      # Evaluación de supuestos + tabla de 50 combinaciones
    └── mod_conclusiones.R
```

---

## 📦 Requisitos — Paquetes de R

R **≥ 4.2.0** recomendado. Instala todas las dependencias con:

```r
install.packages(c(
  "shiny",
  "shinyWidgets",
  "plotly",
  "ggplot2",
  "dplyr",
  "tidyr",
  "lubridate",
  "readxl",
  "DT",
  "ggcorrplot",
  "tseries",
  "zoo",
  "forecast"
))
```

No se usa `shinydashboard`. Las funciones `box()` y `valueBox()` están reimplementadas en `global.R` como componentes Bootstrap nativos.

---

## ▶️ Cómo ejecutar localmente

**1. Clona el repositorio**

```bash
git clone https://github.com/tu-usuario/shiny-tasas-colombia.git
cd shiny-tasas-colombia/shiny_tasas
```

**2. Abre R o RStudio y lanza la app**

```r
shiny::runApp(".")
```

O directamente desde la raíz del repo:

```r
shiny::runApp("shiny_tasas")
```

La app abrirá en tu navegador por defecto en `http://127.0.0.1:XXXX`.

> **Nota Windows:** si tu nombre de usuario contiene espacios, `global.R` redirige automáticamente los temporales a `C:/Temp/RShiny` para evitar errores de rutas.

---

## 🗄 Datos

| Campo | Detalle |
|---|---|
| Archivo | `data/tasas_interes.xlsx` |
| Hoja | `Series de datos` |
| Periodo | Abril 1998 — Agosto 2025 |
| Frecuencia | Mensual |
| Series | Consumo, Tesorería, Ordinarios, Preferenciales, Banco República, Sin Tesorería, Total |
| Fuente | Superintendencia Financiera de Colombia / Banco de la República |

Los datos se leen en `global.R` saltando las primeras 5 filas de encabezado. Las fechas vienen en formato serial Excel y se convierten a `Date` con `origin = "1899-12-30"`.

---

## 🧭 Secciones de la app

| Pestaña | Contenido |
|---|---|
| **Introducción** | Presentación general del proyecto |
| **Contexto** | Marco macroeconómico colombiano |
| **Problema** | Planteamiento del problema de investigación |
| **Objetivos** | Objetivos general y específicos |
| **Marco Teórico** | Teoría de series de tiempo, ARIMA, Rolling |
| **Metodología** | Pipeline de análisis: EDA → ARIMA → Rolling |
| **Resultados EDA** | Series temporales interactivas, correlaciones, estacionalidad, descomposición STL |
| **ARIMA** | Grid search AIC/BIC, diagnóstico de residuos, pronóstico ARIMA(0,1,3) |
| **Rolling** | Supuestos estadísticos, ACF/PACF, tabla de 50 combinaciones (p,d,q) con p-valores reales |
| **Conclusiones** | Síntesis de hallazgos y limitaciones del modelo |

---

## 🤖 Módulo ARIMA — Detalles técnicos

- **Train/test split:** 80% entrenamiento / 20% prueba
- **Modelo seleccionado:** `ARIMA(0,1,3)` por menor AIC/BIC entre los candidatos evaluados
- **Candidatos evaluados:** `(1,1,0)`, `(0,1,1)`, `(0,1,3)`, `(1,1,1)`, `(2,1,0)`, `(0,1,2)`
- **Diagnóstico:** prueba ADF, Ljung-Box (lag=20), Shapiro-Wilk, gráfico Q-Q
- Los tres modelos principales se precalculan en `global.R` al inicio para no repetir cómputo por sesión

---

## 🔁 Módulo Rolling — Detalles técnicos

Evalúa si la técnica Rolling (pronóstico continuo con ventana deslizante) es aplicable a la serie `TasaColocacionTotal`. Se verifican 5 supuestos:

1. **Estacionariedad** — Prueba ADF
2. **Independencia** — Ljung-Box (lag=10) sobre residuos ARIMA
3. **Homocedasticidad** — inspección visual de varianza
4. **Normalidad de residuos** — Shapiro-Wilk
5. **Tamaño de muestra suficiente** — n ≥ 50

La tabla de combinaciones contiene los **50 p-valores exactos** obtenidos con Python (`statsmodels`, `scipy`) sobre la serie completa, con `d ∈ {1, 2}`, `p ∈ {0,…,4}`, `q ∈ {0,…,4}`. Todos los p-valores Ljung-Box resultaron < 0.05 → supuesto de independencia violado → **Rolling no pertinente**.

---

## 🎨 Tema visual — Obsidian Gold

El diseño no usa Bootstrap por defecto ni `shinydashboard`. Todo el estilo está en `www/custom.css`:

| Token | Valor | Uso |
|---|---|---|
| Fondo principal | `#0c0a09` | Fondo de página y gráficos |
| Fondo panel | `#1a1714` | Navbar, cajas, sidebar |
| Dorado principal | `#fcd34d` | Títulos, valores destacados |
| Dorado medio | `#f59e0b` | Ejes, bordes, acentos |
| Texto secundario | `#a89472` | Descripciones, etiquetas |
| Verde ok | `#4ade80` | Supuesto cumplido |
| Rojo falla | `#f87171` | Supuesto violado |

---

## 🚀 Despliegue en shinyapps.io

```r
# Instala rsconnect si no lo tienes
install.packages("rsconnect")

# Configura tu cuenta (solo la primera vez)
rsconnect::setAccountInfo(
  name   = "tu-cuenta",
  token  = "TU_TOKEN",
  secret = "TU_SECRET"
)

# Despliega
rsconnect::deployApp("shiny_tasas")
```

El archivo `.dcf` en `rsconnect/shinyapps.io/` ya contiene la configuración del despliegue previo. Si haces fork, elimina esa carpeta antes de desplegar en tu propia cuenta.

---

## 👤 Autor

**Jesús David Barrios**  
Proyecto académico — Análisis de Series de Tiempo  
Universidad / Programa: *[completar]*

---

## 📄 Licencia

Este proyecto es de uso académico. Los datos son de acceso público (Superintendencia Financiera de Colombia). El código puede reutilizarse con atribución.
