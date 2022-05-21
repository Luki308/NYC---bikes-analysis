# Skrypt w którym dla danych stacji generujemy dane lokalizacyjne
# na podstawie szerokości i wysokości geograficznej
library(dplyr)
library(tidygeocoder)

k22 <- read.csv("data/lokalizacja/202204-citibike-tripdata.csv")
k22 <- as.data.frame(k22)

k22 %>%
  select(ID = start_station_id, Name = start_station_name, Lat = start_lat, Lng = start_lng) %>%
  distinct(ID,Name,Lat,Lng) -> stacje


 stacje_district <- stacje %>%
   reverse_geocode(lat = Lat, long = Lng, method = 'arcgis',
                   address = address_found, full_results = TRUE)
 stacje_nbh <- stacje %>%
   reverse_geocode(lat = Lat, long = Lng, method = 'osm',
                   address = address_found, full_results = TRUE)
 
 stacje_district_clean <- stacje_district %>%
                            mutate(City = ifelse(City == "New York", "Manhattan", City))
 
 stacje_nbh_clean <- stacje_nbh %>%
                      filter(is.na(neighbourhood) == FALSE)
 
 
?reverse_geocode

 