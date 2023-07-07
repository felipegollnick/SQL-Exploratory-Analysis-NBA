USE [NBA Gollnick]



-- CREATING TABLES

CREATE TABLE rounds (
rd_id int,
rd_abrev varchar(3),
rd_desc varchar(22)
);

CREATE TABLE teams (
team_id varchar(3),
team_name varchar(22)
);

CREATE TABLE series (
series_id int,
series_round_id int,
series_season int,
series_conference varchar(1),
series_higher_rank varchar(3),
series_lower_rank varchar(3)
);

CREATE TABLE predictions (
pred_id int,
pred_people_id varchar(4),
pred_series_id int,
pred_higher_rank int,
pred_lower_rank int,
pred_right int,
pred_bang int,
pred_conserv int,
pred_right_resc varchar(5),
pred_bang_desc varchar(5),
pred_conserv_desc varchar(5),
pred_gms_margin int,
pred_real_gms_margin int, 
pred_games_qty int
);

CREATE TABLE people (
people_id varchar(4),
people_name varchar(27),
people_debut int
);



-- INSERTING DATA FROM CSV FILES

BULK INSERT rounds
FROM 'C:\Projetos Dados\Bolão Gollnick\SQL\rounds.csv'
WITH (
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
);

BULK INSERT predictions
FROM 'C:\Projetos Dados\Bolão Gollnick\SQL\predictions.csv'
WITH (
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
);

BULK INSERT series
FROM 'C:\Projetos Dados\Bolão Gollnick\SQL\series.csv'
WITH (
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
);

BULK INSERT teams
FROM 'C:\Projetos Dados\Bolão Gollnick\SQL\teams.csv'
WITH (
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
);

BULK INSERT people
FROM 'C:\Projetos Dados\Bolão Gollnick\SQL\people.csv'
WITH (
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
);



-- FINDING OUT ALL THE BETS FROM A SINGLE PARTICIPANT THROUGH ALL THE YEARS:

SELECT
	series_season		AS 'Year',
	rd_desc				AS 'Playoffs Round',
	people_name			AS Participant,
	t1.team_name		AS 'Higher Ranked Team',
	pred_higher_rank	AS 'HR GMs Won',
	pred_lower_rank		AS 'LR GMs Won',
	t2.team_name		AS 'Lower Ranked Team',
	pred_right_desc		AS 'Bet was right?',
	pred_bang_desc		AS 'Bet was a BANGER?'		-- A 'BANGER' meant that a participant correctly guessed the games won qty. by each team in a series
FROM predictions	
LEFT JOIN series		ON pred_series_id = series_id
LEFT JOIN rounds		ON series_round_id = rd_id
LEFT JOIN people		ON pred_people_id = people_id
LEFT JOIN teams			AS t1 ON series_higher_rank = t1.team_id
LEFT JOIN teams			AS t2 ON series_lower_rank = t2.team_id
WHERE pred_people_id = 'GOLL'				-- 'GOLL' was my ID!
;



-- FINDING OUT HOW MANY RIGHT BETS ALL PARTICIPANTS HAD THROUGH THE YEARS

SELECT
	RANK() OVER(ORDER BY SUM(pred_right) DESC)	AS 'Rank',
	pred_people_id								AS Participant,
	SUM(pred_right)								AS TOTAL,
	SUM(CASE WHEN series_season = 2018 THEN pred_right ELSE NULL END) AS '2018',
	SUM(CASE WHEN series_season = 2019 THEN pred_right ELSE NULL END) AS '2019',
	SUM(CASE WHEN series_season = 2020 THEN pred_right ELSE NULL END) AS '2020',
	SUM(CASE WHEN series_season = 2021 THEN pred_right ELSE NULL END) AS '2021',
	SUM(CASE WHEN series_season = 2022 THEN pred_right ELSE NULL END) AS '2022',
	ROUND((SUM(CAST(pred_right AS float)) / COUNT(DISTINCT series_season)), 2) AS 'Right bets per year'
FROM predictions 
LEFT JOIN series ON pred_series_id = series_id
WHERE pred_people_id <> 'REAL'		-- excluding the rows that contains the actual final result from the series
GROUP BY pred_people_id
ORDER BY Rank ASC;


-- FINDING OUT HOW MANY BANGERS ALL PARTICIPANTS HAD THROUGH THE YEARS

SELECT
	RANK() OVER(ORDER BY SUM(pred_bang) DESC)	AS 'Rank',
	pred_people_id								AS Participant,
	SUM(pred_bang)								AS TOTAL,
	SUM(CASE WHEN series_season = 2018 THEN pred_bang ELSE NULL END) AS '2018',
	SUM(CASE WHEN series_season = 2019 THEN pred_bang ELSE NULL END) AS '2019',
	SUM(CASE WHEN series_season = 2020 THEN pred_bang ELSE NULL END) AS '2020',
	SUM(CASE WHEN series_season = 2021 THEN pred_bang ELSE NULL END) AS '2021',
	SUM(CASE WHEN series_season = 2022 THEN pred_bang ELSE NULL END) AS '2022',
	ROUND((SUM(CAST(pred_bang AS float)) / COUNT(DISTINCT series_season)), 2) AS 'BANGERS per year'
FROM predictions 
LEFT JOIN series ON pred_series_id = series_id
WHERE pred_people_id <> 'REAL'		-- excluding the rows that contained the actual final result from the series
GROUP BY pred_people_id
ORDER BY Rank ASC;


-- CALCULATING THE % OF THE BETS THAT WERE CONSERVATIVE (HIGHER-RANKED TEAM WOULD WIN THE SERIES), BY YEAR AND ROUND

SELECT
	rd_id,
	rd_desc																							   AS 'Conservative Bets',
	ROUND(AVG(CAST(CASE WHEN series_season = 2018 THEN pred_conserv ELSE NULL END AS float)) * 100, 2) AS '2018 (%)',
	ROUND(AVG(CAST(CASE WHEN series_season = 2019 THEN pred_conserv ELSE NULL END AS float)) * 100, 2) AS '2019 (%)',
	ROUND(AVG(CAST(CASE WHEN series_season = 2020 THEN pred_conserv ELSE NULL END AS float)) * 100, 2) AS '2020 (%)',
	ROUND(AVG(CAST(CASE WHEN series_season = 2021 THEN pred_conserv ELSE NULL END AS float)) * 100, 2) AS '2021 (%)',
	ROUND(AVG(CAST(CASE WHEN series_season = 2022 THEN pred_conserv ELSE NULL END AS float)) * 100, 2) AS '2022 (%)',
	ROUND(AVG(CAST(pred_conserv AS FLOAT)) * 100, 2)												   AS 'TOTAL (%)'
FROM predictions 
LEFT JOIN series ON pred_series_id = series_id 
LEFT JOIN rounds ON series_round_id = rd_id
WHERE pred_people_id <> 'REAL'		-- excluding the rows that contains the actual final result from the series
GROUP BY rd_desc, rd_id
ORDER BY rd_id;


-- CALCULATING THE % OF CONSERVATIVE BETS THAT WERE RIGHT, BY YEAR AND ROUND

SELECT
	rd_id,
	rd_desc																							 AS 'Conservative Bets',
	ROUND(AVG(CAST(CASE WHEN series_season = 2018 THEN pred_right ELSE NULL END AS float)) * 100, 2) AS '2018 (%)',
	ROUND(AVG(CAST(CASE WHEN series_season = 2019 THEN pred_right ELSE NULL END AS float)) * 100, 2) AS '2019 (%)',
	ROUND(AVG(CAST(CASE WHEN series_season = 2020 THEN pred_right ELSE NULL END AS float)) * 100, 2) AS '2020 (%)',
	ROUND(AVG(CAST(CASE WHEN series_season = 2021 THEN pred_right ELSE NULL END AS float)) * 100, 2) AS '2021 (%)',
	ROUND(AVG(CAST(CASE WHEN series_season = 2022 THEN pred_right ELSE NULL END AS float)) * 100, 2) AS '2022 (%)',
	ROUND(AVG(CAST(pred_right AS FLOAT)) * 100, 2)													 AS 'TOTAL (%)'
FROM predictions 
LEFT JOIN series ON pred_series_id = series_id 
LEFT JOIN rounds ON series_round_id = rd_id
WHERE pred_conserv_desc = 'TRUE'	-- filtering only the bets that were conservative
	AND pred_people_id <> 'REAL'	-- excluding the rows that contains the actual final result from the series
GROUP BY rd_desc, rd_id
ORDER BY rd_id;


-- NOW LET'S PLAY WITH CTEs! LET'S DISCOVER THE SERIES WHERE PARTIPANTS THOUGHT ONE TEAM WOULD REALLY BLAST THE OTHER:

-- First, let's get the average bet on games won quantity by higher and lower ranked teams in each series:

WITH avg_bets AS (
	SELECT 
		pred_series_id									AS series_id,
		ROUND(AVG(CAST(pred_higher_rank AS float)), 2)	AS avg_hr_gms_won,
		ROUND(AVG(CAST(pred_lower_rank AS float)), 2)	AS avg_lr_gms_won,
		COUNT(DISTINCT pred_people_id)					AS bets_qty
	FROM predictions
	WHERE pred_people_id <> 'REAL'	-- excluding the rows that contains the actual final result from the series
	GROUP BY pred_series_id
	),

-- Then, let's get the real score by each team in each series:

real_score AS (
	SELECT
		pred_series_id		AS series_id,
		pred_higher_rank	AS real_hr_gms_won,
		pred_lower_rank		AS real_lr_gms_won
	FROM predictions
	WHERE pred_people_id = 'REAL'	-- bringing just the real result from the series
	)

-- Now let's join everything together, calculate the margin between the two average columns, rank the output by this margin and leave the real scores for comparison:

SELECT
	RANK() OVER(ORDER BY ABS(avg_hr_gms_won - avg_lr_gms_won) DESC) AS 'Rank',
	t1.team_name								AS 'Higher Ranked Team',
	t2.team_name								AS 'Lower Ranked Team',
	avg_hr_gms_won								AS 'HR AVG Bet',
	avg_lr_gms_won								AS 'LR AVG Bet',
	ROUND(avg_hr_gms_won - avg_lr_gms_won, 2)	AS 'Margin',
	bets_qty									AS 'Bets Qty',
	real_hr_gms_won								AS 'HR Real Score',
	real_lr_gms_won								AS 'LR Real Score',
	rd_desc										As 'Round',
	series_season								AS 'Year'
FROM series
LEFT JOIN avg_bets		ON series.series_id = avg_bets.series_id
LEFT JOIN real_score	ON series.series_id = real_score.series_id
LEFT JOIN rounds		ON series_round_id = rd_id
LEFT JOIN teams			AS t1 ON series_higher_rank = t1.team_id
LEFT JOIN teams			AS t2 ON series_lower_rank = t2.team_id
ORDER BY 'Rank'