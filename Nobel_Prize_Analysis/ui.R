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
library(DT)

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
                box(h6("This app is meant to introduce and provide an overview of
                        data related to the Nobel Prize awarded to individuals
                        yearly since 1901 in 6 distinct categories:"),
                    br(),
                    h6("Chemistry"),
                    h6("Economics"),
                    h6("Literature"),
                    h6("Peace"),
                    h6("Physiology"),
                    h6("Physiology or Medicine"),
                    h6("Physics"),
                    br(),
                    h6("The Nobel Prize was created as part of Alfred Nobel's 
                       endowment, and has become one of the most prestigious 
                       prizes in any of the 6 fields described. 
                       We will download data from the Nobel API. 
                       information can be found at the link below"),
                    br(),
                    h6("https://app.swaggerhub.com/apis/NobelMedia/NobelMasterData/2.1"),
                    ),
                img(src = "Alfred_Nobel_img.jpg")
              )),
      #Download tab
      tabItem(tabName = "download",
              fluidRow(
                box(
                  h5("Download a csv file of Nobel Laureate data based on 
                     your category selection"),
                  downloadButton("download_button", "Download Data")),
                box(radioButtons(inputId = "category_sel", "Category Selection",
                                 choices = c("Chemistry", "Economic Sciences",
                                             "Literature", "Physiology or Medicine", "Peace",
                                             "Physics")))
              )),
      #Output tab - including category selection & resulting dynamic output.
      #also includes static output.
      tabItem(tabName = "analysis",
              fluidRow(
                box(
                  h5("The items on this page labeled as 'Dynamic' are
                     based on the Nobel Prize category selected. Use the
                     radio buttons to select a category and view the 
                     associated results."),
                  br(),
                  h5("Birth Country Histogram displays the total number of Nobel
                     Prizes associated with each Country based on the laureates'
                     birth location. This plot is dynamic and presents totals for
                     the category selected in the 'Download' tab."),
                  br(),
                  h5("The Female % Recipients Table shows the total number of Nobel
                     recipients per birth country, as well as the proportion of
                     those recipients which are female. The table is dynamic based
                     the category selected, and is sorted in descending order by
                     female proportion."),
                  br(),
                  h5("There are 2 static plots on this page. Primarily because the
                     information they present is irrespective of the category selected. 
                     The Adjusted Nobel Prize Amount plot shows the Swedish-Kroner denoted
                     amount which is adjusted for inflation over time. Because the prize
                     reward amount is independent of prize category (i.e. a Chemistry
                     & Physics winner will receive the same amount), a dynamic selection
                     would not necessarily present new information."),
                  br(),
                  h5("The Number of Recipients per Year plot is meant to show the
                     general increase in number of recipients over time. Prizes can
                     be shared amongst individuals, and this plot appears to show
                     that generally, the number of prizes shared, or number of individuals
                     receiving a Nobel Prize has increased over time.")
                ),
                box(plotOutput("birth_hist"), title = "Dynamic - Birth Country Histogram"),
                box(plotOutput("prizeplot"), title = "Static - Adjusted Nobel Prize Amount by Year"),
                box(DTOutput("contingency_table"), title = "Dynamic - Female % Recipients Table"),
                box(plotOutput("rec_plot"), title = "Static - Number of Recipients per Year")
              )
        )
    )
  )
)

