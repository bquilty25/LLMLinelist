library(shiny)
library(reticulate)
library(shinyjs)
library(listviewer)
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
library(stringr)
library(readr)

source("examples.R")
source("utils.R")
source("llm_call_functions.R")

ui <- fluidPage(
  useShinyjs(),  # Enable shinyjs
  theme = shinythemes::shinytheme("flatly"), # Set theme
  
  title = "LLMLinelist: LLM-Assisted Processing of Free-Text Outbreak Reports to Tabular Data",
  
  tags$head(
    tags$style(HTML("
      body {
        margin-left: 5%;
        margin-right: 5%;
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
      style = "background-color:#ecf0f1; max-height:90vh",
      textAreaInput("input_text", 
                    label = "Paste outbreak report (or choose an example):",
                    rows = 10,
                    width = '100%', 
                    value = example1),
      radioButtons("example_btn", "Examples:",
                   choices = c("Example 1", "Example 2", "Example 3"),
                   selected = "Example 1"),
      selectInput("call_option", "Choose LLM:",
                  choices = c("Local LLM", "gpt-3.5-turbo"),
                  selected = "Local LLM"),
     #fileInput("input_file", "or upload .docx File:", accept = c(".docx"), width = "100%"),
      actionButton("process_btn", "Process Text", class = "btn-primary", width = "100%")
    ),
    
    # Main content area
    mainPanel(
      style = "max-height:90vh",
      tabsetPanel(
        tabPanel("Result", 
                 fluidRow(
                   column(12,
                          jsoneditOutput("jsed", width = "100%", height = "450px")
                 )
                 ),
                 fluidRow(
                   column(12,
                          align = "right",
                          style = "margin-bottom: 10px;",
                          style = "margin-top: 10px;",
                          downloadButton("download_csv", "Download CSV")
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
  
  hideElement(id = "download_csv")
  
  observe({
    if (!is.null(input$input_file)) {
      content <- readtext(input$input_file$datapath)
      updateTextAreaInput(session, "input_text", value = content)
    }
  })
  
  observeEvent(input$example_btn, {
    example_text <- switch(input$example_btn,
                           "Example 0.5" = example0.5, 
                           "Example 1" = example1,
                           "Example 2" = example2,
                           "Example 3" = example3)
    
    updateTextAreaInput(session, "input_text", value = example_text)
  })

  
  output$input_text_output <- renderPrint({
    isolate(input$input_text)
  })
  
  observeEvent(input$process_btn, {
    
    tryCatch({
      content <- input$input_text
      # Disable button while processing
      showPageSpinner()
      disable("process_btn")
      
      # Call function based on the selected option
      if (input$call_option == "Local LLM") {
        result <- local_llm_call(content)
      } else {
        # Call OpenAI function (replace with your actual OpenAI function call)
        result <- openai_call(content)
      }
      
      
      # Process JSON
      pretty_json <- str_trim(result) %>% paste0("[",.,"]") 
      
      # Render pretty printed JSON
      output$jsed <- renderJsonedit({
        jsonedit(
          pretty_json,
          "onChange" = htmlwidgets::JS('function(after, before, patch){
        console.log( after.json )
      }')
        )
        
      })
      
      # Convert JSON to long data frame
      df <- fromJSON(pretty_json)
      
      df_long <- unnest(df,cols="Contacts",names_sep = "_") 
      
      # Write data frame to CSV
      csv_content <- capture.output(write.csv(df_long, row.names = FALSE))
      
      # Enable download button
      output$download_csv <- downloadHandler(
        filename = function() {
          "output.csv"
        },
        content = function(file) {
          writeLines(csv_content, file)
        }
      )
      
      # Render timeline plot
      output$timeline_plot <- renderPlot({
        # Call a function to generate the timeline plot
        generate_timeline_plot(df)
      })
      
    }, error = function(e) {
      # Show error message
      showModal(modalDialog(
        title = "Error",
        "An error occurred while processing the text.",
        tags$br(),
        "Error message:",
        tags$br(),
        tags$code(e$message),
        tags$br(),
        "Please try again.",
        easyClose = TRUE
      ))
    }, finally = {
      
      hidePageSpinner()
      
      # Re-enable button
      showElement(id = "download_csv")
      enable("process_btn")
    
  })
})
}

shinyApp(ui, server)
