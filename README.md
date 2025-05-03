# RSVPlease - Wedding RSVP Data Converter

## Project Overview

A Shiny application that transforms wedding RSVP data from The Knot into a streamlined format for place cards and table assignments. This tool bridges the gap between online RSVP platforms and the practical needs of wedding day logistics.


https://github.com/user-attachments/assets/96775ad1-5a1d-4c41-a98a-c57c39bb2a6d


## The Challenge

Wedding planners and couples face a common frustration: while platforms like The Knot provide excellent RSVP collection, they export data in formats that aren't immediately usable for creating place cards with meal indicators. This application solves that problem through intelligent data transformation.

## Origin Story

I created this tool after experiencing this challenge firsthand during my own wedding planning. Our incredibly talented stationery designer needed our guest list with meal choices in a specific format to create beautiful table cards. After spending hours manually reformatting our RSVP data from The Knot, I realized I could automate this process not just for us, but for her future clients as well. What began as solving a personal pain point evolved into a tool that simplifies an often overlooked aspect of wedding planning.

## Key Features

### Smart Data Processing
- Automatically detects and maps columns from various CSV export formats
- Intelligently identifies meal choices using pattern recognition
- Transforms guest information into a consistent, standardized structure
- Outputs a clean CSV with name, meal code, and last name fields

### Intuitive Interface
- Clean, step-by-step workflow for uploading and transforming data
- Interactive preview of transformed data before download
- Customizable meal codes to match wedding-specific needs
- Responsive design that works across devices

### Error Handling
- Robust validation catches common data issues
- Clear error messages guide users to solutions
- Fallback options when automatic detection isn't possible

## Technical Implementation

The application leverages several powerful R packages:
- **Shiny** for the interactive web interface
- **dplyr** for data transformation pipelines
- **DT** for interactive data previews
- **readr** for robust CSV handling
- **shinythemes** for clean, professional UI design

The code is structured around reactive programming principles, with clear separation between data processing logic and UI components. Error handling is implemented throughout the application to ensure reliability.

## Impact

This tool reduces a 2-3 hour manual process to under 5 minutes, eliminating tedious data reformatting while improving accuracy. Wedding planners can focus on creating beautiful table arrangements rather than manipulating spreadsheets.

## Use Case Example

After collecting 150 RSVPs through The Knot, a wedding planner needs to create place cards that show each guest's meal choice using a single letter code (B for beef, C for chicken, V for vegetarian). This application:

1. Takes the raw CSV export from The Knot
2. Filters out non-attending guests
3. Creates properly formatted guest names
4. Applies the appropriate meal code to each guest
5. Outputs a clean CSV ready for mail merge with place card templates

## Behind the Design

The application was developed after observing wedding planners struggling with this exact data transformation challenge. The design prioritizes simplicity and reliability, making it accessible even to users with minimal technical experience.

## Future Directions

The code architecture allows for future enhancements such as:
- Table assignment algorithms
- Direct integration with place card printing services
- Multi-event support for wedding weekends
- Extended guest attribute handling
