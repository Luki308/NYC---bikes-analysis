# Skrypt jest w calosci przeniesiony do shiny, bo inaczej nie dzialalo

# Skrypt generujacy mapy interaktywne na postawie danych wyliczonych w "Stacje_nbh"


library(leaflet)
library(dplyr)
library(sp)
library(tigris) #geo_join

load("shiny/Stacje_z_osiedlami.RData")


######### 1
plot_data <- geo_join(nyc_neighborhoods, ilosc_w_neighborhood,
                      "neighborhood", "neighborhood",
                      how = 'inner')

pal <- colorNumeric(palette = heat.colors(10,rev = T),
                    domain = range(plot_data@data$Count, na.rm=T))

leaflet(plot_data) %>%
  addTiles() %>%
  addPolygons(color = "black", weight = 1 , opacity = 1,
              fillColor = ~pal(Count), fillOpacity = 0.9,
              popup = ~paste(neighborhood, "<br/> Liczba:", Count)) %>%
  addLegend("bottomright", pal = pal, values = ~Count,
            title = "Liczba stacji na osiedlach",
            opacity = 1
  ) %>%
  addProviderTiles("CartoDB.Positron") %>%
  setView(-74.00, 40.71, zoom = 12) -> mapa1

######### 2
plot_data2 <-  geo_join(nyc_neighborhoods, start_station,
                        "neighborhood", "neighborhood",
                        how = 'inner')
pal2 <- colorNumeric(palette = heat.colors(10,rev = T),
                    domain = range(plot_data2@data$Count, na.rm=T))

leaflet(plot_data2) %>%
  addTiles() %>%
  addPolygons(color = "black", weight = 1 , opacity = 1,
              fillColor = ~pal2(Count), fillOpacity = 0.9,
              popup = ~ paste(neighborhood, "<br/> Liczba:", Count)) %>%
  addLegend("bottomright", pal = pal2, values = ~Count,
            title = "Liczba przejazdow (Start)",
            opacity = 1
  ) %>%
  addProviderTiles("CartoDB.Positron") %>%
  setView(-74.00, 40.71, zoom = 12) -> mapa2


######### 3
plot_data3 <-  geo_join(nyc_neighborhoods, end_station,
                        "neighborhood", "neighborhood",
                        how = 'inner')
pal3 <- colorNumeric(palette = heat.colors(10,rev = T),
                     domain = range(plot_data3@data$Count, na.rm=T))

leaflet(plot_data3) %>%
  addTiles() %>%
  addPolygons(color = "black", weight = 1 , opacity = 1,
              fillColor = ~pal3(Count), fillOpacity = 0.9,
              popup = ~paste(neighborhood, "<br/> Liczba:", Count)) %>%
  addLegend("bottomright", pal = pal3, values = ~Count,
            title = "Liczba przejazdow (Koniec)",
            opacity = 1
  ) %>%
  addProviderTiles("CartoDB.Positron") %>%
  setView(-74.00, 40.71, zoom = 12) -> mapa3

#remove(list = c("end_station","ilosc_w_neighborhood","nyc_neighborhoods","plot_data","plot_data2","plot_data3","points","start_station","pal","pal2","pal3"))
