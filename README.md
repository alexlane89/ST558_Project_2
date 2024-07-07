# ST558_Project_2
ST558 Project 2 - API, Data Analysis, and Shiny App Presentation of Nobel Prize Award & Laureate information.

## Required Packages
- tidyverse
- httr
- jsonlite

## Code for packages:

library(tidyverse)
library(httr)
library(jsonlite)
library(shiny)

## Code to run app

shiny::runGitHub("ST558_Project_2", username = "alexlane89")
#          ref = "Main", subdir = NULL, port = NULL,
#          launch.browser = getOption("shiny.launch.browser", interactive()))