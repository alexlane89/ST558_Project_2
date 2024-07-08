#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "Nobel Prize Data Analysis"),

  #Sidebar with tabs
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview"),
      menuItem("Download", tabName = "download"),
      menuItem("Analysis", tabName = "analysis")
    )
  ),
  
  #Main Display associated with each tab
  dashboardBody(
    tabItems(
      #Overview Tab content
      tabItem(tabName = "overview",
              fluidRow(
                box(h3("An Introduction to Nobel Prize Laureate Data")),
                box(h4("This app is mean to introduce and provide an overview/
                       of data related to the Nobel Prize awarded to individuals/
                       yearly since 1901 in 6 distinct categories:/
                       Chemistry/
                       Economics/
                       Literature/
                       Medicine/
                       Peace/
                       Physics/"),
                    br(),
                    h4("The Nobel Prize was created as part of Alfred Nobel's/
                       endowment, and has become one of the most prestigious/
                       prizes in any of the 6 fields described."),
                    br(),
                    h4("We will download data from the Nobel API. More/
                       information can be found at the link below"),
                    br(),
#                    tags$a(href = "https://app.swaggerhub.com/apis/NobelMedia/NobelMasterData/2.1\)",
                    ),
                img(src = "Alfred_Nobel_img.jpg")
              )),
      tabItem(tabName = "download",
              fluidRow(
                actionButton(inputId = "download_button", label = "Download Data")
              )),
      tabItem(tabName = "analysis",
              fluidRow(
                box(radioButtons(inputId = "category_sel", "Category Selection",
                             choices = c("Chemistry", "Economic Sciences",
                                         "Literature", "Medicine", "Peace",
                                         "Physics"))),
                box(plotOutput("birth_hist")),
                box(textOutput("cat_text")),
                box(tableOutput("gen_table")),
                box(plotOutput("prizeplot"))
              ))
    )
  ),
    # Boxes need to be put in a row (or column)
#    fluidRow(
#      box(plotOutput("plot1", height = 250)),
      
#      box(
#        title = "Controls",
#        sliderInput("slider", "Number of observations:", 1, 100, 50)
)

# Define UI for application that draws a histogram
#fluidPage(

    # Application title
#    titlePanel("Nobel Prize Laureate Data"),

    # Sidebar with a slider input for number of bins
#    sidebarLayout(
#        sidebarPanel(
#            sliderInput("bins",
#                        "Number of bins:",
#                        min = 1,
#                        max = 50,
#                        value = 30)
#        ),

        # Show a plot of the generated distribution
#        mainPanel(
#            plotOutput("distPlot")
#        )
#    )
#)
