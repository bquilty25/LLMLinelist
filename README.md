# LLMLinelist: LLM-Assisted Processing of Free-Text Outbreak Reports to Tabular Data

![A screenshot of the app](screenshot.png)

## Overview

This Shiny app is designed to demonstrate the LLM-assisted processing of free-text outbreak reports into epidemiologically useful tabular data - i.e., a linelist. It utilizes a small open-source LLM run locally on your machine to generate a table of cases and contacts from a free-text outbreak report. The app allows users to paste a report into the interface for automatic processing.

**Warning: this is a work in progress and hence there will be bugs. LLMs are not perfect and are prone to hallucination (especially if the input data is vague or unclear), so please double-check any output generated.**

**Known bugs:
Small local LLMs such as Llama 2 and Mistral 7B appear to have a much higher error rate than OpenAI models when requesting a specified format, e.g. CSV or JSON, causing the app to crash. Next steps are to modify to allow the choice of using local or OpenAI API models (or upgrade compute infrastructure to allow for larger local models to be used).**

## Getting Started

### Prerequisites

-   R & R Studio (<https://www.r-project.org/>)
-   LM Studio (<https://lmstudio.ai/>)
-   Python (version 3.7 or higher)
-   A reasonably powerful machine (tested on a 2021 Macbook Pro M1 Pro with 16GB RAM; a report took about 10-30 seconds to process)

### Installation

1.  Clone this repository to your local machine:

    ``` bash
    git clone https://github.com/bquilty25/ai_contact_tracing_diaries.git
    ```

2.  Open the R project in your preferred R development environment (RStudio recommended when using Shiny).

### Install the OpenAI Python library

1.  Open a new terminal in R.

2.  Run the following commands to create and activate a virtual environment:

    ``` bash
    python -m venv aienv
    source aienv/bin/activate  # On Windows, use 'myenv\Scripts\activate'
    ```

3.  Install the OpenAI Python library:

    ``` bash
    pip install openai
    ```

## Option 1: Installing and running the local LLM

1. Install LM Studio: Follow the instructions on the [official LM Studio website](https://www.openai.com/lm-studio/) to download and install LM Studio.

2. Download Llama 2 7b Model (or other model of your choice) and host a local inference server
3.  Open LM Studio.
4.  Navigate to the Search tab and search for "TheBloke/Llama-2-7B-Chat-GGUF" (not GGUML!)
5.  Download the "Q5_K_M" model (4.78GB, recommended).
6.  Choose an appropriate preset on the right-hand side (e.g., "ChatML") - some perform better than others.
6.  Navigate to the "Local Server" tab ("\<-\>" icon) and click "Start Server".

## Option 2: Run via GPT-4 using the OpenAI API

1. Sign up for an OpenAI account.
2. Navigate to the "API Keys" tab and create a new API key.
3. Copy your OpenAI API key and run the following command in R (replacing `sk-xxx` with your API key) to add it to your R environment:

``` r
Sys.setenv(OPENAI_API_KEY = "sk-xxx")
```

Note: this costs money, so make sure you monitor your usage and set a budget.

### Running the app

1.  Return to R and install the required R packages:

    `r install.packages(c("shiny", "reticulate", "shinyjs", "future", "shinycssloaders", "shinythemes", "DT", "tidyverse", "openai", "ggplot2", "ggpubr"))`

2.  Run the Shiny app:

    ``` r
    shiny::runApp()
    ```

## Usage

1.  Open the app in your web browser.

2.  Enter text, or choose an example input.

3.  Click the "Process Text" button to initiate the processing.

4.  Explore the generated table and timeline plot in their respective tabs.

5.  Export table in your required format.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or create a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

-   Developed by Billy Quilty, Research Fellow, LSHTM

-   Many thanks to:

    -   Pratik Gupte

    -   Sam Clifford

    -   Noel Kennedy

    -   Adam Kucharski

    -   Roz Eggo

    -   Chrissy Roberts

    -   Michael Marks

    -   and others in CMMID and at LSHTM for their useful input and feedback.
