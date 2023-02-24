# 30.05.2022
# Praca domowa nr 3 z Przetwarzania Danych Ustrukturyzowanych
# Łukasz Lepianka, Marta Szuwarska
# Przewidywanie typu użytkownika roweru (Subsciber lub Customer) na podstawie pozostałych dostępnych danych
# przy użyciu regresji logistycznej

# Załączamy potrzebne biblioteki:
import pandas as pd
from sklearn.linear_model import LogisticRegression
import random as rand
import numpy as np
from sklearn.metrics import f1_score
import seaborn as sns
from sklearn.preprocessing import MinMaxScaler

def main():

    # Wczytujemy dane z 2019:
    df = pd.concat([pd.read_csv("data/2019/2019"+str(i).zfill(2)+"-citibike-tripdata.csv") for i in range(1,7)])

    # Pozbywamy się wierszy z NA
    df = df.dropna()

    # Konwertujemy kolumny z datami na liczby całkowite:
    df["starttime"] = pd.to_datetime(df["starttime"], format="%Y-%m-%d %H:%M:%S.%f").astype(int)
    df["stoptime"] = pd.to_datetime(df["stoptime"], format="%Y-%m-%d %H:%M:%S.%f").astype(int)

    # Pozbywamy się kolumn z nazwami stacji (regresja logistyczna nie obsłuży stringów)
    df = df.drop(columns=["start station name","end station name"])

    # Przyporządkowujemy wartościom w kolumnie usertype 1 dla "Subscriber" i 0 dla pozostałych ("Customer")
    df["usertype"] = np.where(df["usertype"]=="Subscriber",1,0)

    # Losujemy k wierszy z typem użytkownika "Subscriber" i k z typem "Customer"
    rand.seed(2022)
    k = 10000
    random_rows_subscriber = df[df["usertype"]==1].sample(k)
    random_rows_customer = df[df["usertype"]==0].sample(k)

    # Zapisujemy je jako dane testowe
    X_test = pd.concat([random_rows_subscriber,random_rows_customer])

    # Pozostałe wiersze będą danymi treningowymi
    X_train = df.drop(X_test.index)

    # Kolumnę z usertype przerzucamy do Y
    Y_test = X_test["usertype"]
    X_test = X_test.drop(columns="usertype")
    Y_train = X_train["usertype"]
    X_train = X_train.drop(columns=["usertype"])

    # Skalujemy dane
    scaler = MinMaxScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)

    # Wypróbujemy pięć różnych wbudowanych algorytmów optymalizacyjnych
    solver_list = ['liblinear', 'newton-cg', 'lbfgs', 'sag', 'saga']
    scores = []
    for solver in solver_list:
        model = LogisticRegression(solver=solver,max_iter=10000).fit(X_train, Y_train)
        prediction = model.predict(X_test)
        scores.append(f1_score(Y_test, prediction))

    # Wyniki skuteczności przewidywania usertype
    print(scores)
    ax = sns.barplot(x=solver_list, y=scores)
    ax.set_title("Skuteczność przewidywania usertype dla danych z roku 2019")
    ax.set_xlabel("Algorytm")
    ax.set_ylabel("Skuteczność działania")
    ax.set(ylim=(min(scores)-0.0001,max(scores)+0.0001))
    fig = ax.get_figure()
    fig.savefig('usertypepredictionaccuracy.png')


if __name__ == "__main__":
    main()