library(dplyr)
library(ggplot2)
library(leaflet)
library(ggmap)
library(sp)

load("shiny/Stacje_z_osiedlami.RData")

k22 <- read.csv("data/lokalizacja/202204-citibike-tripdata.csv")
k22 <- as.data.frame(k22)  

k22 %>%
  mutate(hour_start = hour(started_at), hour_end = hour(ended_at)) ->k22

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


# leaflet(busy_connections)%>%
#   addTiles() %>%
#   addPolygons(data = nyc_neighborhoods) %>%
#   addProviderTiles("CartoDB.Positron") %>%
#   setView(-74.00, 40.71, zoom = 12) ->m

# for(l in LETTERS[1:10]){
#   m <- m %>%
#     addPolylines(data = busy_connections[busy_connections$group == l,],
#                  lng = ~Lng,
#                  lat = ~Lat,
#                  color = "red",
#                  opacity = 1,
#                  popup = ~paste("Liczba:", Count))
#   }
# 
# m

?addPolylines
