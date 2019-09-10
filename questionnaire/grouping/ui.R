source("global.R")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    # CSS
    shinyjs::useShinyjs(),
    shinyjs::inlineCSS(appCSS),
    shinyjs::extendShinyjs(text = "shinyjs.refresh = function() { location.reload(); }"),
    
    # Application title
    titlePanel("心理學教育統計分組表單"),
    
    wellPanel(
        h4("拉啦啦啦"),
        h4("心統助教群", class = "align_right"), 
        br(), br()
    ),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(width = 5,
            div(id = "form",
                span("*", class = "font_red"), span("(必填)"), br(), br(),
                textInput("name", labelMandatory("姓名："), ""),
                textInput("id", labelMandatory("學號："), ""),
                textInput("department", labelMandatory("系級："), ""),
                
                hr(),
                
                checkboxGroupInput("time", labelMandatory("實習課可以的時段（可複選）："),
                                   choices = c("（一）12:20 - 13:10 @北館 301 電腦教室" = "Mon",
                                               "（三）12:20 - 13:10 @博雅 408 電腦教室" = "Wed",
                                               "（四）12:20 - 13:10 @北館 301 電腦教室" = "Thu",
                                               "（五）12:20 - 13:10 @博雅 408 電腦教室" = "Fri",
                                               "以上皆無法" = "None")),
                
                hr(),
                
                selectInput("os", "你電腦的作業系統",
                            choices = c("Win7", "Win8", "Win10", "Mac", "Linux", "Other")),
                sliderInput("credit", "你這學期預計修幾學分", min = 1, max = 30, value = 15),
                textInput("hight", "你認為你的身高多少 cm（自由心證 XD）", ""),
                
                actionButton("submit", "提交", class = "btn-primary")
            ),
            
            shinyjs::hidden(
                span(id = "submit_msg", "提交中..."),
                div(id = "error",
                    div(br(), tags$b("Error: "), span(id = "error_msg"))
                )
            ),
            
            shinyjs::hidden(
                div(id = "thankyou_msg",
                    h3("感謝您的填寫，已收到您的回答。"),
                    actionLink("submit_another", "點此填寫新的回答～")
                )
            )
        ),
        
        
        # Show a plot of the generated distribution
        mainPanel(width = 7,
            div(id = "responses",
                actionButton("refresh", "Refresh"),
                h4(paste0("目前（", humanTime(), "）累積回答")),
                plotOutput("responsesPlot"),
                hr(),
                downloadButton("downloadBtn", "Download responses"),
                dataTableOutput("responsesTable")
            )
            
        )
    )
))
