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
load("Dane_wyliczone.RData")
#load("Mapy.RData")

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
    
    output$mapa1 <- renderLeaflet(mapa1)
    output$mapa2 <- renderLeaflet(mapa2)
    output$mapa3 <- renderLeaflet(mapa3)
    
}

# Run the application 
shinyApp(ui = ui, server = server)
