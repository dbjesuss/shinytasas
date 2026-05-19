# modules/mod_resultados.R

mod_resultados_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    tabsetPanel(

      tabPanel("Series temporales",
        br(),
        fluidRow(
          column(3,
            checkboxGroupInput(ns("series_sel"), "Series a mostrar:",
                               choices = c("Consumo","Tesoreria","Ordinarios",
                                           "Preferenciales","BancoRepublica","SinTesoreria","Total"),
                               selected = c("Consumo","BancoRepublica","Total")),
            hr(),
            radioButtons(ns("modo_series"), "Vista:",
                         choices = c("Superpuestas" = "overlay", "Separadas" = "facet"),
                         selected = "overlay")
          ),
          column(9, plotlyOutput(ns("grafico_series"), height = "420px"))
        )
      ),

      tabPanel("Estadísticos descriptivos",
        br(),
        fluidRow(column(12, DTOutput(ns("tabla_stats")))),
        br(),
        fluidRow(column(12, plotlyOutput(ns("boxplot_series"), height = "380px")))
      ),

      tabPanel("Distribuciones",
        br(),
        fluidRow(
          column(3,
            selectInput(ns("serie_hist"), "Serie:",
                        choices = c("Consumo","Tesoreria","Ordinarios","Preferenciales",
                                    "BancoRepublica","SinTesoreria","Total"),
                        selected = "Total"),
            sliderInput(ns("n_bins"), "Barras:", min = 10, max = 60, value = 30),
            hr(),
            checkboxInput(ns("show_density"), "Superponer densidad", value = TRUE)
          ),
          column(9, plotlyOutput(ns("histograma"), height = "400px"))
        )
      ),

      tabPanel("Correlación de Spearman",
        br(),
        fluidRow(
          column(3,
            radioButtons(ns("tipo_cor"), "Aplicar sobre:",
                         choices = c("Niveles" = "nivel", "Primera diferencia" = "diff"),
                         selected = "diff"),
            hr(),
            tags$div(style="font-size:12px; color:#a89472; background:#1a1714; padding:10px; border-radius:5px;",
              strong("Significancia:"), br(),
              "*** p < 0.001", br(), "**  p < 0.01", br(), "*   p < 0.05", br(), "ns  no significativo"
            ),
            hr(),
            uiOutput(ns("resumen_cor"))
          ),
          column(9, plotlyOutput(ns("corrplot_spearman"), height = "500px"))
        )
      )
    )
  )
}

mod_resultados_server <- function(id, datos, modelo) {
  moduleServer(id, function(input, output, session) {

    df <- reactive({ if (is.reactive(datos)) datos() else datos })

    vars       <- c("Consumo","Tesoreria","Ordinarios","Preferenciales","BancoRepublica","SinTesoreria","Total")
    labels_vars <- c("Consumo","Tesorería","Ordinarios","Preferenciales","BR","Sin Tes.","Total")
    colores    <- c("Consumo"        = "#f59e0b",
                    "Tesoreria"      = "#d4a843",
                    "Ordinarios"     = "#d97706",
                    "Preferenciales" = "#a89472",
                    "BancoRepublica" = "#fcd34d",
                    "SinTesoreria"   = "#92400e",
                    "Total"          = "#fff3cd")

    # ── Series temporales (bug fix modo separadas) ────────────────────────────
    output$grafico_series <- renderPlotly({
      req(input$series_sel)
      d <- df()

      if (input$modo_series == "overlay") {
        p <- plot_ly()
        for (s in input$series_sel) {
          p <- add_trace(p,
                         x    = d$Fecha,
                         y    = d[[s]],
                         type = "scatter", mode = "lines", name = s,
                         line = list(color = colores[s], width = 1.8),
                         hovertemplate = paste0(s, ": %{y:.2f}%<extra></extra>"))
        }
        p %>% layout(
          title  = "Tasas de colocación — Colombia",
          xaxis  = list(title = "", showgrid = FALSE),
          yaxis  = list(title = "Tasa (%)", gridcolor = "rgba(245,158,11,0.1)"),
          legend = list(orientation = "h", y = -0.12),
          paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"), plot_bgcolor  = "#0c0a09"
        )
      } else {
        # Subplots separados, uno por serie
        plots <- lapply(input$series_sel, function(s) {
          plot_ly(x = d$Fecha, y = d[[s]],
                  type = "scatter", mode = "lines", name = s,
                  line = list(color = colores[s], width = 1.8),
                  hovertemplate = paste0(s, ": %{y:.2f}%<extra></extra>")) %>%
            layout(
              annotations = list(list(
                x = 0.01, y = 1.02, xref = "paper", yref = "paper",
                text = paste0("<b>", s, "</b>"), showarrow = FALSE,
                font = list(size = 11, color = colores[s])
              )),
              yaxis = list(title = "", gridcolor = "rgba(245,158,11,0.1)"),
              xaxis = list(showgrid = FALSE)
            )
        })
        n <- length(plots)
        subplot(plots, nrows = n, shareX = TRUE, titleY = FALSE) %>%
          layout(
            showlegend = FALSE,
            paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"), plot_bgcolor  = "#0c0a09",
            margin = list(l=40, r=10, t=10, b=40)
          )
      }
    })

    # ── Estadísticos ──────────────────────────────────────────────────────────
    output$tabla_stats <- renderDT({
      stats <- do.call(rbind, lapply(vars, function(v) {
        x <- df()[[v]]
        data.frame(
          Serie   = v,
          Media   = round(mean(x, na.rm=TRUE), 2),
          Mediana = round(median(x, na.rm=TRUE), 2),
          DE      = round(sd(x, na.rm=TRUE), 2),
          Min     = round(min(x, na.rm=TRUE), 2),
          Max     = round(max(x, na.rm=TRUE), 2),
          CV_pct  = round(sd(x, na.rm=TRUE)/mean(x, na.rm=TRUE)*100, 1)
        )
      }))
      datatable(stats, rownames = FALSE,
                colnames = c("Serie","Media","Mediana","D.E.","Mín","Máx","CV (%)"),
                options = list(dom = "t", pageLength = 10),
                class = "stripe hover") %>%
        formatStyle("Serie", fontWeight = "bold")
    })

    output$boxplot_series <- renderPlotly({
      df_long <- df() %>%
        select(Fecha, all_of(vars)) %>%
        pivot_longer(-Fecha, names_to = "Serie", values_to = "Tasa")
      col_gris <- setNames(rep("#92400e", length(vars)), vars)
      plot_ly(df_long, x = ~Serie, y = ~Tasa, color = ~Serie, colors = col_gris,
              type = "box", hovertemplate = "%{y:.2f}%<extra></extra>") %>%
        layout(title = "Distribución por modalidad",
               xaxis = list(title = "", showgrid = FALSE),
               yaxis = list(title = "Tasa (%)", gridcolor = "rgba(245,158,11,0.1)"),
               showlegend = FALSE,
               paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"), plot_bgcolor  = "#0c0a09")
    })

    # ── Histograma + densidad ─────────────────────────────────────────────────
    output$histograma <- renderPlotly({
      s <- input$serie_hist
      x <- df()[[s]]; x <- x[!is.na(x)]
      p <- plot_ly() %>%
        add_histogram(x = x, nbinsx = input$n_bins,
                      marker = list(color = colores[s],
                                    line = list(color = "white", width = 0.5)),
                      name = "Frecuencia",
                      hovertemplate = "Rango: %{x:.1f}%<br>n: %{y}<extra></extra>")
      if (input$show_density) {
        dens  <- density(x)
        bin_w <- (max(x) - min(x)) / input$n_bins
        p <- add_lines(p, x = dens$x, y = dens$y * length(x) * bin_w,
                       name = "Densidad",
                       line = list(color = "#f0ebe0", width = 2),
                       hovertemplate = "Densidad: %{y:.2f}<extra></extra>")
      }
      p %>% layout(title = paste("Distribución —", s),
                   xaxis = list(title = "Tasa (%)"), yaxis = list(title = "Frecuencia"),
                   barmode = "overlay",
                   paper_bgcolor = "#0c0a09",
          font = list(color = "#a89472", family = "Poppins"), plot_bgcolor  = "#0c0a09")
    })

    # ── Correlación Spearman ──────────────────────────────────────────────────
    df_cor <- reactive({
      d <- df()[, vars]
      if (input$tipo_cor == "diff") {
        d <- as.data.frame(lapply(d, function(x) c(NA, diff(x))))
        d <- d[complete.cases(d), ]
      }
      d
    })

    matrices_spearman <- reactive({
      d <- df_cor(); n <- length(vars)
      mat_r <- diag(1, n); dimnames(mat_r) <- list(vars, vars)
      mat_p <- diag(0, n); dimnames(mat_p) <- list(vars, vars)
      for (i in seq_len(n)) for (j in seq_len(n)) if (i != j) {
        t <- cor.test(d[[vars[i]]], d[[vars[j]]], method = "spearman", exact = FALSE)
        mat_r[i,j] <- round(t$estimate, 3)
        mat_p[i,j] <- t$p.value
      }
      list(r = mat_r, p = mat_p)
    })

    output$corrplot_spearman <- renderPlotly({
      m <- matrices_spearman(); r <- m$r; pv <- m$p; n <- length(vars)

      sig_label <- function(p) {
        if      (p < 0.001) "***"
        else if (p < 0.01)  "** "
        else if (p < 0.05)  "*  "
        else                "ns "
      }

      # Texto: r + significancia
      texto <- matrix("", n, n)
      for (i in seq_len(n)) for (j in seq_len(n)) {
        if (i == j) {
          texto[i,j] <- "1.000"
        } else {
          texto[i,j] <- paste0(sprintf("%.3f", r[i,j]), "\n", sig_label(pv[i,j]))
        }
      }

      tipo_txt <- if (input$tipo_cor == "diff") "Primera Diferencia" else "Niveles"

      plot_ly(
        z    = r,
        x    = labels_vars,
        y    = labels_vars,
        type = "heatmap",
        text = texto,
        texttemplate = "%{text}",
        # Blanco puro — máximo contraste sobre cualquier tono del degradado dorado
        textfont = list(size = 11.5, color = "#ffffff", family = "Poppins"),
        colorscale = list(
          list(0.00, "#1a0a00"),
          list(0.25, "#3d1f00"),
          list(0.50, "#0c0a09"),
          list(0.75, "#78350f"),
          list(1.00, "#b45309")   # dorado más oscuro para que el blanco contraste
        ),
        zmin = -1, zmax = 1,
        colorbar = list(
          title       = list(text = "r", font = list(color = "#a89472", size = 12)),
          tickvals    = c(-1, -0.5, 0, 0.5, 1),
          tickfont    = list(color = "#a89472", size = 10),
          outlinecolor = "rgba(245,158,11,0.2)",
          bgcolor     = "#1a1714",
          bordercolor = "rgba(245,158,11,0.25)"
        ),
        hovertemplate = "<b>%{y} x %{x}</b><br>r = %{z:.3f}<extra></extra>"
      ) %>%
        layout(
          title  = list(
            text = paste0("Correlacion de Spearman — ", tipo_txt,
                          "<br><sup>*** p&lt;0.001  ** p&lt;0.01  * p&lt;0.05  ns no significativo</sup>"),
            font = list(size = 12, color = "#fcd34d")
          ),
          xaxis  = list(tickangle = -35, tickfont = list(size = 11, color = "#a89472"),
                        title = "", showgrid = FALSE),
          yaxis  = list(tickfont = list(size = 11, color = "#a89472"),
                        title = "", autorange = "reversed", showgrid = FALSE),
          margin        = list(l = 90, r = 30, t = 80, b = 110),
          paper_bgcolor = "#0c0a09",
          plot_bgcolor  = "#0c0a09",
          font          = list(color = "#a89472", family = "Poppins")
        )
    })

    output$resumen_cor <- renderUI({
      m <- matrices_spearman(); n <- length(vars)
      cnt <- sum(m$p[upper.tri(m$p)] < 0.05); tot <- n*(n-1)/2
      tags$div(style="font-size:12px; color:#a89472;",
        strong("Pares significativos"), br(),
        tags$span(style="font-size:20px; font-weight:700; color:#f59e0b;", cnt),
        paste0(" de ", tot), br(), br(), em("(p < 0.05, Spearman)"))
    })

  })
}
