# 31.05.2022
# Praca domowa nr 3 z Przetwarzania Danych Ustrukturyzowanych
# Łukasz Lepianka, Marta Szuwarska
# Czyszczenie danych z marców

import pandas as pd
from sklearn.metrics.pairwise import haversine_distances
from math import radians

pd.options.mode.chained_assignment = None

def main():

    # Wczytanie danych
    data = []
    for i in range(18, 23):
        data.append(pd.read_csv("../../data/marce/20" + str(i) + "03-citibike-tripdata.csv", low_memory=False))

    # Czyszczenie
    for i in range(len(data)):
        df = data[i]
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
        df.to_csv("../../cleandata/marce/20" + str(18+i) + "03-citibike-tripdata.csv")


if __name__ == "__main__":
    main()

