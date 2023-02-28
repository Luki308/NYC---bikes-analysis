# NYC---bikes-analysis

Project for Structured Data Processing course at Warsaw University of Technology.

Authors: Łukasz Lepianka, Marta Szuwarska.

Data source: [Citi Bike](https://citibikenyc.com/system-data).

## Łukasz:

I conducted 2 analyses in R:
1. Firstly, I took a look at
how Covid 19 pandemy influenced
travelling by bike. I fetched rides' count and time
from Marches since 2019 to 2022 and presented
them on interactive plots.
![1](https://user-images.githubusercontent.com/76851989/221318659-59a43ba2-c530-4627-b1e7-ec5ccebb3db7.png)


2. The other analysis focused on presenting the
number of the bike uses on interactive NYC map
diveded by neighbourhoods.
I created some maps and two of them showed movement
in morning rush hours. From these I could tell which
ones are more residential neighbourhoods and which
ones are more focused on offices and entertainment facilities.
![3](https://user-images.githubusercontent.com/76851989/221318698-39c5890b-71d5-4d2b-8edb-b05ae5aeefba.png)

Both analyses were transfered to shiny app.

While working with this project I learned mainly how to create a
simple app in shiny, how to create interactive maps in leaflet
and using spatial objects.

## Marta:

1. To start, I engaged in data cleansing, which included deleting empty and invalid rows (e.g. with age set to lower than 5 or average speed over 40 km/h). All analises we did were conducted on the cleansed data.

<p align="center">
<img alt= "CleaningData2019" src="https://user-images.githubusercontent.com/100805060/221985102-f014ce46-b56d-4125-aa77-813c7be07678.png">
</p>

2. Then I got round to an age analysis, in which I compared cyclists' age with distance they covered and their average speed.
<p align="center">
<img src="https://user-images.githubusercontent.com/100805060/221985378-3602909d-4377-454b-93e9-8bcc481531e4.png" alt="AgeAnalysisDistance" width=49%> <img src="https://user-images.githubusercontent.com/100805060/221990840-5ef6a2b5-edc5-4bbb-9f57-962aa87b185a.png" alt="AgeAnalysisSpeed" width=49%>
</p>
  
3. Finally, I made a simple predictive model using logistic regression to predict user type (users with and without year subscription). 

<p align="center">
<img alt= "usertypepredictionaccuracy2019" src="https://user-images.githubusercontent.com/100805060/221986629-d0bb842b-444e-4b38-9d8f-f394ea5a9cfb.png">
</p>

All my work was done in Python. This project allowed me to get the hang of predictive modelling with scikit-learn and improve my data analysis skills.
