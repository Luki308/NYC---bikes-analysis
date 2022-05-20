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
#source("PD3.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Pomysł nr 1"),

    # Sidebar
    sidebarLayout(
        sidebarPanel(
          selectInput("month", label = "Miesiac",
                      choices = list("2019",
                                     "2020",
                                     "2022"),
                      selected = "2019")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("countPlot"),
           plotOutput("avgPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {


    output$countPlot <- renderPlot({
        datasetInput <- switch( input$month,
                                "2019" = wynik19,
                                "2020" = wynik20,
                                "2022" = wynik22)
        
        x <- as.Date(unlist(datasetInput[,1]))
        y <- unlist(datasetInput[,2])/1000

        options(scipen=9) 
        plot(x, y, ylim = c(0, 100) , type = "l", col = 'red', border = 'white'
             ,xlab = "Data", ylab = "Liczba Przejazdow [tys]", main = "Liczba przejazdów w marcu danego roku [tys]")
    })
    output$avgPlot <- renderPlot({
      datasetInput <- switch( input$month,
                              "2019" = wynik19,
                              "2020" = wynik20,
                              "2022" = wynik22)
      
      x <- as.Date(unlist(datasetInput[,1]))
      y <- unlist(datasetInput[,3])
      
      plot(x, y, ylim = c(0,30), type = "l", col = 'red', border = 'white'
           ,xlab = "Data", ylab = "Średni czas trwania przejazdu [min]", main = "Sredni czas trwania przejazdów w marcu danego roku [min]")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
