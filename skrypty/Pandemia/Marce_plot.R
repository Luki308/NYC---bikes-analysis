# W tym skrypcie znajduje się kod tworzący histogram ilości podrózy w kolejnych
# marcach lat 2019-2022

library(dplyr)
library(ggplot2)

load("shiny/Dane_wyliczone2.RData")

df <- NULL
df_temp <- wynik18m %>%
  summarise(Sum = sum(Count), Avg = mean(Avg)) %>% mutate(Month = "Marzec 18'")
df <- rbind(df,df_temp)
df_temp <- wynik19m %>%
  summarise(Sum = sum(Count), Avg = mean(Avg)) %>% mutate(Month = "Marzec 19'")
df <- rbind(df,df_temp)
df_temp <- wynik20m %>%
  summarise(Sum = sum(Count), Avg = mean(Avg)) %>% mutate(Month = "Marzec 20'")
df <- rbind(df,df_temp)
df_temp <- wynik21m %>%
  summarise(Sum = sum(Count), Avg = mean(Avg)) %>% mutate(Month = "Marzec 21'")
df <- rbind(df,df_temp)
df_temp <- wynik22m %>%
  summarise(Sum = sum(Count), Avg = mean(Avg)) %>% mutate(Month = "Marzec 22'")
df <- rbind(df,df_temp)

df <- df %>% mutate(liczba_przejazdow = Sum/1000) %>% select(c(Month,liczba_przejazdow, Avg)) 


# df %>%
#   ggplot(aes(x = Month, y = liczba_przejazdow, group = 1))+
#   geom_point(colour = "green", size = 5)+
#   geom_line(colour = "red")+
#   labs(y = "Liczba przejazdow[tys]", x = "Rok", title = "Liczba przejazdow w kolejnych latach")+
#   ylim(0,2000)
  
df %>%
  ggplot(aes(x = Month, y = liczba_przejazdow), group=1)+
  geom_bar(stat='identity', colour = "black", fill = "springgreen3")+
  labs(y = "Liczba przejazdow[tys]", x = "Rok", title = "Liczba przejazdow w kolejnych latach")+
  ylim(0,2000) -> lata_count_plot

df %>%
  ggplot(aes(x = Month, y = Avg), group=1)+
  geom_bar(stat='identity', colour = "black", fill = "springgreen3")+
  labs(y = "Sredni czas trwania[min]", x = "Rok", title = "Średni czas trwania przejazdow w kolejnych latach") -> lata_avg_plot

rm(list =ls(pattern = "wynik"))
rm(list =ls(pattern = "df"))

save.image(file = "shiny/Marce_histogram.RData")