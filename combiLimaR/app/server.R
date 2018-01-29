library(leaflet)
library(RColorBrewer)
library(scales)
library(magrittr)
library(jsonlite)
library(stringr)
library(sp)
library(plyr)
library(tidyverse)
library(data.table)
# setwd("app/")
source("functions.R")

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
# set.seed(100)
# zipdata <- allzips[sample.int(nrow(allzips), 10000),]
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
# trip_stops_df <- get_data('./../data/')
# saveRDS(trip_stops_df, file="app/data/trip-stops.RDS")
trip_stops_df <- readRDS("data/trip-stops.rds")
latlong <- list(lat = -12.102700, lon = -77.047246)
splines <- get_splines(trip_stops_df, latlong)

function(input, output, session) {

  ## Interactive Map ###########################################

  # Create the map
  output$map <- renderLeaflet({
    leaflet(splines) %>% 
          addProviderTiles("CartoDB.DarkMatterNoLabels") %>% 
          addPolylines(opacity = 0.4, 
                       weight = 3, 
                       color = c("#ffff00", "#ff4f00", "#3fff00", "#ffaa00", "#A4ff00")) %>% 
          addMarkers(lat= latlong$lat, lng= latlong$lon)
  })

  # A reactive expression that returns the set of zips that are
  # in bounds right now
  # zipsInBounds <- reactive({
  #   if (is.null(input$map_bounds))
  #     return(zipdata[FALSE,])
  #   bounds <- input$map_bounds
  #   latRng <- range(bounds$north, bounds$south)
  #   lngRng <- range(bounds$east, bounds$west)
  # 
  #   subset(zipdata,
  #     latitude >= latRng[1] & latitude <= latRng[2] &
  #       longitude >= lngRng[1] & longitude <= lngRng[2])
  # })

  # Precalculate the breaks we'll need for the two histograms
  # centileBreaks <- hist(plot = FALSE, allzips$centile, breaks = 20)$breaks

  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  observe({
    # colorBy <- input$color
    temp <- input$map_click
    if (temp %>% is.null){
        return()
    }
    latlong <- list(lat = temp$lat, lon = temp$lng)
    # browser()
    splines <- get_splines(trip_stops_df, latlong)
    if (splines %>% is.null){
        return()
    }
    leafletProxy("map", data = splines) %>%
        clearMarkers() %>% 
        clearShapes() %>%
        addPolylines(opacity = 0.4, 
                     weight = 3, 
                     color = c("#ffff00", "#ff4f00", "#3fff00", "#ffaa00", "#A4ff00")) %>% 
        addMarkers(lat= latlong$lat, lng= latlong$lon)
  })


  # # When map is clicked, show a popup with city info
  # observe({
  #   leafletProxy("map") %>% clearPopups()
  #   event <- input$map_shape_click
  #   if (is.null(event))
  #     return()
  # 
  #   isolate({
  #     showZipcodePopup(event$id, event$lat, event$lng)
  #   })
  # })

}
