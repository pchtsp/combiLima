library(leaflet)
library(leaflet.extras)
library(magrittr)
library(jsonlite)
library(stringr)
library(sp)
library(tidyverse)
library(data.table)
source("scripts/functions.R")
library(gepaf)

relative_path = './../data/'

stops_path = relative_path %>% paste0("stops.json")

stops_data = jsonlite::read_json(stops_path)

data_t = 
    data.frame(lat = sapply(stops_data, "[[", "lat"),
               long = sapply(stops_data, "[[", "lon"))

leaflet(data_t) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
    addWebGLHeatmap(lng=~long, lat=~lat, size = 600)