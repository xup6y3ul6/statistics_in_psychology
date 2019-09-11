source("global.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    formData <- reactive({
        data <- sapply(fieldsAll, function(x) {
            if(x == "time"){
                paste(input[[x]], collapse = "/")
            } else {
                return(input[[x]])
            }
        })
        data <- c(data, timestamp = epochTime())
        data <- t(data)
        data
    })
    
    observe({
        # check if all mandatory fields have a value
        mandatoryFilled <-
            vapply(fieldsMandatory,
                   function(x) {
                       !is.null(input[[x]]) && input[[x]] != "" 
                   },
                   logical(1))
        mandatoryFilled <- all(mandatoryFilled)
        
        # enable/disable the submit button
        shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
    })
    
    observeEvent(input$submit, {
        shinyjs::disable("submit")
        shinyjs::show("submit_msg")
        shinyjs::hide("error")
        
        tryCatch({
            saveData(formData())
            shinyjs::hide("form")
            shinyjs::show("thankyou_msg")
        },
        error = function(err) {
            shinyjs::html("error_msg", err$message)
            shinyjs::show(id = "error", anim = TRUE, animType = "fade")
        },
        finally = {
            shinyjs::enable("submit")
            shinyjs::hide("submit_msg")
            shinyjs::reset("responses")
        })
    })
    
    observeEvent(input$submit_another, {
        shinyjs::reset("form")
        shinyjs::show("form")
        shinyjs::enable("submit")
        shinyjs::hide("thankyou_msg")
    }) 
    
    observeEvent(input$refresh, {
        shinyjs::js$refresh()
    })
    
    data <- reactive({loadData()})
    
    output$responsesPlot <- renderPlot({
        .time <- strsplit(data()$time, "/")
        .Mon <- sapply(.time, function(x){"Mon" %in% x})
        .Wed <- sapply(.time, function(x){"Wed" %in% x})
        .Thu <- sapply(.time, function(x){"Thu" %in% x})
        .Fri <- sapply(.time, function(x){"Fri" %in% x})
        .None <- sapply(.time, function(x){"None" %in% x})
        
        df <- data() %>% 
            select(id) %>% 
            add_column(Mon = .Mon, Wed = .Wed, Thu = .Thu, Fri = .Fri, None = .None) %>% 
            gather(key = "day", value = "attend", -1, factor_key = TRUE) %>% 
            group_by(day) %>% 
            summarise(number = sum(attend))
            
        ggplot(df, aes(x = day, y = number)) +
            geom_histogram(stat = "identity") +
            geom_text(aes(label = number, y = number/2), color = "white") +
            geom_hline(yintercept = 30, color = "red", linetype = "dashed") +
            scale_y_continuous(breaks = seq(0, 45, 5)) +
            theme(text = element_text(family = "黑體-繁 中黑"))
        
    })
    
    output$downloadBtn <- downloadHandler(
        filename = function() { 
            sprintf("mimic-google-form_%s.csv", humanTime())
        },
        content = function(file) {
            write.csv(loadData(), file, row.names = FALSE)
        }
    )
    
    output$responsesTable <- renderDataTable({
        datatable(data(),
                  options = list(lengthChange = FALSE))
    })

})
