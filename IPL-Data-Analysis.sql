--First of all, We will create database to store tables:
 CREATE DATABASE ipl_data_analysis;
 
 --Now will open the query tool of the database 'ipl_data_analysis' to create tables
 
--Secondly, We will create tables to store data, we wil be creating two tables:

--1. matches
CREATE TABLE matches
(
    match_id int8 PRIMARY KEY,
    city varchar(50),
    date date,
    season varchar(50),
    match_number varchar(50),
    team1 varchar(50),
    team2 varchar(50),
    venue varchar(100),
    toss_winner varchar(50),
    toss_decision varchar(50),
    superover varchar(50),
    winning_team varchar(50),
    won_by varchar(50),
    margin int4,
    method varchar(50),
    player_of_match varchar(50),
    umpire1 varchar(50),
    umpire2 varchar(50)
);


					  
--2. deliveries
CREATE TABLE deliveries
(
    match_id int8 NOT NULL,
	innings int8,
	overs int8,
	ball_number int8,
	batter varchar(50),
	bowler varchar(50),
	non_striker varchar(50),
	extra_type varchar(50),
	batsman_run int8,
	extras_run int8,
	total_run int8,
	non_boundry int8,
	iswicket_delivery int8,
	player_out varchar(50),
	dismisal_kind varchar(50),
	fielders_involved varchar(50),
	batting_team varchar(50)
)
;

							 
--Now let's import data into the tables from csv files

-- FOR 'matches' table 
 COPY matches(id,city,match_date,season,match_number,team1,team2,venue,toss_winner,
			  toss_decision,superover,winning_team,won_by,margin,method,player_of_match,umpire1,umpire2)
 FROM 'C:\Downloads\matches.csv'
 DELIMITER ','
 CSV HEADER ;
 
-- FOR 'deliveries' table 
 COPY deliveries(match_id,innings,overs ,ball_number ,batter ,bowler ,non_striker ,extra_type ,batsman_run ,extras_run ,
			  total_run ,non_boundry ,iswicket_delivery ,player_out,dismisal_kind,fielders_involved,batting_team)
 FROM 'C:\Downloads\deliveries.csv'
 DELIMITER ','
 CSV HEADER ;
 
--Now let's start analysing our data

#Shape of Data
----------------
-- Shapes are combination of rows and columns
-- To know about our tables' structure (i.e rows and columns), let's write queries:

--FOR 'matches' Table
select count(*)
as No_of_row 
from matches;

select count(*) as No_of_columns
from information_schema.columns
where TABLE_NAME='matches';

--FOR 'deliveries' Table
select count(*)
as No_of_row 
from deliveries;

select count(*) as No_of_columns
from information_schema.columns
where TABLE_NAME='deliveries';


#Viewing Data
--------------
Select *
From matches;

Select *
From deliveries;


# View selected columns
-------------------------

select m.season,m.city,m.date,m.team1,m.team2,m.winning_team,m.won_by,m.margin
from matches m
where m.season='2017'
limit 5;


# Distinct values
-------------------
select distinct EXTRACT(YEAR From m.date) as Year_of_Match
from matches m
order by 1;

select count(distinct player_of_match) as No_of_Matches
from matches m
order by 1;


# Find season winner for each season (season winner is the winner of the last match of each season)
------------------------------------
Select winning_team
From matches
where match_number='Final'
Order by season


Select winning_team
From matches
Where date IN (Select max(date)
			  From matches
			  Group by season)
Order by season


# Find venue of 10 most recently played matches
------------------------------------------------
Select venue,date
From matches
Order by date desc
LIMIT 10


# Case (4,6, single,0)
-------------------------
select DISTINCT batter,bowler,ball_number,
CASE
when batsman_run=4 then 'Four'
when batsman_run=6 then 'Six'
 else 'Non-Bounadry Ball'
end as Run_in_words from deliveries ;


# Data Aggregation
--------------------

select winning_team,max(margin)
from matches
where won_by='Runs'
group by winning_team
order by 2 desc;
	
# How many extra runs have been conceded by each bowler in ipl
----------------------------------------------------------------

select bowler,SUM(extras_run)
From deliveries
Group By bowler
having SUM(extras_run)>0
Order By 2 desc;

# On an average, teams won by how many runs in ipl (Show for individual team)
-------------------------------------------------------------------------------

Select winning_team,AVG(margin)
From matches
Where won_by='Runs'
Group By winning_team
Having AVG(margin)>0
Order By 2 desc;

# How many extra runs were conceded in ipl by SK Warne
-------------------------------------------------------

Select bowler,SUM(extras_run)
From deliveries
Where bowler='SK Warne'
Group BY bowler;

# How many boundaries (4s or 6s) have been hit in ipl by each team
--------------------------------------------------------------------
select m.winning_team, d.batsman_run,COUNT(d.total_run) 
From deliveries as d
Inner Join matches as m
ON d.match_id=m.match_id
Where batsman_run in (4,6) 
Group BY m.winning_team, d.batsman_run;


/*Cricket trading has become increasingly popular in recent years.
With the evolving cricket landscape, there are new opportunities and 
it can be a great way to connect with other cricket enthusiasts and potentially make some profit.
Here you have to buy or sell shares of a team and the result will be decided by the winning team.
There are different markets too where you can Invest on YES or NO for a particular over's runs or 
team runs or a specific batsman's runs. There are plenty of markets to explore.*/

/*This project can help us predicting the outcome of a event by analyzing the past data. For a particular over
we can get the past record of the bowler and batsmans who will be playing in that over. Its not like every time
our prediction from past data will come true. But we dont need to 100% accuracy rate to be in profit. Even if we
are getting results with 51% accuracy rate, it will do the job.*/


# Batsman's stats agains a Bowler
------------------------------------------
select *
From deliveries
where batter='Yuvraj Singh' and bowler='Harbhajan Singh';


# Batsman's stats agains a team
------------------------------------------
select *
from deliveries
where batter='Yuvraj Singh' and bowling_team='Mumbai Indians';


# Bowler's stats agains a Team
------------------------------------------
select *
from deliveries
where bowler='Harbhajan Singh' and batting_team='Delhi Daredevils';


# Bowler's stats agains Batsmans
------------------------------------------
select *
from deliveries
where bowler='Harbhajan Singh' and batter IN ('Yuvraj Singh','S Dhawan')



# How many balls did 'Harbhajan' bowl to batsman 'V Kohli' and how many runs scored by 'Virat Kohli'
------------------------------------------------------------------------------------------------------
Select batter,bowler,count(*) as balls_faced ,SUM(batsman_run) as runs_scored
from deliveries
JOIN matches
ON deliveries.match_id=matches.match_id
Where batter='V Kohli' and Bowler='Harbhajan Singh'
Group By batter,bowler;
.

# How many matches were played in the month of April
------------------------------------------------------
Select count(*)
From matches 
where EXTRACT(MONTH FROM date)=4;


# How many matches were played in the March and June
------------------------------------------------------
Select count(*)
From matches
where EXTRACT(MONTH FROM date) IN (3,6);


# Total number of wickets taken in ipl also specify number of wickets according to dismisial kind
--------------------------------------------------------------------------------------------------
Select dismisal_kind,Count(*),SUM(Count(*)) OVER() as Total_Wickets
From deliveries
Where iswicket_delivery=1
Group By dismisal_kind
Order BY 2 desc;


# Pattern Match ( Like operators % _ )
----------------------------------------
select Distinct player_of_match
From matches 
where player_of_match Like '%M%';

select Distinct player_of_match 
From matches 
where player_of_match 
like 'JJ %';

select distinct player_of_match 
From matches 
where player_of_match 
like 'K__P%';
	
# Group by - Maximum runs by which any team won a match per season
--------------------------------------------------------------------
Select winning_team,margin
From matches
Where won_by='Runs'
Order By margin desc
LIMIT 1;


# Top 10 batters of IPL History
---------------------------------
Select batter,sum(batsman_run)
From deliveries
Group by batter
Order by 2 desc
LIMIT 10;


# Top 10 players with max boundaries (4 or 6)
-----------------------------------------------
Select batter,Count(*)
From deliveries
Where batsman_run IN (4,6)
Group By batter
Order By Count(*) desc
LIMIT 10;


# Top 20 bowlers who conceded highest extra runs
--------------------------------------------------
Select bowler,Sum(extras_run)
From deliveries
Group by bowler
Order By 2 desc
LIMIT 20;


# Top 10 wicket takers of IPL History
---------------------------------------
Select bowler,Count(*)
From deliveries
Where iswicket_delivery=1
Group by bowler
Order by 2 desc
LIMIT 10;


# Name and number of wickets by bowlers who have taken more than or equal to 100 wickets in ipl
------------------------------------------------------------------------------------------------
Select bowler,Count(*)
From deliveries
Where iswicket_delivery=1
Group by bowler
Having Count(*)>=100
Order by 2 desc;

Select * From matches
Select * From deliveries

WITH CTE AS(
Select M.Season,D.batter,SUM(D.batsman_run) AS Runs
From Deliveries AS D
INNER JOIN Matches AS M
ON D.match_id=M.match_id
Group By season,batter
Order By Runs Desc
LIMIT 75
)
Select Season,Count(Runs)
From CTE
Where Runs>=500
Group By Season
Order By Count Desc
















































			  








 

















