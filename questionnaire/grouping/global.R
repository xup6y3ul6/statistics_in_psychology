####
# use shiny to build questionnaire 
# reference: https://deanattali.com/2015/06/14/mimicking-google-form-shiny/
####

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
   #sidebar, #instruction { background-color: rgba(140, 202, 242, 0.25); }
  "
## to resolve chineses problem in ggplot in shinyapps.io
# reference: http://shiny.rstudio.com/gallery/unicode-characters.html
options(shiny.usecairo = FALSE)

font_home <- function(path = '') file.path('~', '.fonts', path)
if (Sys.info()[['sysname']] == 'Linux' &&
    system('locate wqy-zenhei.ttc') != 0 &&
    !file.exists(font_home('wqy-zenhei.ttc'))) {
  if (!file.exists('wqy-zenhei.ttc'))
    curl::curl_download(
      'https://github.com/rstudio/shiny-examples/releases/download/v0.10.1/wqy-zenhei.ttc',
      'wqy-zenhei.ttc'
    )
  dir.create(font_home())
  file.copy('wqy-zenhei.ttc', font_home())
  system2('fc-cache', paste('-f', font_home()))
}
rm(font_home)


if (.Platform$OS.type == "windows") {
  if (!grepl("Chinese", Sys.getlocale())) {
    warning(
      "You probably want Chinese locale on Windows for this app",
      "to render correctly. See ",
      "https://github.com/rstudio/shiny/issues/1053#issuecomment-167011937"
    )
  }
}

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