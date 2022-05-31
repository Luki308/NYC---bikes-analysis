# 18.05.2022
# Praca domowa nr 3
# Łukasz Lepianka i Marta Szuwarska

library(data.table)
library(ggplot2)

m19 <-
  as.data.table(read.csv("data/marce/201903-citibike-tripdata.csv"))
m20 <-
  as.data.table(read.csv("data/marce/202003-citibike-tripdata.csv"))
m22 <-
  as.data.table(read.csv("data/marce/202203-citibike-tripdata.csv"))

# Policzymy liczbę przejazdów na dzień oraz średni czas ich trwania dla marca 2019, 2020 i 2022

wynik19 <-
  m19[, .(Day = substr(starttime, 9, 10), tripduration)][, .(RidesCount =
                                                               .N,
                                                             AvgTimeDuration = mean(tripduration / 60)), by = Day]
wynik20 <-
  m20[, .(Day = substr(starttime, 9, 10), tripduration)][, .(RidesCount =
                                                               .N,
                                                             AvgTimeDuration = mean(tripduration / 60)), by = Day]
wynik22 <-
  setorder(m22[, .(Day = substr(started_at, 9, 10),
                   tripduration = as.double(difftime(ended_at, started_at, units = "secs")))][, .(RidesCount =
                                                                                                    .N,
                                                                                                  AvgTimeDuration = mean(tripduration / 60)), by = Day], Day)
ggplot(wynik19, aes(x = Day, y = RidesCount)) + geom_point(color = "red") +
  geom_point(data = wynik20, aes(x = Day, y = RidesCount), color = "blue") +
  geom_point(data = wynik22, aes(x = Day, y = RidesCount), color = "green")

ggplot(wynik19, aes(x = Day, y = AvgTimeDuration)) + geom_point(color = "red") +
  geom_point(data = wynik20, aes(x = Day, y = AvgTimeDuration), color = "blue") +
  geom_point(data = wynik22, aes(x = Day, y = AvgTimeDuration), color = "green")

####
m19[,.(Count = .N),by=usertype][,.(Count=Count/sum(Count))]
m19[,.(Count = .N),by=gender][,.(Count=Count/sum(Count))]
m19[,.(Count = .N),by=birth.year]
