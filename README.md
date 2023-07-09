# SQL-Exploratory-Analysis-NBA
_Using SQL to analyze my friends' NBA Playoffs bets_

![Marius Christensen - Unsplash](https://i.ibb.co/Th27JKX/Marius-Christensen-Unsplash.jpg)
_Picture by [Marius Christensen on Splash](https://unsplash.com/photos/_Ghzg0xvHW0)_

**Gollnick's NBA Playoffs Predictions Game** was a betting game that I runned from 2018 to 2022 just for the sake of having a little bit of fun with my friends during the NBA playoffs. Betting was actually free and there was no prize money.

Usually, when each round of the NBA Playoffs began, I would send Google Forms to my friends where they could insert their predictions to each playoff series (say Toronto Raptors 4-2 Golden State Warriors). 
Those predictions were then compiled in spreadsheets that I used for this analysis.

In this study, I used SQL queries to make exploratory analyses about each partipant betting history, as well as the participants habits to make conservative bets (that means predicting that the higher-ranked team would win a series).

Data was split into five tables:
- _rounds_
- _teams_
- _people_
- _series_
- _predictions_

The last one could be considered as a fact table since it contains data from all the bets made by all participants through all the five years of Predictions Game.

I was able to do all the analyses with the following SQL functions:
- LEFT JOIN
- SUM
- RANK
- CASE
- ROUND
- CAST
- COUNT
- AVG
- _Common Table Expressions (CTEs)_

### [Click here to check the PDF file with all the queries and their output tables.](https://github.com/felipegollnick/SQL-Exploratory-Analysis-NBA/blob/main/Gollnick's%20NBA%20Playoffs%20Game%20-%20SQL.pdf)

This study was made with **SQL Server Management Studio**. A previous version of this study was made with MySQL - [click here to check it out](https://datagollnick.medium.com/using-sql-to-analyze-5-years-of-my-own-nba-predictions-game-2bc0cb29fa9c).
