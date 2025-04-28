# app.R
library(shiny)
library(readr)
library(dplyr)
library(DT)
library(shinythemes)

ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("RSVPlease - Wedding Data Converter"),
  
  navlistPanel(
    widths = c(3, 9),
    tabPanel("Convert Data",
             fluidRow(
               column(12,
                      wellPanel(
                        h3("Upload RSVP Data from The Knot"),
                        p("Upload the CSV file exported from The Knot's RSVP system."),
                        fileInput("rsvp_file", "Choose CSV File", 
                                  accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
                        
                        conditionalPanel(
                          condition = "output.file_uploaded",
                          hr(),
                          h4("Entree Mapping"),
                          p("Map the entree choices to single letter codes for place cards:"),
                          
                          fluidRow(
                            column(4, selectInput("beef_option", "Beef Option:", choices = NULL, multiple = TRUE)),
                            column(2, textInput("beef_code", "Code:", value = "B"))
                          ),
                          fluidRow(
                            column(4, selectInput("chicken_option", "Chicken Option:", choices = NULL, multiple = TRUE)),
                            column(2, textInput("chicken_code", "Code:", value = "C"))
                          ),
                          fluidRow(
                            column(4, selectInput("vegetarian_option", "Vegetarian Option:", choices = NULL, multiple = TRUE)),
                            column(2, textInput("vegetarian_code", "Code:", value = "V"))
                          ),
                          fluidRow(
                            column(4, selectInput("other_options", "Other Options:", choices = NULL, multiple = TRUE)),
                            column(2, textInput("other_code", "Code:", value = "O"))
                          ),
                          
                          hr(),
                          h4("Column Mapping"),
                          fluidRow(
                            column(6, selectInput("first_name_col", "First Name Column:", choices = NULL)),
                            column(6, selectInput("last_name_col", "Last Name Column:", choices = NULL))
                          ),
                          fluidRow(
                            column(6, selectInput("attendance_col", "Attendance Column:", choices = NULL)),
                            column(6, selectInput("attending_value", "Attending Value:", choices = NULL))
                          ),
                          fluidRow(
                            column(12, selectInput("meal_col", "Meal Selection Column:", choices = NULL))
                          ),
                          
                          hr(),
                          actionButton("convert_btn", "Convert RSVP Data", class = "btn-primary")
                        )
                      )
               )
             ),
             
             conditionalPanel(
               condition = "output.conversion_done",
               fluidRow(
                 column(12,
                        h3("Converted RSVP Data"),
                        p("Preview of converted data in the format needed for place cards:"),
                        DTOutput("preview_table"),
                        downloadButton("download_data", "Download Converted Data", class = "btn-success")
                 )
               )
             )
    ),
    
    tabPanel("Instructions",
             fluidRow(
               column(12,
                      wellPanel(
                        h3("How to Use This Tool"),
                        tags$ol(
                          tags$li("Export your RSVP list from The Knot as a CSV file"),
                          tags$li("Upload the CSV file using the 'Choose CSV File' button"),
                          tags$li("Map the columns and values to match your RSVP data structure"),
                          tags$li("Click 'Convert RSVP Data' to process the information"),
                          tags$li("Preview the results and download the converted CSV file")
                        ),
                        h3("About The Knot Export"),
                        p("This tool expects a CSV export from The Knot with columns for first name, last name, 
              attendance status, and meal selection. The tool will automatically detect these columns 
              but you may need to adjust the mapping if your export has different column names."),
                        h3("For Wedding Planners"),
                        p("This tool can be used for any wedding client who uses The Knot for RSVPs. 
              The output format includes each guest's full name, a single letter code for their 
              meal choice, and their last name (useful for organizing place cards by table).")
                      )
               )
             )
    ),
    
    tabPanel("About",
             fluidRow(
               column(12,
                      wellPanel(
                        h3("Wedding RSVP Data Converter"),
                        p("This application was created to simplify the process of converting RSVP data 
              from The Knot into a format optimized for creating wedding place cards."),
                        h4("Features:"),
                        tags$ul(
                          tags$li("Automated data conversion from The Knot's CSV export format"),
                          tags$li("Customizable meal code mapping"),
                          tags$li("Preview of converted data before download"),
                          tags$li("Simple interface for wedding planners to use with any client")
                        ),
                        hr(),
                        p("Version 1.0", style = "text-align: right;")
                      )
               )
             )
    )
  )
)

server <- function(input, output, session) {
  # Reactive value to store uploaded data
  rsvp_data <- reactiveVal(NULL)
  
  # Reactive value to store converted data
  converted_data <- reactiveVal(NULL)
  
  output$file_uploaded <- reactive({
    return(!is.null(rsvp_data()))
  })
  outputOptions(output, "file_uploaded", suspendWhenHidden = FALSE)
  
  output$conversion_done <- reactive({
    return(!is.null(converted_data()))
  })
  outputOptions(output, "conversion_done", suspendWhenHidden = FALSE)
  
  # Handle file upload and update column mapping options
  observeEvent(input$rsvp_file, {
    req(input$rsvp_file)
    
    # Read the uploaded file with more robust error handling
    df <- tryCatch({
      read_csv(input$rsvp_file$datapath, show_col_types = FALSE)
    }, error = function(e) {
      showNotification(paste("Error reading CSV file:", e$message), type = "error")
      return(NULL)
    })
    
    if(is.null(df)) {
      return(NULL)
    }
    
    rsvp_data(df)
    
    # Update column selection inputs
    column_names <- names(df)
    updateSelectInput(session, "first_name_col", choices = column_names, 
                      selected = if("First Name" %in% column_names) "First Name" else column_names[1])
    updateSelectInput(session, "last_name_col", choices = column_names, 
                      selected = if("Last Name" %in% column_names) "Last Name" else column_names[2])
    
    # Try to find attendance column
    attendance_cols <- column_names[grepl("RSVP|Attending|Attendance", column_names, ignore.case = TRUE)]
    updateSelectInput(session, "attendance_col", choices = column_names,
                      selected = if(length(attendance_cols) > 0) attendance_cols[1] else column_names[3])
    
    # After selecting attendance column, update attendance values
    if(length(attendance_cols) > 0) {
      unique_values <- unique(df[[attendance_cols[1]]])
      attending_values <- unique_values[grepl("Attending|Yes|Accept", unique_values, ignore.case = TRUE)]
      updateSelectInput(session, "attending_value", choices = unique_values,
                        selected = if(length(attending_values) > 0) attending_values[1] else unique_values[1])
    } else if(length(column_names) >= 3) {
      unique_values <- unique(df[[column_names[3]]])
      updateSelectInput(session, "attending_value", choices = unique_values, selected = unique_values[1])
    }
    
    # Try to find meal column
    meal_cols <- column_names[grepl("Entree|Meal|Food|Course", column_names, ignore.case = TRUE)]
    meal_col_selected <- if(length(meal_cols) > 0) meal_cols[1] else 
      if(length(column_names) >= 4) column_names[4] else column_names[length(column_names)]
    
    updateSelectInput(session, "meal_col", choices = column_names, selected = meal_col_selected)
    
    # After selecting meal column, update meal options
    if(length(meal_cols) > 0) {
      meal_options <- unique(df[[meal_cols[1]]])
      
      # Try to identify meal types
      beef_options <- meal_options[grepl("Beef|Steak|Tenderloin", meal_options, ignore.case = TRUE)]
      chicken_options <- meal_options[grepl("Chicken|Poultry|Hen", meal_options, ignore.case = TRUE)]
      veg_options <- meal_options[grepl("Veg|Mushroom|Plant|Risotto", meal_options, ignore.case = TRUE)]
      other_options <- setdiff(meal_options, c(beef_options, chicken_options, veg_options))
      
      updateSelectInput(session, "beef_option", choices = meal_options, selected = beef_options)
      updateSelectInput(session, "chicken_option", choices = meal_options, selected = chicken_options)
      updateSelectInput(session, "vegetarian_option", choices = meal_options, selected = veg_options)
      updateSelectInput(session, "other_options", choices = meal_options, selected = other_options)
    } else if(meal_col_selected %in% column_names) {
      meal_options <- unique(df[[meal_col_selected]])
      updateSelectInput(session, "beef_option", choices = meal_options, selected = character(0))
      updateSelectInput(session, "chicken_option", choices = meal_options, selected = character(0))
      updateSelectInput(session, "vegetarian_option", choices = meal_options, selected = character(0))
      updateSelectInput(session, "other_options", choices = meal_options, selected = character(0))
    }
  })
  
  # Update meal options when meal column is changed
  observeEvent(input$meal_col, {
    req(rsvp_data(), input$meal_col)
    
    tryCatch({
      meal_options <- unique(rsvp_data()[[input$meal_col]])
      
      # Try to identify meal types
      beef_options <- meal_options[grepl("Beef|Steak|Tenderloin", meal_options, ignore.case = TRUE)]
      chicken_options <- meal_options[grepl("Chicken|Poultry|Hen", meal_options, ignore.case = TRUE)]
      veg_options <- meal_options[grepl("Veg|Mushroom|Plant|Risotto", meal_options, ignore.case = TRUE)]
      other_options <- setdiff(meal_options, c(beef_options, chicken_options, veg_options))
      
      updateSelectInput(session, "beef_option", choices = meal_options, selected = beef_options)
      updateSelectInput(session, "chicken_option", choices = meal_options, selected = chicken_options)
      updateSelectInput(session, "vegetarian_option", choices = meal_options, selected = veg_options)
      updateSelectInput(session, "other_options", choices = meal_options, selected = other_options)
    }, error = function(e) {
      showNotification("Error updating meal options. Please check your data.", duration = 5)
    })
  })
  
  # Update attendance values when attendance column is changed
  observeEvent(input$attendance_col, {
    req(rsvp_data(), input$attendance_col)
    
    tryCatch({
      unique_values <- unique(rsvp_data()[[input$attendance_col]])
      attending_values <- unique_values[grepl("Attending|Yes|Accept", unique_values, ignore.case = TRUE)]
      
      updateSelectInput(session, "attending_value", choices = unique_values,
                        selected = if(length(attending_values) > 0) attending_values[1] else unique_values[1])
    }, error = function(e) {
      showNotification("Error updating attendance values. Please check your data.", duration = 5)
    })
  })
  
  # Process data when convert button is clicked
  observeEvent(input$convert_btn, {
    req(rsvp_data())
    
    withProgress(message = 'Converting RSVP data...', {
      tryCatch({
        df <- rsvp_data()
        
        # Ensure columns exist
        required_cols <- c(input$first_name_col, input$last_name_col, input$attendance_col, input$meal_col)
        missing_cols <- required_cols[!required_cols %in% names(df)]
        
        if(length(missing_cols) > 0) {
          showNotification(paste("Missing columns:", paste(missing_cols, collapse=", ")), duration = 5)
          return(NULL)
        }
        
        # Filter for attending guests
        df_filtered <- df %>%
          filter(!!sym(input$attendance_col) == input$attending_value)
        
        if(nrow(df_filtered) == 0) {
          showNotification("No attending guests found with the selected criteria.", duration = 5)
          return(NULL)
        }
        
        # Process the filtered data with safe evaluation
        result <- df_filtered %>%
          rowwise() %>%
          mutate(name = paste0(.data[[input$first_name_col]], " ", .data[[input$last_name_col]])) %>%
          ungroup()
        
        # Add food codes
        result <- result %>%
          mutate(
            food = case_when(
              .data[[input$meal_col]] %in% input$beef_option ~ input$beef_code,
              .data[[input$meal_col]] %in% input$chicken_option ~ input$chicken_code,
              .data[[input$meal_col]] %in% input$vegetarian_option ~ input$vegetarian_code,
              .data[[input$meal_col]] %in% input$other_options ~ input$other_code,
              TRUE ~ "?"
            ),
            last_name = .data[[input$last_name_col]]
          ) %>%
          select(name, food, last_name)
        
        converted_data(result)
        
        showNotification("RSVP data converted successfully!", duration = 5)
      }, error = function(e) {
        showNotification(paste("Error converting data:", e$message), duration = 5)
      })
    })
  })
  
  # Render the preview table
  output$preview_table <- renderDT({
    req(converted_data())
    datatable(converted_data(), options = list(pageLength = 10))
  })
  
  # Download handler for converted data
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("wedding_place_cards_", format(Sys.Date(), "%Y%m%d"), ".csv")
    },
    content = function(file) {
      write_csv(converted_data(), file)
    }
  )
}

shinyApp(ui = ui, server = server)