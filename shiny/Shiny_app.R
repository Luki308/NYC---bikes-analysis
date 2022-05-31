#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
#

library(shiny)
library(ggplot2)
library(leaflet)
library(sp)
library(tigris) #geo_join


load("Dane_wyliczone.RData")
load("Marce_histogram.RData")
load("Stacje_z_osiedlami.RData")
load("Morning_maps.RData")

# Define UI for application that draws a histogram
ui <- fluidPage(
    navbarPage("Pomysły:",

    # Zakladka 1
    
    tabPanel("1.",
        verticalLayout(
          titlePanel("Badanie wpływu pandemii na ruch"),
          sidebarLayout(
            sidebarPanel(
              # Wybor
              selectInput("month", label = "Wybierz rok",
                          choices = list("2019 - marzec",
                                         "2019 - kwiecien",
                                         "2020 - marzec",
                                         "2020 - kwiecien",
                                         "2021 - marzec",
                                         "2022 - marzec"),
                          selected = "2019", width = 200), width = 4
            ),
    
            # Wykresy
            mainPanel(
               plotOutput("countPlot", width = 500),
               plotOutput("avgPlot", width = 500), width = 8
            ),
          ),
          
          # Histogramy
          fluidRow(
            column(12,align="center",
                   plotOutput("lata_count_plot", width = 500)
            )
          ),
          fluidRow(
            column(12,align="center",
                   plotOutput("lata_avg_plot", width = 500)
            )
          )
      )
    ),
    # Zakladka 2
    tabPanel("2.",
        verticalLayout(
          # Mapy Interaktywne
          fluidRow(
            column(12,align="center",
              br(),
              h3("Mapa1"),
              leafletOutput("mapa1", height = 500 , width = 800))
            ),
          fluidRow(
            column(12,align="center",
                   br(),
                   h3("Mapa2"),
                   leafletOutput("mapa2", height = 500 , width = 800))
          ),
          fluidRow(
            column(12,align="center",
                   br(),
                   h3("Mapa3"),
                   leafletOutput("mapa3", height = 500 , width = 800))
          ),
      )
    ),
    tabPanel("3.",
             verticalLayout(
               # Mapy Interaktywne - Poranek
               fluidRow(
                 column(12,align="center",
                        br(),
                        h3("Mapa Początków Tras"),
                        leafletOutput("morning_s", height = 500 , width = 800))
               ),
               fluidRow(
                 column(12,align="center",
                        br(),
                        h3("Mapa Końców Tras"),
                        leafletOutput("morning_e", height = 500 , width = 800))
               ),
               fluidRow(
                 column(12,align="center",
                        br(),
                        h3("Tabelka pokazująca gdzie jest co najmniej 60% więcej
                           poczatków podróży niż konców (>2000 przejazdow)"),
                        tableOutput("morning_compare"))
               )
             )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    # Wybor - wykres_count
    output$countPlot <- renderPlot({
        datasetInput <- switch( input$month,
                                "2019 - marzec" = wynik19m,
                                "2019 - kwiecien" = wynik19k,
                                "2020 - marzec" = wynik20m,
                                "2020 - kwiecien" = wynik20k,
                                "2021 - marzec" = wynik21m,
                                "2022 - marzec" = wynik22m)
        
        x <- unlist(datasetInput[,1])
        y <- unlist(datasetInput[,2])/1000

        options(scipen=9) 
        plot(x, y, ylim = c(0, 100) , type = "l", col = 'red', border = 'white'
             ,xlab = "Data", ylab = "Liczba Przejazdow [tys]", main = "Liczba przejazdów w danym okresie [tys]")
    })
    # Wybor - wykres_avg
    output$avgPlot <- renderPlot({
      datasetInput <- switch( input$month,
                              "2019 - marzec" = wynik19m,
                              "2019 - kwiecien" = wynik19k,
                              "2020 - marzec" = wynik20m,
                              "2020 - kwiecien" = wynik20k,
                              "2021 - marzec" = wynik21m,
                              "2022 - marzec" = wynik22m)
      
      x <- unlist(datasetInput[,1])
      y <- unlist(datasetInput[,3])
      
      plot(x, y, ylim = c(0,31), type = "l", col = 'red', border = 'white'
           ,xlab = "Data", ylab = "Średni czas trwania przejazdu [min]", main = "Sredni czas trwania przejazdów w danym okresie [min]")
    })
    
    
    # Histogramy
    output$lata_count_plot <- renderPlot(lata_count_plot)
    output$lata_avg_plot <- renderPlot(lata_avg_plot)
    
    
    # Mapy interaktywne
    output$mapa1 <- renderLeaflet({plot_data <- geo_join(nyc_neighborhoods, ilosc_w_neighborhood,
                                                        "neighborhood", "neighborhood",
                                                        how = 'inner')
                                  
                                  pal <- colorNumeric(palette = heat.colors(10,rev = T),
                                                      domain = range(plot_data@data$Count, na.rm=T))
                                  
                                  leaflet(plot_data) %>%
                                    addTiles() %>%
                                    addPolygons(color = "black", weight = 1 , opacity = 1,
                                                fillColor = ~pal(Count), fillOpacity = 0.9,
                                                popup = ~paste(neighborhood, "<br/> Liczba:", Count)) %>%
                                    addLegend("bottomright", pal = pal, values = ~Count,
                                              title = "Liczba stacji na osiedlach",
                                              opacity = 1
                                    ) %>%
                                    addProviderTiles("CartoDB.Positron") %>%
                                    setView(-74.00, 40.71, zoom = 12)})
    output$mapa2 <- renderLeaflet({plot_data2 <-  geo_join(nyc_neighborhoods, start_station,
                                                          "neighborhood", "neighborhood",
                                                          how = 'inner')
                                  pal2 <- colorNumeric(palette = heat.colors(10,rev = T),
                                                       domain = range(plot_data2@data$Count, na.rm=T))
                                  
                                  leaflet(plot_data2) %>%
                                    addTiles() %>%
                                    addPolygons(color = "black", weight = 1 , opacity = 1,
                                                fillColor = ~pal2(Count), fillOpacity = 0.9,
                                                popup = ~ paste(neighborhood, "<br/> Liczba:", Count)) %>%
                                    addLegend("bottomright", pal = pal2, values = ~Count,
                                              title = "Liczba przejazdow (Start)",
                                              opacity = 1
                                    ) %>%
                                    addProviderTiles("CartoDB.Positron") %>%
                                    setView(-74.00, 40.71, zoom = 12)})
    output$mapa3 <- renderLeaflet({plot_data3 <-  geo_join(nyc_neighborhoods, end_station,
                                                          "neighborhood", "neighborhood",
                                                          how = 'inner')
                                  pal3 <- colorNumeric(palette = heat.colors(10,rev = T),
                                                       domain = range(plot_data3@data$Count, na.rm=T))
                                  
                                  leaflet(plot_data3) %>%
                                    addTiles() %>%
                                    addPolygons(color = "black", weight = 1 , opacity = 1,
                                                fillColor = ~pal3(Count), fillOpacity = 0.9,
                                                popup = ~paste(neighborhood, "<br/> Liczba:", Count)) %>%
                                    addLegend("bottomright", pal = pal3, values = ~Count,
                                              title = "Liczba przejazdow (Koniec)",
                                              opacity = 1
                                    ) %>%
                                    addProviderTiles("CartoDB.Positron") %>%
                                    setView(-74.00, 40.71, zoom = 12)})
    
    
    output$morning_s <- renderLeaflet(morning_start)
    output$morning_e <- renderLeaflet(morning_end)
    output$morning_compare <- renderTable(morning_compare)
}

# Run the application 
shinyApp(ui = ui, server = server)




