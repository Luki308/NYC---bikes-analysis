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


load("Dane_wyliczone2.RData")
load("Marce_histogram.RData")
load("Stacje_z_osiedlami.RData")
load("Morning_maps_data.RData")


# Define UI for application that draws a histogram
ui <- fluidPage(
    navbarPage("Pomysły:",

    # Zakladka 1
    
    tabPanel("Pandemia",
          verticalLayout(
            titlePanel("Badanie wpływu pandemii na ruch"),
            selectInput("month", label = "Wybierz rok",
                        choices = list("2019 - marzec",
                                       "2019 - kwiecien",
                                       "2020 - marzec",
                                       "2020 - kwiecien",
                                       "2021 - marzec",
                                       "2022 - marzec"),
                        selected = "2019", width = 200),
            splitLayout(
              # Wykresy
              verticalLayout(
                plotOutput("countPlot"),
                plotOutput("avgPlot"),
              ),
              # Histogramy
              verticalLayout(
                plotOutput("lata_count_plot"),
                plotOutput("lata_avg_plot")
              )
            )
          )
      ),
    # Zakladka 2
    tabPanel("Mapy Ogólne",
        verticalLayout(
            column(12,align="center",
                   br(),
                   h3("Liczba stacji na osiedlach"),
                   leafletOutput("mapa1", height = 500 , width = 800)),
            splitLayout(
              column(12,align="center",
                     br(),
                     h3("Mapa Początków Tras"),
                     leafletOutput("mapa2")),
              column(12,align="center",
                     br(),
                     h3("Mapa Końców Tras"),
                     leafletOutput("mapa3"))
            )
          )
    ),
    tabPanel("Poranne godziny szczytu",
               # Mapy Interaktywne - Poranek
              verticalLayout(
                splitLayout(
                   fluidRow(
                     column(12,align="center",
                            br(),
                            h3("Mapa Początków Tras"),
                            leafletOutput("morning_s", height = 500 , width = 800))
                   ),
                   fluidRow(
                     column(12,align="center",
                            br(),
                            h4("Tabelka pokazująca gdzie jest co najmniej 50% więcej
                             początków podróży niż końców (>10000 przejazdow)"),
                            tableOutput("morning_compare")
                            )
                   )
               ),
               splitLayout(
                 fluidRow(
                   column(12,align="center",
                          br(),
                          h3("Mapa Końców Tras"),
                          leafletOutput("morning_e", height = 500 , width = 800))
                 ),
                 fluidRow(
                   column(12,align="center",
                          br(),
                          h4("Tabelka pokazująca gdzie jest co najmniej 50% więcej
                             końców podróży niż początków (>10000 przejazdow)"),
                          tableOutput("morning_compare_end"))
                 )
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
    
    
    output$morning_s <- renderLeaflet({
        leaflet(plot_data1) %>%
        addTiles() %>%
        addPolygons(color = "black", weight = 1 , opacity = 1,
                    fillColor = ~pal(Count), fillOpacity = 0.9,
                    popup = ~paste(neighborhood, "<br/> Liczba:", Count)) %>%
        addLegend("bottomright", pal = pal, values = ~Count,
                  title = "Liczba przejazdow (Start)",
                  opacity = 1
        ) %>%
        addProviderTiles("CartoDB.Positron") %>%
        setView(-74.00, 40.71, zoom = 12) -> morning_start
      
        for(l in LETTERS[1:10]){
          morning_start <- morning_start %>%
            addPolylines(data = busy_connections[busy_connections$group == l,],
                         lng = ~Lng,
                         lat = ~Lat,
                         color = "black",#~pal2(Count),
                         opacity = 1,
                         popup = ~paste("Liczba:", Count))
        }
        morning_start})
    output$morning_e <- renderLeaflet({
        leaflet(plot_data2) %>%
        addTiles() %>%
        addPolygons(color = "black", weight = 1 , opacity = 1,
                    fillColor = ~pal(Count), fillOpacity = 0.9,
                    popup = ~paste(neighborhood, "<br/> Liczba:", Count)) %>%
        addLegend("bottomright", pal = pal, values = ~Count,
                  title = "Liczba przejazdow (Koniec)",
                  opacity = 1
        ) %>%
        addProviderTiles("CartoDB.Positron") %>%
        setView(-74.00, 40.71, zoom = 12) -> morning_end})
    output$morning_compare <- renderTable(morning_compare)
    output$morning_compare_end <- renderTable(morning_compare_end)
}

# Run the application 
shinyApp(ui = ui, server = server)


# library(rsconnect)
# rsconnect::deployApp("D:/Studia - Pobrane Wykłady/MINI/Semestr 2/PDU/PD3/shiny")

