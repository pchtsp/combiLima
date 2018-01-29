library(leaflet)
library(magrittr)
library(jsonlite)
library(stringr)
library(sp)
library(plyr)
library(tidyverse)
library(data.table)
# library(gepaf)

# test <- function(id) { Line(. %>% select(lon, lot)) %>% Lines(ID=route) }
# route_sample <- trip_stops_df %>% distinct(route) %>% dplyr::first() %>% sample(20)

start <- listCoors %>% sample(1) %>% extract2(1) %>% sample_n(1)

leaflet(spl_lst) %>%
    addProviderTiles("CartoDB.DarkMatterNoLabels") %>%
    # setView(start$lat, start$lon, zoom = 9) %>% s
    addPolylines(opacity = 0.4, weight = 3, color = c("#ffff00", "#ff4f00", "#3fff00", "#ffaa00", "#A4ff00")) %>% 
    addMarkers(lat= latlong$lat, lng= latlong$lon)

# alternative to graph SpatialLines is a dataframe. But it only works with one polyline:

# leaflet(data) %>% 
#     addProviderTiles("CartoDB.DarkMatterNoLabels") %>%
#     addPolylines(lng = ~lon, lat = ~lat,
#                  opacity = 0.4, weight = 3, color = c("#ffff00", "#ff4f00", "#3fff00", "#ffaa00", "#A4ff00")) 
# 

# alternative to get stops is to get geometry. But it's slower.

# trip_geom = lapply(trips_ids, get_trip_geometry, path=routes_trips) %>% Filter(. %>% is.null %>% not, .)
# listCoors <- trip_geom %>% sample(5) %>% lapply(gepaf::decodePolyline)
