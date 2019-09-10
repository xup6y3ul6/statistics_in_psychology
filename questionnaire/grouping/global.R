library(shiny)
library(rdrop2)
library(tidyverse)
library(DT)
library(V8)

## custom css
appCSS <-
  ".mandatory_star { color: red; }
   .font_red { color: red; }
   .align_right { float: right; }
   #error { color: red; }
   #incorrect_msg { color: red; font-style: italic; }
  "

## custom function
# mandatory
labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}

# save the response upon submission
fieldsAll <- c("name", "id", "department", "time", "os", "credit", "hight")
fieldsMandatory <- c("name", "id", "department", "time")
outputDir <- file.path("statistics_in_psychology", "grouping_responses")
epochTime <- function() {as.integer(Sys.time())}
humanTime <- function() {format(Sys.time(), "%Y%m%d-%H%M%OS")}

saveData <- function(data) {
  fileName <- sprintf("%s_%s.csv",
                      humanTime(),
                      digest::digest(data))
  filePath <- file.path(tempdir(), fileName)
  write.csv(x = data, file = filePath,
            row.names = FALSE, quote = TRUE)
  drop_upload(filePath, path = outputDir)
}

# add table that shows all previous responses
loadData <- function() {
  filesInfo <- drop_dir(outputDir)
  filePaths <- filesInfo$path_display
  #files <- list.files(file.path(responsesDir), full.names = TRUE)
  data <- lapply(filePaths, drop_read_csv, stringsAsFactors = FALSE, 
                 colClasses = "character")
  data <- bind_rows(data)
  data$timestamp <- as.POSIXct(as.integer(data$timestamp), origin = "1970-01-01")
  return(data)
}