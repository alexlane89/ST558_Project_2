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

#Defining nobel_raw_data & nobel_clean_data prior to the shiny function
#because there appear to be errors if not defined at the outset.
#Next step is to troubleshoot how to download and clean data through the app
nobel_raw_data <- get_laureate_data()
nobel_clean_data <- clean_laureate(nobel_raw_data)

# Define server logic required to draw a histogram
function(input, output, session) {

    #Keep getting an error that 'nobel_raw_data' isn't available unless
    #it's defined prior to the shiny function. This renders the below code extraneous.
    nobel_raw_data <- observeEvent(input$download_button, {
      withProgress(
        message = "Please Wait",
        detail = "Downloading...",
        value = 0, {
          get_laureate_data()
        })
    })
    
    nobel_clean_cat <- reactive({
      req("input$category_sel")
        nobel_cat <- nobel_clean_data |>
          filter(Category == input$category_sel)
    })
    
    output$birth_hist <- renderPlot({
      gg <- ggplot(nobel_clean_cat(), aes(Birth_Country_Now))
      gg + geom_bar(aes(colour = factor(Birth_Continent))) +
        labs(x = "Birth Country Now",
             y = "Number of Recipients",
             title = paste0(input$category_sel, " Prizes Awarded per Birth Country")) +
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
