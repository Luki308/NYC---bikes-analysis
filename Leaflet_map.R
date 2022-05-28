install.packages("leaflet")
library(leaflet)
library(dplyr)
library(sp)
library(tigris) #geo_join

load("Dane_lokalizacyjne.RData")

plot_data <- geo_join(nyc_neighborhoods, ilosc_w_neighborhood,
                      "neighborhood", "neighborhood")

pal <- colorNumeric(palette = heat.colors(10,rev = T),
                    domain = range(plot_data@data$Count, na.rm=T))

leaflet(plot_data) %>%
  addTiles() %>%
  addPolygons(color = "black", weight = 1 , opacity = 1,
              fillColor = ~pal(Count), fillOpacity = 0.7,
              popup = ~neighborhood) %>%
  addLegend("bottomright", pal = pal, values = ~Count,
            title = "Liczba stacji w osiedlach",
            opacity = 1
  )
  setView(-74.00, 40.71, zoom = 12) %>%
  addProviderTiles
?addPolygons
?colorNumeric
  