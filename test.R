# Call the OpenAI API 
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
library(stringr)
library(readr)

source("examples.R")
source("local_llm_call.R")
#source("openai_call.R")

result <- create_response(example3)
result

str_trim(result) %>% paste0("[",.,"]") %>% prettify()
