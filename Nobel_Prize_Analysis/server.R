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
library(timeDate)
library(DT)

source("ST558_Project_2.R")

# Define server logic required to provide output
function(input, output, session) {

  nobel_raw_data <- get_laureate_data()
  nobel_clean_data <- clean_laureate(nobel_raw_data)
  
  nobel_clean_cat <- reactive({
    req("input$category_sel")
    nobel_cat <- nobel_clean_data |>
      filter(Category == input$category_sel)
  })
  
    #Keep seeing that the below download Handler only returns an html file.
    output$download_button <- downloadHandler(
      filename = paste0("Nobel_", input$category_sel, ".csv"),
      content = write_csv(nobel_clean_cat(), "ST558_Project_2"),
      contentType = "text/csv"
      )
    
    output$birth_hist <- renderPlot({
      gg <- ggplot(nobel_clean_cat(), aes(Birth_Country_Now))
      gg + geom_bar(aes(colour = factor(Birth_Continent))) +
        labs(x = "Birth Country Now",
             y = "Number of Recipients",
             title = paste0(input$category_sel, " Prizes Awarded per Birth Country")) +
        theme(axis.text.x = element_text(angle = 90),
              panel.background = element_rect(fill = "gray"),
              legend.title = element_blank())
    })
    
    perc_fem_table <- reactive({
      nobel_clean_cat() |>
        group_by(Birth_Country_Now) |>
        summarise(Total_Recipients = n(),
                  Perc_Fem = (sum(gender == "female")/n())*100) |>
        arrange(desc(Perc_Fem)) |>
        ungroup()
    })
    
    output$contingency_table <- renderDT({
      datatable(perc_fem_table(),
                options = list(pageLength = 10),
                colnames = list("Birth Country",
                                "Total # Recipients",
                                "Percent Female Recipients (%)"),
                caption = paste0("Total & Female Percent of Nobel ",
                input$category_sel, " Prize Recepients by Birth Country"),
                rownames = FALSE)
    })
    
    
    output$prizeplot <- renderPlot({
      m <- ggplot(nobel_clean_data, aes(awardYear, prizeAmountAdjusted))
      m +
        geom_point() +
        labs(x = "Nobel Award Year",
             y = "Prize Amount Adjusted to Current SEK",
             title = "Adjusted Nobel Prize SEK Amounts by Year") +
        scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
        scale_y_continuous(labels = scales::comma) +
        theme(panel.background = element_rect(fill = "gray"))
    })
    
    r <- reactive({
      nobel_clean_data |>
        group_by(awardYear) |>
        summarise(Num_Recipients = n()) |>
        ungroup()
    })
    
    output$rec_plot <- renderPlot({
      n <- ggplot(r(), aes(awardYear, Num_Recipients))
      n + geom_point() +
        labs(x = "Nobel Award Year",
             y = "Number of Recipients",
             title = "Number of Prize Recipients Over Time") +
        scale_x_discrete(guide = guide_axis(check.overlap = TRUE))
    })
}
