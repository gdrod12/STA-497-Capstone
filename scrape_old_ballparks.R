library(rvest)
library(dplyr)

{url <- "https://www.seamheads.com/ballparks/index.php"
page <- read_html(url)

# Extract the table text (for ballpark names etc.)
tbl <- page %>%
  html_node("table") %>%
  html_table(fill = TRUE)

# Extract only the hrefs from the FIRST column
hrefs <- page %>%
  html_node("table") %>%
  html_nodes("tr td:first-child a") %>%  # only <a> tags in first column
  html_attr("href")

# Add them to the table
tbl$Link <- hrefs

head(tbl)
tbl$Link_full <- paste0("https://www.seamheads.com/ballparks/",
                        tbl$Link)}

inactive_capacity_data <- data.frame()

for (row in 1:nrow(tbl)){
  new_url <- tbl$Link_full[row]
  print(new_url)
  
  new_page <- read_html(new_url)
  
  # Extract the table text (for ballpark names etc.)
  tables <- new_page %>% html_nodes("table")
  main_table <- tables[[2]] %>% html_table(fill = TRUE)
  colnames(main_table) <- make.unique(as.character(unlist(main_table[1, ])))
  main_table <- main_table[-1, ]
  team_id <- substr(tbl$Link[row], nchar(tbl$Link[row])-4, nchar(tbl$Link[row]))
  main_table$team_id <- team_id
  inactive_capacity_data<-rbind(inactive_capacity_data, main_table)
}

write_csv(inactive_capacity_data, "inactive_capacity_data.csv")

{url <- "https://www.seamheads.com/ballparks/year.php?Year=2024"
  page <- read_html(url)
  
  # Get all tables
  tables <- page %>% html_nodes("table")
  # The main ballpark table is usually the second one
  tbl <- tables[[2]] %>% html_table(fill = TRUE)
  colnames(tbl) <- make.unique(as.character(unlist(tbl[1, ])))
  tbl <- tbl[-1, ]
  # Extract the hrefs from the first column, scoped to the same table
  hrefs <- tables[[2]] %>%
    html_nodes("tr td:first-child a") %>%
    html_attr("href")
  
  # Add them to the data frame
  tbl$Link <- hrefs
  
  head(tbl)}
inactive_capacity_data$Comment <- NULL
tbl$team_id <- substr(tbl$Link, nchar(tbl$Link)-4, nchar(tbl$Link))
tbl$Link <- NULL
data <- rbind(inactive_capacity_data%>%
                reframe(`Ballpark Name`, Capacity, team_id, Year), tbl%>%
                reframe(`Ballpark Name`, Capacity, team_id, Year=2024))
write_csv(data, "capacity_data.csv")
