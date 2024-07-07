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
    
    output$Nobel_img <- renderImage({
      img(src = "www/Alfred_Nobel_img.jpg")
    },
    deleteFile = FALSE)
    
    output$cat_text <- renderText({
      if(input$category_sel == "Chemistry") {
        "You have selected the Chemistry category"
      } else if (input$category_sel == "Economic Sciences") {
        "You have selected the Economic Sciences category"
      } else if (input$category_sel == "Literature") {
        "You have selected the Literature category"
      } else if (input$category_sel == "Peace") {
        "You have selected the Peace category"
      } else if (input$category_sel == "Physics") {
        "You have selected the Physics category"
      } else if (input$category_sel ==  "Medicine") {
        "You have selected the Medicine category"
      }
    })
    
    output$birth_hist <- renderPlot({
      
#      if(input$category_sel == "Chemistry") {
#      } else if (input$category_sel == "Economic Sciences") {
#        nobel_clean_data |>
#          filter(Category == "Economic Sciences")
#      } else if (input$category_sel == "Literature") {
#        nobel_clean_data |>
#          filter(Category == "Literature")
#      } else if (input$category_sel == "Peace") {
#        nobel_clean_data |>
#          filter(Category == "Peace")
#      } else if (input$category_sel == "Physics") {
#        nobel_clean_data |>
#          filter(Category == "Physics")
#      } else if (input$category_sel ==  "Physiology or Medicine") {
#        nobel_clean_data |>
#          filter(Category == "Physiology or Medicine")
#      }
        
        gg <- ggplot(nobel_clean_data, aes(Birth_Country))
        gg + geom_bar()
    })
    
    output$gen_table <- renderTable({
      cont_table <- table(nobel_clean_data$Birth_Country_Now,
                          nobel_clean_data$gender)
    })
    
    
    output$prizeplot <- renderPlot({
      m <- ggplot(nobel_clean_data, aes(awardYear, prizeAmountAdjusted))
      m + geom_boxplot()
    })

}
