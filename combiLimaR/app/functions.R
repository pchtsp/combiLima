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

get_latlong = function(path, id) {
    routes_paths_id = sprintf("%s%s_stops.json", path, id)
    data = routes_paths_id[1] %>% read_json()
    list(
        lat = data %>% sapply("[[", "lat"),
        long = data %>% sapply("[[", "lon")
    )
}

get_trips = function(path, id) {
    routes_paths_id = sprintf("%s%s_trips.json", path, id)
    data = routes_paths_id[1] %>% read_json()
    data %>% sapply('[[', 'id') %>% str_replace_all(":", "")
}

get_trip_geometry <- function(path, id){
    file_name = sprintf("%s%s_geometry.json", path, id)
    if (file.exists(file_name) %>% not){
        return(NULL)
    }
    file_name %>% read_json() %>% extract2('points')
}

get_trip_stops <- function(path, id){
    file_name = sprintf("%s%s_stops.json", path, id)
    if (file.exists(file_name) %>% not){
        return(NULL)
    }
    file_name %>% read_json()
}

dif_points <-  function(lat1, long1, lat2, long2){
    abs(lat1 - lat2)+abs(long1-long2)
}

order_points = function(lines_df) {
    points = list()
    position = 1
    original_df = lines_df
    lines_df$dist = 0
    prev = 0
    
    while (nrow(lines_df) > 0){
        point = lines_df[1,]
        points[[point$id]] = list(position, point$dist, prev)
        prev = point$id
        lines_df = 
            lines_df[-1,] %>% 
            mutate(dist = dif_points(point$lat, point$long, lat, long)) %>% 
            arrange(dist)
        position = position + 1
    }
    data.frame(pos = points %>% sapply("[[", 1),
               dist = points %>% sapply("[[", 2),
               prev = points %>% sapply("[[", 3),
               stringsAsFactors = FALSE
               ) %>% 
        mutate(id = rownames(.)) %>% 
        left_join(original_df, by="id") %>% 
        arrange(pos)
}

get_data <- function(relative_path){
    # relative_path = './../data/'
    
    # stops_path = relative_path %>% paste0("stops.json")
    routes_path = relative_path %>% paste0("routes.json")
    routes_paths = relative_path %>% paste0("routes/")
    routes_trips = relative_path %>% paste0("trips/")
    
    # we get the route's trips
    # and get the trips geometry
    
    routes_data = jsonlite::read_json(routes_path)
    
    routes_ids = sapply(routes_data, "[[", "id") %>% str_replace_all(":", "")
    
    colors = routes_data %>% sapply("[[", 'color')
    shortNames = routes_data %>% sapply("[[", 'shortName')
    franjas = 
        routes_data %>% 
        sapply("[[", "routeDesc") %>%
        lapply(fromJSON) %>%
        sapply("[[", 'colores_franjas_hexa')
    companies <- 
        routes_data %>%
        sapply("[[", "routeDesc") %>%
        lapply(fromJSON) %>%
        lapply("[[", 'agency_name')
    
    routes_info <- 
        data.table(route = routes_ids) %>% 
        mutate(company= companies,
               color = colors,
               shortName = shortNames,
               franja = franjas)

    names(routes_ids) = routes_ids
    # route_lat_long = lapply(routes_ids, get_latlong, path=routes_paths)
    route_trips = lapply(routes_ids, get_trips, path=routes_paths)
    
    # route_lat_long_df = route_lat_long %>% bind_rows(.id = 'route')
    
    # we temporary filter and get only the first one:
    route_trips = lapply(route_trips, "[[", 1)
    
    trips_ids = route_trips %>% unlist
    names(trips_ids) = names(route_trips)
    trip_stops = lapply(trips_ids, get_trip_stops, path=routes_trips) %>% Filter(. %>% is.null %>% not, .)
    trip_stops_df <- 
        trip_stops %>% 
        lapply(bind_rows) %>% 
        bind_rows(.id="route") %>% 
        inner_join(routes_info, by="route")
    trip_stops_df
}


filter_routes <- function(input_data, latlong){
    # latlong = list(lat = -11.9725226, lon = -77.0814621)
    # latlong = list(lat = -12.102700, lon = -77.047246)
    dif = 0.005
    max_coord = list(lat = latlong$lat + dif, lon = latlong$lon + dif)
    min_coord = list(lat = latlong$lat - dif, lon = latlong$lon - dif)
    
    input_data %>% 
        filter(lat >= min_coord$lat &
                   lat <= max_coord$lat &
                   lon>=min_coord$lon & 
                   lon <= max_coord$lon) %>% 
        mutate(distance = dif_points(lat, lon, max_coord$lat, max_coord$lon)) %>% 
        group_by(route) %>% 
        summarise(min_dist = min(distance, na.rm = T)) %>% 
        arrange(route, min_dist) %>% 
        ungroup() %>% 
        head(10) %>% 
        dplyr::first(.)
}

get_intersections <- function(trip_stops_df_f){
    multi_stops <- 
        trip_stops_df_f %>% 
        group_by(id) %>% 
        summarise(nr = n() %>% as.double()) %>% 
        filter(nr > 1)
    
    stops_info <- 
        trip_stops_df_f %>% 
        inner_join(multi_stops)
    
    stops_info
}

spread_intersections <- function(trip_stops_df_f, stops_info, max_dist=0.0001){
    max_dist_lat = max_dist
    max_dist_lon = max_dist
    
    new_pos <-
        stops_info %>% 
        arrange(id, route) %>% 
        group_by(id) %>% 
        mutate(route_pos = row_number() -nr/2 - 0.5,
               lon = lon + max_dist_lon*route_pos,
               lat = lat + max_dist_lat*route_pos) %>% 
        ungroup() %>% 
        select(route, id, lat_n=lat, lon_n=lon)
    
    trip_stops_df_n <- 
        trip_stops_df_f %>% 
        left_join(new_pos) %>% 
        mutate(lat = if_else(lat_n %>% is.na, lat, lat_n),
               lon = if_else(lon_n %>% is.na, lon, lon_n))
    
    trip_stops_df_n
}


get_splines <- function(input_data){

    if (nrow(input_data) == 0){
        return(NULL)
    }
    # browser()
    listCoors <-  
        input_data %>% 
        plyr::dlply("route") %>% 
        lapply(select, lon= lon, lat = lat)
    
    spl_lst <- listCoors %>% names %>% lapply(function(id) { Line(listCoors[[id]]) %>% Lines(ID=id) }) %>% SpatialLines()
    spl_lst
}
