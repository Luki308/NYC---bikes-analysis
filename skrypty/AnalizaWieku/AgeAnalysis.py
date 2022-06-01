# 1.06.2022
# Praca domowa nr 3 z Przetwarzania Danych Ustrukturyzowanych
# Łukasz Lepianka, Marta Szuwarska
# Analiza zależności między wiekiem a średnią predkością i przejechanym dystansem.

# Załączamy potrzebne biblioteki:
import pandas as pd
from math import radians
from sklearn.metrics.pairwise import haversine_distances
import matplotlib.pyplot as plt
import numpy as np
plt.rcParams['agg.path.chunksize'] = 10000

def main():
    # Wczytanie danych
    df = pd.concat(
                    [pd.read_csv("../../cleandata/2019/2019" + str(i).zfill(2) + "-citibike-tripdata.csv") for i in range(1,7)])


    # Liczymy dystans w km:
    df = df.assign(distance=df.apply(lambda row: haversine_distances(
        [[radians(row['start station latitude']), radians(row['start station longitude'])],
         [radians(row['end station latitude']), radians(row['end station longitude'])]])[0, 1] * 6371,
                                     axis=1))

    # Liczymy średnią prędkość w km/h:
    df = df.assign(speed=df['distance'] / (df['tripduration'] / 3600))

    # Liczymy wiek:
    df = df.assign(age=2019 - df['birth year'])

    # Dla każdego wieku liczymy średni dystans:
    X = range(min(df['age']),max(df['age'])+1)
    Y = [0]*len(X)
    Z = [0]*len(X)
    for i in range(len(X)):
        Y[i]=np.mean(df[df['age']==X[i]]['distance'])
        Z[i]=np.mean(df[df['age']==X[i]]['speed'])


    ax = plt.gca()
    ax.plot(X,Y)
    ax.set_title("Porównanie wieku rowerzystów ze średnim przejechanym dystansem")
    ax.set_xlabel("Wiek")
    ax.set_ylabel("Średnia odległość [km]")
    fig = ax.get_figure()
    fig.savefig('AgeAnalysisDistance.png')
    plt.close()

    ax = plt.gca()
    ax.plot(X, Z)
    ax.set_title("Porównanie wieku rowerzystów ze średnią prędkością")
    ax.set_xlabel("Wiek")
    ax.set_ylabel("Średnia prędkość [km/h]")
    fig = ax.get_figure()
    fig.savefig('AgeAnalysisSpeed.png')


if __name__ == "__main__":
    main()