# 31.05.2022
# Praca domowa nr 3 z Przetwarzania Danych Ustrukturyzowanych
# Łukasz Lepianka, Marta Szuwarska
# Czyszczenie danych z marców
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import haversine_distances
from math import radians

pd.options.mode.chained_assignment = None

def main():

    # Wczytanie danych
    data = []
    for i in range(1,13):

        data.append(pd.read_csv("../../data/2019/2019" + str(i).zfill(2) + "-citibike-tripdata.csv", low_memory=False))

    barHeights = [[0]*len(data) for _ in range(2)]

    # Czyszczenie
    for i in range(len(data)):
        df = data[i]
        barHeights[0][i] = len(df)
        print(f"Przed czyszczeniem: {len(df)}")
        # Czyszczenie NA:
        df = df.dropna()
        # Czyszczenie nieprawidłowego wieku:
        if 'birth year' in df:
            df = df.query('5 < 2019 - `birth year` < 80')
        # Czyszczenie nieprawidłowego czasu podróży:
        if 'tripduration' not in df:
            df = df.assign(tripduration=(pd.to_datetime(df["ended_at"], format="%Y-%m-%d %H:%M:%S.%f")
                                         - pd.to_datetime(df["started_at"], format="%Y-%m-%d %H:%M:%S.%f")).dt.seconds)
        df = df.query('tripduration < 12*60*60')
        # Czyszczenie nieprawidłowej prędkości:
        if 'start station latitude' in df:
            df = df.assign(distance=df.apply(lambda row: haversine_distances(
                [[radians(row['start station latitude']), radians(row['start station longitude'])],
                 [radians(row['end station latitude']), radians(row['end station longitude'])]])[0, 1] * 6371,
                                             axis=1))
        else:
            df = df.assign(distance=df.apply(lambda row: haversine_distances(
                [[radians(row['start_lat']), radians(row['start_lng'])],
                 [radians(row['end_lat']), radians(row['end_lng'])]])[0, 1] * 6371,
                                             axis=1))
        df = df.assign(speed=df['distance'] / (df['tripduration'] / 3600))
        df = df.query('5 < speed < 40')
        df = df.drop(columns=["distance","speed"])
        print(f"Po czyszczeniu: {len(df)}")
        barHeights[1][i] = len(df)
        df.to_csv("../../cleandata/2019/2019" + str(i+1).zfill(2) + "-citibike-tripdata.csv")

    # Robimy wykres kolumnowy:
    barWidth = 0.25
    fig = plt.subplots(figsize=(12,5))
    br1 = np.arange(len(barHeights[0]))
    br2 = [i+barWidth for i in br1]
    plt.bar(br1,barHeights[0],color='r',width=barWidth,edgecolor='grey',label='Przed czyszczeniem',log = True)
    plt.bar(br2,barHeights[1],color='g',width=barWidth,edgecolor='grey',label='Po czyszczeniu',log = True)
    plt.title("Liczba przejazdów przed i po czyszczeniu danych dla roku 2019")
    plt.xlabel('Miesiąc')
    plt.ylabel('Liczba przejazdów')
    plt.xticks([x + barWidth for x in range(len(barHeights[0]))],["styczeń","luty","marzec","kwiecień","maj","czerwiec","lipiec","sierpień","wrzesień","październik","listopad","grudzień"])
    plt.legend(fancybox=True)
    plt.yscale('log')
    plt.savefig('CleaningData2019.png')


if __name__ == "__main__":
    main()

