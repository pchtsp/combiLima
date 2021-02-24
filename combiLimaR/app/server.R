# setwd("app/")
source("functions.R")
# TODO list:
# colors according to line colors:
# label html with colors, image, etc.
# jugar con colores de mapa de fondo

# trip_stops_df <- get_data('./../../data/')
# saveRDS(trip_stops_df, file="data/trip-stops.rds")
trip_stops_df <- readRDS("data/trip-stops.rds")
latlong <- list(lat = -12.102700, lon = -77.047246)
routes_list <- filter_routes(trip_stops_df, latlong) %>% data.table(route=.) 
trip_stops_df_f <- trip_stops_df %>% inner_join(routes_list)
stops_info <- get_intersections(trip_stops_df_f)
trip_stops_df_f_n <- spread_intersections(trip_stops_df_f, stops_info)
splines <- get_splines(trip_stops_df_f_n)

drop_dir("combiLima", dtoken = token)
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
        latlong <- list(lat = -12.102700, lon = -77.047246)
    } else {
        latlong <- list(lat = temp$lat, lon = temp$lng)   
    }
    # browser()
    routes_list <- filter_routes(trip_stops_df, latlong) %>% data.table(route=.) 
    
    trip_stops_df_f <- trip_stops_df %>% inner_join(routes_list)
    
    stops_info <- get_intersections(trip_stops_df_f)
    trip_stops_df_f_n <- spread_intersections(trip_stops_df_f, stops_info, max_dist = 0.0004)
    splines <- get_splines(trip_stops_df_f_n)
    
    route_ids <- trip_stops_df_f %>% distinct(route, .keep_all = T)
    routes_info <- routes_list %>% inner_join(route_ids, by='route')
    
    
    imgs = paste0("img/shortName_all/", routes_info$shortName, '.jpg')
    html_code <- sprintf('<img src="%s" height="300"><p>%s</p>', 
                         imgs, 
                         routes_info$company)
    labels <- html_code %>% lapply(HTML)
    circles_n <- stops_info %>% distinct(id, .keep_all = TRUE)
    # browser()
    circles <- 
        stops_info %>%
        mutate(img = paste0("img/shortName_all/", shortName, '.jpg'),
               html_code = sprintf('<img src="%s" height="50"><p>%s</p>', 
                                   img, 
                                   company)) %>% 
        group_by(id) %>% 
        summarise(html_code = paste(html_code, collapse ="")) %>%
        inner_join(circles_n) %>% 
        data.table
    # ids <- routes_info$route_id %>% as.character()
    
# 
    if (splines %>% is.null){
        return()
    }
    # browser()
    leafletProxy("map", data = splines) %>%
        clearMarkers() %>% 
        clearShapes() %>%
        addPolylines(opacity=0.4, 
                     weight=15, 
                     color=c("#ffff00", "#ff4f00", "#3fff00", "#ffaa00", "#A4ff00"),
                     label=labels,
                     # layerId=ids,
                     labelOptions=labelOptions(noHide = TRUE, textsize = "15px")) %>% 
        addMarkers(lat= latlong$lat, lng= latlong$lon) %>% 
        addCircles(lat = circles$lat, lng = circles$lon, radius = 30, popup=circles$html_code)
  })
  
  # This observer is for the lines themselves
  observe({
      # if (input$map_shape_mouseover %>% is.null){
      #     return()
      # }
      # print(input$map_shape_mouseover)

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
