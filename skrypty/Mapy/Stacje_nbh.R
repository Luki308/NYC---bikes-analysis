# Skrypt przydzielajacy stacjom osiedla i liczacy liczbe stacji oraz przejazdow

# Mapa pokazująca zagęszczenie korzystania ze stacji rowerowych w poszczególnych
# osiedlach NYC - NIEAKTUALNE

#https://rpubs.com/jhofman/nycmaps
#library(ggplot2)
library(dplyr)
library(httr) #GET geojson
library(rgdal) #readOGR - przekształca geojson na Spatial Data Frame; także sp
library(broom) #tidy - spatial Data Frame -> tibble = data.frame
library(sp)

k22 <- read.csv("data/lokalizacja/202204-citibike-tripdata.csv")
k22 <- as.data.frame(k22)

k22 %>%
  select(ID = start_station_id, Name = start_station_name, Lat = start_lat, Lng = start_lng) %>%
  distinct(ID,Name,Lat,Lng) -> stacje

r <- GET('http://data.beta.nyc//dataset/0ff93d2d-90ba-457c-9f7e-39e47bf2ac5f/resource/35dd04fb-81b3-479b-a074-a27a37888ce7/download/d085e2f8d0b54d4590b1e7d1f35594c1pediacitiesnycneighborhoods.geojson')
nyc_neighborhoods <- readOGR(content(r,'text'), 'OGRGeoJSON', verbose = F)

#nyc_neighborhoods_df <- tidy(nyc_neighborhoods) # wielokąty dla każdego osiedla (rozpoznawanego po id)

#Polaczyc stacje z iloscia przejzadow (startowych + konczonych - osobne kolumny)

# Przypisywanie stacjom okolicy (neighborhood)
points <- stacje[,c(1,2,3,4)]
points_spdf <- points
coordinates(points_spdf) <- ~Lng +  Lat                      #przekształcanie na Spatial df,
proj4string(points_spdf) <- proj4string(nyc_neighborhoods)   #system zmiany systemu współrzędnych?
matches <- over(points_spdf, nyc_neighborhoods)              # "nakładanie" punktów na wielokąty (osiedla), przypisywanie stacji osiedlom
stacje <- cbind (points, matches)                            # przydzielenie stacjom ich osiedli                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
stacje <- stacje[,-8]

# Inaczej:
# coords <- stacje[,c(3,4)]
# data <- stacje[,1,drop = FALSE]
# coordinates(data) = cbind(coords$Lng,coords$Lat)
# proj4string(data) <- proj4string(nyc_neighborhoods)
# matches2 <- over(data, nyc_neighborhoods)


ilosc_w_neighborhood <- stacje %>%
  group_by(neighborhood) %>%
  summarise(Count = n())

start_station <- k22 %>%
  group_by(start_station_id) %>%
  summarise(Count = n())

start_station <- left_join(x = start_station,
                                y = stacje,
                                by = c("start_station_id" = "ID")) %>%
  group_by(neighborhood) %>%
  summarise(Count = sum(Count))

end_station <- k22 %>%
  group_by(end_station_id) %>%
  summarise(Count = n()) %>%
  filter(end_station_id != "")

end_station <- left_join(x = end_station,
                         y = stacje,
                         by = c("end_station_id" = "ID")) %>%
  group_by(neighborhood) %>%
  summarise(Count = sum(Count))

# plot_data <- tidy(nyc_neighborhoods, region="neighborhood") %>%
#   left_join(., ilosc_w_neighborhood, by=c("id"="neighborhood")) %>%
#   filter(!is.na(Count))

# ggplot() + 
#   geom_polygon(data=plot_data, aes(x=long, y=lat, group=group, color = "red", fill = Count), alpha = 0.75)



