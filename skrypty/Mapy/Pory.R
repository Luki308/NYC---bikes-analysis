library(dplyr)
library(leaflet)
library(lubridate) #hour()
library(tigris)
library(viridis)


load("shiny/Stacje_z_osiedlami.RData")

k22 <- read.csv("data/lokalizacja/202204-citibike-tripdata.csv")
k22 <- as.data.frame(k22)

k22 %>%
  mutate(hour_start = hour(started_at), hour_end = hour(ended_at)) ->k22

start_station_morning <-k22 %>%
  select(start_station_id, hour_start)  %>% 
  filter(hour_start >= 7 & hour_start < 10) %>%
  group_by(start_station_id) %>%
  summarise(Count = n()) %>%
  left_join(y = stacje,
            by = c("start_station_id" = "ID")) %>%
  group_by(neighborhood) %>%
  summarise(Count = sum(Count))

end_station_morning <-k22 %>%
  select(end_station_id, hour_end)  %>% 
  filter(hour_end >= 7 & hour_end < 10) %>%
  group_by(end_station_id) %>%
  summarise(Count = n()) %>%
  left_join(y = stacje,
            by = c("end_station_id" = "ID")) %>%
  group_by(neighborhood) %>%
  summarise(Count = sum(Count))

busy_connections <- k22 %>%
  #filter(start_station_id != end_station_id) %>%
  filter(hour_start >= 7 & hour_start < 10) %>%
  group_by(start_station_id,end_station_id, start_lng, start_lat, end_lng, end_lat) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count)) %>% head(10)

busy_connections_start <- busy_connections %>%
  ungroup() %>%
  select(ID = start_station_id, Lng = start_lng, Lat = start_lat, Count) %>%
  mutate(group = LETTERS[1:10])

busy_connections_end <- busy_connections %>%
  ungroup() %>%
  select(ID = end_station_id, Lng = end_lng, Lat = end_lat, Count) %>%
  mutate(group = LETTERS[1:10])

busy_connections <- as.data.frame(rbind(busy_connections_start, busy_connections_end))


plot_data1 <- geo_join(nyc_neighborhoods, start_station_morning,
                      "neighborhood", "neighborhood",
                      how = 'inner')

plot_data2 <- geo_join(nyc_neighborhoods, end_station_morning,
                       "neighborhood", "neighborhood",
                       how = 'inner')


pal <- colorNumeric(palette = heat.colors(10,rev = T),
                    domain = range(plot_data2@data$Count, na.rm=T))

# pal2 <- colorNumeric(palette = viridis::magma(5,0.8,1,0),
#                      domain = 90:120)

morning_compare <- inner_join(start_station_morning,end_station_morning, by = "neighborhood") %>%
  rename(Count_start = Count.x , Count_end = Count.y ) %>%
  filter(Count_start >= 1.5*Count_end  & Count_start > 10000) %>%
  arrange(desc(Count_start))

morning_compare_end <- inner_join(start_station_morning,end_station_morning, by = "neighborhood") %>%
  rename(Count_start = Count.x , Count_end = Count.y ) %>%
  filter(Count_end >= 1.5*Count_start  & Count_end > 10000) %>%
  arrange(desc(Count_end))

########### Rysowanie map

# leaflet(plot_data1) %>%
#   addTiles() %>%
#   addPolygons(color = "black", weight = 1 , opacity = 1,
#               fillColor = ~pal(Count), fillOpacity = 0.9,
#               popup = ~paste(neighborhood, "<br/> Liczba:", Count)) %>%
#   addLegend("bottomright", pal = pal, values = ~Count,
#             title = "Liczba przejazdow (Start)",
#             opacity = 1
#   ) %>%
#   addProviderTiles("CartoDB.Positron") %>%
#   setView(-74.00, 40.71, zoom = 12) -> morning_start
# 
# for(l in LETTERS[1:10]){
#   morning_start <- morning_start %>%
#     addPolylines(data = busy_connections[busy_connections$group == l,],
#                  lng = ~Lng,
#                  lat = ~Lat,
#                  color = "black",#~pal2(Count),
#                  opacity = 1,
#                  popup = ~paste("Liczba:", Count))
# }
# morning_start

################### END

# leaflet(plot_data2) %>%
#   addTiles() %>%
#   addPolygons(color = "black", weight = 1 , opacity = 1,
#               fillColor = ~pal(Count), fillOpacity = 0.9,
#               popup = ~paste(neighborhood, "<br/> Liczba:", Count)) %>%
#   addLegend("bottomright", pal = pal, values = ~Count,
#             title = "Liczba przejazdow (Koniec)",
#             opacity = 1
#   ) %>%
#   addProviderTiles("CartoDB.Positron") %>%
#   setView(-74.00, 40.71, zoom = 12) -> morning_end


# ls()
# rm(list = ls()[-c(1,6,7,8,9,10,11)])
# save.image(file = "shiny/Morning_maps_data.RData")
