# Mapa pokazująca zagęszczenie korzystania ze stacji rowerowych w poszczególnych
# osiedlach NYC
#https://rpubs.com/jhofman/nycmaps
install.packages("sf")
load("Dane_lokalizacyjne.RData")
library(ggplot2)
library(dplyr)
library(httr)
library(rgdal)
library(broom)
library(maptools)
library(sf)

r <- GET('http://data.beta.nyc//dataset/0ff93d2d-90ba-457c-9f7e-39e47bf2ac5f/resource/35dd04fb-81b3-479b-a074-a27a37888ce7/download/d085e2f8d0b54d4590b1e7d1f35594c1pediacitiesnycneighborhoods.geojson')
nyc_neighborhoods <- readOGR(content(r,'text'), 'OGRGeoJSON', verbose = F)

nyc_neighborhoods_df <- tidy(nyc_neighborhoods)


# Przypisywanie stacjom okolicy (neighborhood)
points <- stacje[,c(3,4)]
points_spdf <- points
coordinates(points_spdf) <- ~Lng + Lat
proj4string(points_spdf) <- proj4string(nyc_neighborhoods)
matches <- over(points_spdf, nyc_neighborhoods)
points <- cbind (points, matches)
points

ilosc_w_neighborhood <- points %>%
  group_by(neighborhood) %>%
  summarise(Count = n())

plot_data <- tidy(nyc_neighborhoods, region="neighborhood") %>%
  left_join(., ilosc_w_neighborhood, by=c("id"="neighborhood")) %>%
  filter(!is.na(Count))

ggplot() + 
  geom_polygon(data=plot_data, aes(x=long, y=lat, group=group, color = "red", fill = Count), alpha = 0.75)

