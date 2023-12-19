library(httr)
library(jsonlite)
library(readr)

api_key <- Sys.getenv("OPENAI_API_KEY")  # Set your OpenAI API key as an environment variable
base_url_openai <- "https://api.openai.com/v1"  # Update the base URL to OpenAI's API endpoint

openai_call <- function(prompt) {
    request_url <- paste0(base_url_openai, "/chat/completions")  # Update the endpoint based on OpenAI API specifications
    
    payload <- list(
      model = "gpt-3.5-turbo",  # Update the model name based on OpenAI's available models
      messages = list(
        list(role = "system", content = system_prompt),
        list(role = "user", content = paste0('\nInput:\n', prompt))
      ),
      stop = "\n\n",
      temperature = 0.2
    )
    
    response <- POST(
      url = request_url,
      add_headers("Content-Type" = "application/json", "Authorization" = paste("Bearer", api_key)),
      body = toJSON(payload, pretty = FALSE, auto_unbox = TRUE),
      encode = "json"
    )
    
    print(response)  # Add this line to print the response object for debugging
    
    content <- content(response, "text")
    
    print(content)  # Add this line to print the content for debugging
    
    parsed_content <- fromJSON(content)
    
    return(parsed_content$choices$message$content[[1]])
}


# Local LLM call
base_url_local <- "http://localhost:1234/v1"

local_llm_call <- function(prompt) {
  #browser()
  request_url <- paste0(base_url_local, "/chat/completions")
  
  payload <- list(
    model = "local-model",
    messages = list(
      list(role = "system", content = system_prompt),
      list(role = "user", content = paste0('\nInput:\n', prompt))
    ),
    stop = '\n\n',
    temperature = 0.2
  )
  
  response <- POST(
    url = request_url,
    add_headers("Content-Type" = "application/json", "Openai-Api-Key" = "not required"),
    body = toJSON(payload,pretty = F, auto_unbox = TRUE),
    encode = "json"
  )
  
  content <- content(response, "text")
  parsed_content <- fromJSON(content)
  
  return(parsed_content$choices$message$content)
}

  