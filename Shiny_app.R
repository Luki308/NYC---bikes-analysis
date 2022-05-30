#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(leaflet)
library(sp)
library(tigris) #geo_join

load("Dane_wyliczone.RData")
load("Mapy.RData")
load("Stacje_z_osiedlami.RData")

# Define UI for application that draws a histogram
ui <- fluidPage(
    navbarPage("Pomysły:",
    # Application title
    # titlePanel("Pomysł nr 1"),

    # Sidebar
    #sidebarLayout(
    tabPanel("1.",
        sidebarPanel(
          selectInput("month", label = "Wybierz rok",
                      choices = list("2019 - marzec",
                                     "2019 - kwiecien",
                                     "2020 - marzec",
                                     "2020 - kwiecien",
                                     "2021 - marzec",
                                     "2022 - marzec"),
                      selected = "2019")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("countPlot"),
           plotOutput("avgPlot")
        )
    ),
    tabPanel("2.",
        mainPanel(
             br(),
             h3("Mapa1"),
             leafletOutput("mapa1"),
             br(),
             h3("Mapa2"),
             leafletOutput("mapa2"),
             br(),
             h3("Mapa3"),
             leafletOutput("mapa3")
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {


    output$countPlot <- renderPlot({
        datasetInput <- switch( input$month,
                                "2019 - marzec" = wynik19m,
                                "2019 - kwiecien" = wynik19k,
                                "2020 - marzec" = wynik20m,
                                "2020 - kwiecien" = wynik20k,
                                "2021 - marzec" = wynik21,
                                "2022 - marzec" = wynik22)
        
        x <- unlist(datasetInput[,1])
        y <- unlist(datasetInput[,2])/1000

        options(scipen=9) 
        plot(x, y, ylim = c(0, 100) , type = "l", col = 'red', border = 'white'
             ,xlab = "Data", ylab = "Liczba Przejazdow [tys]", main = "Liczba przejazdów w danym okresie [tys]")
    })
    output$avgPlot <- renderPlot({
      datasetInput <- switch( input$month,
                              "2019 - marzec" = wynik19m,
                              "2019 - kwiecien" = wynik19k,
                              "2020 - marzec" = wynik20m,
                              "2020 - kwiecien" = wynik20k,
                              "2021 - marzec" = wynik21,
                              "2022 - marzec" = wynik22)
      
      x <- unlist(datasetInput[,1])
      y <- unlist(datasetInput[,3])
      
      plot(x, y, ylim = c(0,30), type = "l", col = 'red', border = 'white'
           ,xlab = "Data", ylab = "Średni czas trwania przejazdu [min]", main = "Sredni czas trwania przejazdów w danym okresie [min]")
    })
    
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
    
}

# Run the application 
shinyApp(ui = ui, server = server)





