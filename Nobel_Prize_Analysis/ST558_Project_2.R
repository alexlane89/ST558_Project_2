#Load required packages
library(tidyverse)
library(httr)
library(jsonlite)

#Eventually, we'll create one function to retrieve a data table for all 
#years of each Nobel Prize category. The first "sub-function" will be
#simply one to query the Nobel API with a specification for each category.
#A list will be returned that includes elements associated with each
#"bucket" of 25-year prize data.

#NOTE - The API call limits results to 25 rows (one year per row),
#so to create a result with all years since 1901, multiple queries
#must be made for each 25-year "bucket", then combined.

#define function 'get_data' to initially get Nobel Prize 
#data specific to a Nobel category
get_data <- function(category = "Chemistry") {
  if (category == "Chemistry") {
    q_code <- "che"
  } else if (category == "Economics") {
    q_code <- "eco"
  } else if (category == "Literature") {
    q_code <- "lit"
  } else if (category == "Peace") {
    q_code <- "pea"
  } else if (category == "Physics") {
    q_code <- "phy"
  } else if (category == "Medicine") {
    q_code <- "med"
  } else {
    stop("category argument must be an acceptable prize option")
  }
  num_q <- ((getRmetricsOptions("currentYear")[[1]] - 1901) %/% 25) + 1
  year_start <- 1901
  year_end <- getRmetricsOptions("currentYear")[[1]]
  x_a <- GET(paste0("http://api.nobelprize.org/2.1/nobelPrizes?nobelPrizeYear=1901&yearTo=1925&nobelPrizeCategory=",q_code))
  x_b <- GET(paste0("http://api.nobelprize.org/2.1/nobelPrizes?nobelPrizeYear=1926&yearTo=1950&nobelPrizeCategory=",q_code))
  x_c <- GET(paste0("http://api.nobelprize.org/2.1/nobelPrizes?nobelPrizeYear=1951&yearTo=1975&nobelPrizeCategory=",q_code))
  x_d <- GET(paste0("http://api.nobelprize.org/2.1/nobelPrizes?nobelPrizeYear=1976&yearTo=2000&nobelPrizeCategory=",q_code))
  if (num_q == 5) {
    x_e <- GET(paste0("http://api.nobelprize.org/2.1/nobelPrizes?nobelPrizeYear=2000&yearTo=",getRmetricsOptions("currentYear")[[1]],"&nobelPrizeCategory=",q_code))
    x_f <- NULL
  } else if (num_q == 6) {
    x_e <- GET(paste0("http://api.nobelprize.org/2.1/nobelPrizes?nobelPrizeYear=2001&yearTo=2025&nobelPrizeCategory=",q_code))
    x_f <- GET(paste0("http://api.nobelprize.org/2.1/nobelPrizes?nobelPrizeYear=2026&yearTo=",getRmetricsOptions("currentYear")[[1]],"&nobelPrizeCategory=",q_code))
  }
  return(list(x_a, x_b, x_c, x_d, x_e, x_f))
}

#Use the 'tibble_data' function to pull information from the JSON data result
#in get_data and convert to a tibble for each bucket of years.
tibble_data <- function(x) {
  y_a <- fromJSON(rawToChar(x[[1]]$content))
  y_b <- fromJSON(rawToChar(x[[2]]$content))
  y_c <- fromJSON(rawToChar(x[[3]]$content))
  y_d <- fromJSON(rawToChar(x[[4]]$content))
  y_e <- fromJSON(rawToChar(x[[5]]$content))
  y_f <- NULL
  if (!is.null(x[[6]])) {
    y_f <- fromJSON(rawToChar(x[[6]]$content))
  }
  z_a <- as_tibble(y_a$nobelPrizes)
  z_b <- as_tibble(y_b$nobelPrizes)
  z_c <- as_tibble(y_c$nobelPrizes)
  z_d <- as_tibble(y_d$nobelPrizes)
  z_e <- as_tibble(y_e$nobelPrizes)
  z_f <- NULL
  if (!is.null(y_f)) {
    z_f <- as_tibble(y_f$nobelPrizes)
  }
  return(list(z_a, z_b, z_c, z_d, z_e, z_f))
}

#Merge the resulting tibbles of 25-year buckets into one tibble.
merge_data <- function(x) {
  dplyr::bind_rows(x[[1]], x[[2]], x[[3]], x[[4]], x[[5]], x[[6]])
}

# The resulting list of 10 elements included mostly elements
# describing attributes of the query itself. i.e. headers
# about what type of server hosts the data, how the content
# is encoded, which cookies are included in the request, the date/time
# of the request, etc. I was able to find that the information in
# question, however, appeared to be in the $content list element.
# Within this element, several more data frames existed.
# For example, the category and the laureate names,
# amongst other information.

# A 'clean_data' function will look at the $content element and also
# create a new variable/column to show the Adjusted prize amounts in
# current USD currency. The prize is based in Sweden, so the initial Prize
# amounts are listed in Swedish Kroner. This function includes an argument
# to define which conversion rate is preferred.

clean_data <- function(x, conv = "USD/SEK") {
  conversion <- c(0.095, 1/0.095)
  names(conversion) <- c("USD/SEK", "SEK/USD")
  
  c_data <- x |>
    select(awardYear, dateAwarded, laureates) |>
    mutate(Category = x$category$en,
           AdjustedPrize_SEK = x$prizeAmountAdjusted,
           AdjustedPrize_USD = x$prizeAmountAdjusted * conversion[1]
    ) |>
    unnest(cols = laureates) |>
    select(!links)
  
  return(c_data)
}

# Now we can combine all smaller functions to have one function which pulls
# Nobel Prize API data in 25-year chunks, converts resulting output to tibbles,
# merges them into one tibble, and cleans the data to remove at least swedish
# & Nordic-language variables.
get_Nobel_Prize_data <- function(category = "Chemistry") {
  data_list <- get_data(category = category)
  tibble_list <- tibble_data(data_list)
  merged_data <- merge_data(tibble_list)
  cleaned <- clean_data(merged_data)
  return(cleaned)
}

# Preceding functions have focused on getting data from Nobel Prize-specific
# data, but another API endpoint is the Laureate-specific information.
# This also requires limits of 25-bucket chunks, but instead of 25-years,
# The limit for the Laureate endpoint is for 25-individuals (or laureate IDs).
# This requires a more iterative approach to pulling all the 25-year buckets
# of information.

# We'll start by determining how many Laureate IDs are in use.
det_id_res <- function(ID = 1100) {
  ID_STR <- as.character(ID)
  a <- GET(paste0("https://api.nobelprize.org/2.1/laureates?ID=",
                  ID_STR))
  b <- content(a, "text") |>
    fromJSON()
  
  return(is_empty(b$laureates))
}

# I can use another function to iterate through and determine the last ID.

det_last_id <- function(begin = 1000, end = 1050) {
  for (i in seq(from = begin, to = end)) {
    if (det_id_res(ID = i) == TRUE) {
      return(paste0("Max ID = ",i))
      stop()
    }
  }
}

# Now for the loop which gets all buckets of laureate IDs
get_laureate_data <- function() {
  a <- GET(paste0("https://api.nobelprize.org/2.1/laureates"))
  b <- content(a, "text") |>
    fromJSON()
  c <- as_tibble(b$laureates)
  d <- c
  for (i in seq(from = 26, to = 1010, by = 25)) {
    a <- GET(paste0("https://api.nobelprize.org/2.1/laureates?offset=",
                    i))
    b <- content(a, "text") |>
      fromJSON()
    c <- as_tibble(b$laureates)
    d <- bind_rows(d, c)
  }
  return(d)
}

# A fair amount of data cleaning is required on the laureate data set.
# The process is broken up into several subfunctions, then combined.

clean_name_laureate <- function(x) {
  y <- x |>
    unnest(cols = c(knownName)) |>
    mutate(Known_Name = en) |>
    select(!en & !se & !no & !familyName & !fullName & !givenName &
             !fileName & !wikipedia & !sameAs & !links & !wikidata
           & !founded & !foundedCountry & !foundedContinent
           & !foundedCountryNow)
  return(y)
}

clean_birth_laureate <- function(x) {
  y <- x |>
    unnest(cols = birth) |>
    mutate(Birth_Date = date) |>
    select(!date) |>
    unnest(cols = place) |>
    select(!locationString) |>
    unnest(cols = city) |>
    mutate(Birth_City = en) |>
    select(!en & !se & !no & !cityNow) |>
    unnest(cols = countryNow) |>
    mutate(Birth_Country_Now = en) |>
    select(!en & !se & !no & !sameAs & !latitude & !longitude) |>
    unnest(cols = country) |>
    mutate(Birth_Country = en) |>
    select(!en & !se & !no) |>
    unnest(cols = continent) |>
    mutate(Birth_Continent = en) |>
    select(!en & !se & !no)
}

clean_death_laureate <- function(x) {
  y <- x |>
    unnest(cols = death) |>
    mutate(Death_Date = date) |>
    select(!date) |>
    unnest(cols = place) |>
    unnest(cols = city) |>
    mutate(Death_City = en) |>
    select(!en & !se & !no & !cityNow & !countryNow) |>
    unnest(cols = country) |>
    mutate(Death_Country = en) |>
    select(!en & !se & !no) |>
    unnest(cols = continent) |>
    mutate(Death_Continent = en) |>
    select(!en & !se & !no & !locationString & !sameAs)
}

clean_addl_laureate <- function(x) {
  y <- x |>
    unnest(cols = nobelPrizes) |>
    unnest(cols = category) |>
    mutate(Category = en) |>
    select(!en & !se & !no & !categoryFullName) |>
    unnest(cols = motivation) |>
    mutate(Motivation = en) |>
    select(!en & !se & !no) |>
    unnest(cols = orgName) |>
    mutate(Organization = en) |>
    select(!en & !se & !no)
  return(y)
}

clean_laureate <- function(x) {
  y <- clean_name_laureate(x) |>
    clean_birth_laureate() |>
    clean_death_laureate() |>
    clean_addl_laureate()
  return(y)
}

