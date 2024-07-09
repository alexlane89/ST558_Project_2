# ST558_Project_2
ST558 Project 2 - API, Data Analysis, and Shiny App Presentation of
Nobel Prize Award & Laureate information.

## Required Packages
- tidyverse
- httr
- jsonlite
- shiny
- DT

## Code for packages:

install.packages("tidyverse")
install.packages("httr")
install.packages("jsonlite")
install.packages("shiny")
library("DT")

## Code to run app

shiny::runGitHub("ST558_Project_2", username = "alexlane89")
#          ref = "Main", subdir = NULL, port = NULL,
#          launch.browser = getOption("shiny.launch.browser", interactive()))