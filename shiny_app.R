library(shiny)
library(reticulate)
library(shinyjs)
library(future)
library(shinycssloaders)
library(shinythemes)
library(DT)
library(dplyr)
library(ggplot2)
library(tidyr)
library(readtext)
library(openai)
library(reticulate)

source_python("llama_call.py")
source("examples.R")

ui <- fluidPage(
  useShinyjs(),  # Enable shinyjs
  theme = shinythemes::shinytheme("flatly"), # Set theme
  
  title = "LLMLinelist: LLM-Assisted Processing of Free-Text Outbreak Reports to Tabular Data",
  
  tags$head(
    tags$style(HTML("
      body {
        margin-left: 100px;
        margin-right: 100px;
      }
    "))
  ),
  # Title and subtitle
  titlePanel(
    column(12,
           h1("LLMLinelist: LLM-Assisted Processing of Free-Text Outbreak Reports to Tabular Data"),
           h5("This app demonstrates the use of open-source LLMs for the automatic extraction of information on cases and contacts from free-text outbreak reports to enable rapid analysis and enhance situational awareness.", width = '100%'),
           h5(strong("Warning: this is a work in progress and hence there will be bugs. LLMs are not perfect and are prone to hallucination (especially if the input data is vague or unclear), so please double-check any output generated."), width = '100%'),
           h6("Billy Quilty, Department of Infectious Disease Epidemiology and Dynamics, LSHTM"),
    ),
  ),
  
  # Sidebar layout for input
  sidebarLayout(
    sidebarPanel(
      style = "background-color:#ecf0f1;",
      textAreaInput("input_text", 
                    label = "Paste outbreak report (or choose an example):",
                    rows = 10,
                    width = '100%', 
                    value = example1),
      radioButtons("example_btn", "Examples:",
                   choices = c("Example 1", "Example 2", "Example 3"),
                   selected = "Example 1"),
     #fileInput("input_file", "or upload .docx File:", accept = c(".docx"), width = "100%"),
      actionButton("process_btn", "Process Text", class = "btn-primary", width = "100%")
    ),
    
    # Main content area
    mainPanel(
      tabsetPanel(
        tabPanel("Table", 
                 fluidRow(
                   column(12,
                   shinyjs::hidden(div(id = 'loading', withSpinner(DTOutput("output_table", width = '100%'),type=8,color.background ="#ecf0f1"))
                   )
                 )
                 )
        ),
        
        tabPanel("Timeline", 
                 fluidRow(
                   column(12,
                   plotOutput("timeline_plot", width = "100%", height = "400px")
                   )
                 )
        )
      )
    )
  )
)


server <- function(input, output, session) {
  observe({
    if (!is.null(input$input_file)) {
      content <- readtext(input$input_file$datapath)
      updateTextAreaInput(session, "input_text", value = content)
    }
  })
  
  observeEvent(input$example_btn, {
    example_text <- switch(input$example_btn,
                           "Example 1" = example1,
                           "Example 2" = example2,
                           "Example 3" = example3)
    
    updateTextAreaInput(session, "input_text", value = example_text)
  })

  
  output$input_text_output <- renderPrint({
    isolate(input$input_text)
  })
  
  observeEvent(input$process_btn, {
    content <- if (!is.null(input$input_file)) {
      readtext(input$input_file$datapath)
    } else {
      input$input_text
    }
    
    # Show loading indicator
    shinyjs::showElement(id = 'loading')
    
    browser()
    # Call the OpenAI API 
    result <- create_response(content)
    
    # Parse CSV string
    csv_data <- read.csv(text = result)
    
    # Render CSV data as a table
    output$output_table <- renderDataTable(
      csv_data, extensions = 'Buttons', options = list(scrollX = TRUE,
                                                       dom = 'Bfrtip',
                                                       buttons = c('copy', 'csv', 'excel', 'pdf', 'print'))
    )
    
    # When processing is complete, re-enable the button and hide loading indicator
    onStop(function() {
      shinyjs::enable("process_btn")
      shinyjs::hideElement(id = 'loading')
    })
    
    # Report errors if any
    tryCatch({
    }, error = function(e) {
      showModal(modalDialog(
        title = "Error",
        paste("An error occurred:", e$message),
        easyClose = TRUE
      ))
    })
    
    # New output for timeline plot
    output$timeline_plot <- renderPlot({
      # Call a function to generate the timeline plot
      timeline_plot <- generate_timeline_plot()
      print(timeline_plot)
    })
    
    # Function to generate timeline plot
    generate_timeline_plot <- function() {
      #browser()
      # Assuming csv_data contains your parsed CSV data
      # You may need to adjust the column names based on your actual data
      csv_data %>% 
        pivot_longer(contains("date"),names_to="dates") %>% 
        mutate(value=as.Date(value,format = "%d %B %Y")) %>% 
        drop_na(value) %>% 
        ggplot( aes(x = value, y = Name)) +
        geom_point(aes(colour=dates))+
        scale_x_date(breaks = "2 days",date_labels = "%d %b %y")+
        labs(x = "Date", y = "Name") +
        theme_minimal()+
        ggpubr::rotate_x_text(angle = 45)
    }
  })
}

shinyApp(ui, server)
