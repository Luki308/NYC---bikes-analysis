library(dplyr)

m18 <- read.csv("cleandata/marce/201803-citibike-tripdata.csv")
m19 <- read.csv("cleandata/marce/201903-citibike-tripdata.csv")
k19 <- read.csv("data/marce/201904-citibike-tripdata.csv")
m20 <- read.csv("cleandata/marce/202003-citibike-tripdata.csv")
k20 <- read.csv("data/marce/202004-citibike-tripdata.csv")
m21 <- read.csv("cleandata/marce/202103-citibike-tripdata.csv")
m22 <- read.csv("cleandata/marce/202203-citibike-tripdata.csv")

m18 <- as.data.frame(m18)
m19 <- as.data.frame(m19)
k19 <- as.data.frame(k19)
m20 <- as.data.frame(m20)
k20 <- as.data.frame(k20)
m21 <- as.data.frame(m21)
m22 <- as.data.frame(m22)

m18 %>%
  select(starttime,tripduration) %>%
  mutate(starttime = substr(starttime,9,10)) %>%
  group_by(starttime) %>%
  summarise(Count = n(), Avg = mean(tripduration/60)) -> wynik18m

m19 %>%
  select(starttime,tripduration) %>%
  mutate(starttime = substr(starttime,9,10)) %>%
  group_by(starttime) %>%
  summarise(Count = n(), Avg = mean(tripduration/60)) -> wynik19m

k19 %>%
  select(starttime,tripduration) %>%
  mutate(starttime = substr(starttime,9,10)) %>%
  group_by(starttime) %>%
  summarise(Count = n(), Avg = mean(tripduration/60)) -> wynik19k

m20 %>%
  select(starttime,tripduration) %>%
  mutate(starttime = substr(starttime,9,10)) %>%
  group_by(starttime) %>%
  summarise(Count = n(), Avg = mean(tripduration/60)) -> wynik20m

k20 %>%
  select(starttime,tripduration) %>%
  mutate(starttime = substr(starttime,9,10)) %>%
  group_by(starttime) %>%
  summarise(Count = n(), Avg = mean(tripduration/60)) -> wynik20k

m21 %>%
  select(started_at, ended_at) %>%
  mutate(tripduration = difftime(ended_at, started_at, units = "mins")) %>%
  mutate(started_at = substr(started_at,9,10)) %>%
  group_by(started_at) %>%
  summarise(Count = n(), Avg = mean(tripduration)) -> wynik21m

m22 %>%
  select(started_at, ended_at) %>%
  mutate(tripduration = difftime(ended_at, started_at, units = "mins")) %>%
  mutate(started_at = substr(started_at,9,10)) %>%
  group_by(started_at) %>%
  summarise(Count = n(), Avg = mean(tripduration)) -> wynik22m

rm(m18)
rm(m19)
rm(k19)
rm(m20)
rm(k20)
rm(m21)
rm(m22)

save.image(file = "shiny/Dane_wyliczone2.RData")



