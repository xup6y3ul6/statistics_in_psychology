source("global.R")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    # CSS
    shinyjs::useShinyjs(),
    shinyjs::inlineCSS(appCSS),
    shinyjs::extendShinyjs(text = "shinyjs.refresh = function() { location.reload(); }"),
    
    # Application title
    titlePanel("心理及教育統計學上_分組表單"),
    
    wellPanel(id = "instruction",
        h4("各位同學大家好~"),
        br(),
        h4("為了幫助大家學習統計和應用 R 軟體進行分析，本課程規定同學必須在四個實習課中擇一參加。"),
        h4("四個時段分別由不同助教帶領，但是使用相同的課程教材，
           因此依自己方便的時間自由填答即可。"),
        h4("之後會考量教室大小與填答狀況，以郵件通知大家。"),
        br(),
        h4("如果有任何問題，歡迎聯絡助教或寄信到 r08227112@ntu.edu.tw。"),
        h4("心統助教群", class = "align_right"), 
        br(), br()
    ),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(id = "sidebar", width = 5,
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
                
                selectizeInput("os", "你/妳電腦的作業系統",
                               choices = c("Win7", "Win8", "Win10", "Mac", "Linux", "Other"),
                               options = list(placeholder = 'Please select an option below',
                                              onInitialize = I('function() { this.setValue(""); }'))),
                sliderInput("credit", "你/妳這學期預計修幾學分", min = 1, max = 30, value = 1),
                textInput("hight", "你/妳認為的身高多少 cm（自由心證 XD）", ""),
                selectizeInput("gender", "你/妳的性別", 
                               choices = c("Male", "Female", "Other"),
                               options = list(placeholder = 'Please select an option below',
                                              onInitialize = I('function() { this.setValue(""); }'))),
                
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
