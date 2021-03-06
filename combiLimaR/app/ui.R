library(leaflet)

# # Choices for drop-downs
# vars <- c(
#   "Is SuperZIP?" = "superzip",
#   "Centile score" = "centile",
#   "College education" = "college",
#   "Median income" = "income",
#   "Population" = "adultpop"
# )
bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    # div(class="outer",
    h2("combiLima"),
    p("Click on the map to get the closest lines aroud you"),
      # tags$head(
        # Include our custom CSS
        # includeCSS("styles.css")
        # ,includeScript("gomap.js")
      # ),

      # If not using custom CSS, set height of leafletOutput to a number instead of percent
      leafletOutput("map", width="100%", height="100%")

      # Shiny versions prior to 0.11 should use class = "modal" instead.
      # absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
      #   draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
      #   width = 330, height = "auto",
      # 
      # )
      # ,tags$div(id="cite",
        # 'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960–2010'), ' by Charles Murray (Crown Forum, 2012).'
      # )
    # )
)
