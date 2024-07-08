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
library(xtable)

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
    
#    nobel_clean_cat <- reactive({
#      req("input$category_sel")
#      if(input$category_sel == "Chemistry") {
#        nobel_cat <- nobel_clean_data |>
#          filter(Category == "Chemistry")
#      } else if (input$category_sel == "Economic Sciences") {
#        nobel_cat <- nobel_clean_data |>
#          filter(Category == "Economic Sciences")
#      } else if (input$category_sel == "Literature") {
#        nobel_cat <- nobel_clean_data |>
#          filter(Category == "Literature")
#      } else if (input$category_sel == "Peace") {
#        nobel_cat <- nobel_clean_data |>
#          filter(Category == "Peace")
#      } else if (input$category_sel == "Physics") {
#        nobel_cat <- nobel_clean_data |>
#          filter(Category == "Physics")
#      } else if (input$category_sel ==  "Medicine") {
#        nobel_cat <- nobel_clean_data |>
#          filter(Category == "Medicine")
#      }
#    })
    
    output$birth_hist <- renderPlot({
      gg <- ggplot(nobel_clean_data, aes(Birth_Country_Now))
      gg + geom_bar(aes(colour = factor(Birth_Continent))) +
        labs(x = "Birth Country Now",
             y = "Number of Recipients",
             title = "Chemistry Prizes Awarded per Birth Country") +
        theme(axis.text.x = element_text(angle = 90),
              panel.background = element_rect(fill = "gray"))
    })
    
    output$gen_table <- renderTable({
#      if (input$category_sel == "Chemistry") {
#        nobel_clean_data |>
#          filter(Category == "Chemistry") |>
#          table(Birth_Country_Now, gender)
#      }
      cont_table <- table(nobel_clean_data$Birth_Country_Now,
                                 nobel_clean_data$gender)
    })
    
    
    output$prizeplot <- renderPlot({
      m <- ggplot(nobel_clean_data, aes(awardYear, prizeAmountAdjusted))
      m +
        geom_point() +
        labs(x = "Nobel Award Year",
             y = "Prize Amount Adjusted to Current USD",
             title = "Adjusted Nobel Prize $ Amounts by Year") +
        scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
        scale_y_continuous(labels = scales::comma) +
        theme(panel.background = element_rect(fill = "gray"))
    })

}
