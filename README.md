# ST558_Project_2
ST558 Project 2 - API, Data Analysis, and Shiny App Presentation of
Nobel Prize Award & Laureate information.

This application allows a user to view certain static & dynamic information.
The dynamic information is dependent upon the user's selection of a specific
Nobel Prize category.

## Required Packages
- tidyverse
- httr
- jsonlite
- shiny
- shinydashboard
- timeDate
- DT

## Code for packages:

install.packages("tidyverse")
install.packages("httr")
install.packages("jsonlite")
install.packages("shiny")
install.packages("shinydashboard")
install.packages("timeDate")
install.packages("DT")

## Code to run app

# Unfortunately this code does not appear to run successfully - An error is returned
# for utils::download.file(url, method = method, ...)
shiny::runGitHub("ST558_Project_2", username = "alexlane89")
          ref = "Main", subdir = "Nobel_Prize_Analysis", port = NULL,
          launch.browser = getOption("shiny.launch.browser", interactive()))