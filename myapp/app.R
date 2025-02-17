library(magrittr)
library(data.table)
# library(ggplot2)
# library(ncdf4)
# library(lattice)
# library(RColorBrewer)
# library(raster)
library(googlesheets4)
library(shiny)
library(bslib)

ui <- page_sidebar(
  title = "Chiffres coup de poing",
  # sidebar = sidebar("Types de carte", position = "top"),
  helpText(""),
  sidebar = sidebar(radioButtons(
    inputId = "theme",
    label = "Thèmes",
    choices = c("Loading..." = ""),
  )),  # Add some custom CSS for styling
  tags$head(
    tags$style(HTML("
      .card {
        margin: 10px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        border-radius: 8px;
        height: auto;  /* Make height auto to fit content */
      }
      .card-title {
        font-size: 1.5em;
      }
      .card-body {
        padding: 20px;
      }
      .card-container {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between; /* Ensures cards take up available horizontal space */
        gap: 20px;
      }
      .card-container .card {
        flex: 1 1 300px;  /* Cards take up at least 300px width but can grow */
        max-width: 500px;  /* Set a max width to prevent cards from becoming too wide */
        min-height: 150px;  /* Ensure minimum height */
      }
      .main-content {
        padding: 20px;
      }
    "))
  ),
  # card(card_header("Fact 1"),
  #      "Source"),
  # card(card_header("Fact 2"),
  #      "Source")
  uiOutput("cards")
)

# Define server logic ----
server <- function(input, output, session) {
  # googlesheets4::gs4_auth()
  
  repo_owner = "ValentinTheo"
  repo_name = "Chiffres-coup-de-poing-data"
  branch = "master"
  
  dataset =
    reactive({
      data_path = paste(paste("https://raw.githubusercontent.com",
                              repo_owner,repo_name,branch,sep="/"),"/chiffres.csv",sep="")
       read.csv(data_path)
      })
  
  observe({
    dataset = dataset()
    req(dataset)  
    updateRadioButtons(session, "theme", 
                       choices = unique(dataset$Theme))
  })
  
  d <- reactive({
    req(dataset)
    req(input$theme)
    # req(d)
    data = dataset()
    setDT(data)
    data[Theme == input$theme]
  })


  output$cards = renderUI({
    data = d()
    div(class = "card-container",
        lapply(1:nrow(data), function(i) {
          div(class = "card",
              div(class = "card-body",
                  div(class = "card-body",
                      h4(class = "card-title", data$Phrase[i]),
                      p(class = "card-text", data$Source[i])
                  )
              )
          )
        })
    )
    # renderText({
    # d()$Phrase
  })
  
  
  # output$data_table <- renderTable({
  #   dataset()
  # })
}

# Run the app ----
shinyApp(ui = ui, server = server)
