#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(jsonlite)
library(httr)

source("ST558_Project_2.R")

nobel_raw_data <- get_laureate_data()
nobel_clean_data <- clean_laureate(nobel_raw_data)

# Define server logic required to draw a histogram
function(input, output, session) {

    nobel_raw_data <- observeEvent(input$download_button, {
      withProgress(
        message = "Please Wait",
        detail = "Downloading...",
        value = 0, {
          get_laureate_data()
        })
    })
  
    output$birth_hist <- renderPlot({
      
      gg <- ggplot(nobel_clean_data, aes(Birth_Country))
      gg + geom_bar()

    })

}
