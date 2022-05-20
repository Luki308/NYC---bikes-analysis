library(dplyr)

m19 <- read.csv("data/marce/201903-citibike-tripdata.csv")
m20 <- read.csv("data/marce/202003-citibike-tripdata.csv")
m22 <- read.csv("data/marce/202203-citibike-tripdata.csv")

m19 <- as.data.frame(m19)
m20 <- as.data.frame(m20)
m22 <- as.data.frame(m22)

?difftime

m20 %>%
  select(starttime,tripduration) %>%
  mutate(starttime = substr(starttime,1,10)) %>%
  group_by(starttime) %>%
  summarise(Count = n(), Avg = mean(tripduration/60)) -> wynik20

m19 %>%
  select(starttime,tripduration) %>%
  mutate(starttime = substr(starttime,1,10)) %>%
  group_by(starttime) %>%
  summarise(Count = n(), Avg = mean(tripduration/60)) -> wynik19

m22 %>%
  select(started_at, ended_at) %>%
  mutate(tripduration = difftime(ended_at, started_at)) %>%
  mutate(started_at = substr(started_at,1,10)) %>%
  group_by(started_at) %>%
  summarise(Count = n(), Avg = mean(tripduration)) -> wynik22
