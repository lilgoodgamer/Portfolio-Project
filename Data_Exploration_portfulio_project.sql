/*
my schools eoc 2024 data exploration

skills im going to use 
joins, CTE's, Temp Tables, Windows Functiions, Aggregate Function, Creating Biews, Conversting Data Types
*/
-- select the data we will be starting with

select MOSIS_ID, Grade,Points_Earned, Points_Possible, Percent_Correct
from [spring 2024 eoc]
where Scale_Score is not null
order by  Course, Grade, MOSIS_ID;



-- grade vs people passing
-- Shows likelihood of failing when you take the test based of grade

select Grade,
COUNT(CASE WHEN Percent_Correct <= 59.5 THEN Percent_Correct END) AS "failing", -- how many failed
COUNT(CASE WHEN Percent_Correct > 59.5 THEN Percent_Correct END) AS "passing", -- how many passed

CAST(
    COUNT(CASE WHEN Percent_Correct <= 59.5 THEN 1 END) * 100.0 / 
    COUNT(*) AS DECIMAL(5,2)
  ) AS "% failed"   -- what % of them failed 


from [spring 2024 eoc]
group by Grade

-- Total Cases vs Population
-- Shows what percentage of population passed the test

select
cast(
count(case when Percent_Correct > 59.5 then 1 end)* 100.0 
/ count(*) as decimal (5,2)
) as "total % that passed"
from [spring 2024 eoc]
group by School_Code

-- highest fail rate compared to student body 
select Grade, count(MOSIS_ID) as 'student body',
COUNT(CASE WHEN Percent_Correct <= 59.5 THEN Percent_Correct END) AS "failing",
cast(
     COUNT(CASE WHEN Percent_Correct <= 59.5 THEN 1 END) * 100 / count(MOSIS_ID) as decimal (5,2)
) as 'Precent of population failed'
from[spring 2024 eoc]
where Grade = 11
group by Grade

--grade with the highest fail rate per populaton 
select Grade, count(MOSIS_ID) as 'student body',
COUNT(CASE WHEN Percent_Correct <= 59.5 THEN Percent_Correct END) AS "failing",
cast(
     COUNT(CASE WHEN Percent_Correct <= 59.5 THEN 1 END) * 100 / count(MOSIS_ID) as decimal (5,2)
) as 'Precent of grade failed'
from[spring 2024 eoc]
group by Grade
order by [Precent of grade failed] desc

-- BSEAKING THINGS DOWN BY GRADE    

-- GLOBAL NUMBERS
-- precent of every qustion being right 

select sum(Points_Possible) as 'amount_of_points_possible',
sum(Points_Earned) as 'amount_correct' 
, cast(sum(Points_possible) - sum(points_earned) as float) / sum(Points_Possible) * 100 as 'point loss %'

from [spring 2024 eoc]

--perfomanve level vs passing (59.9%)
--% of population that perfomed Proficient joins

select COUNT(person_data.MOSIS_ID) AS 'student body',
COUNT(CASE WHEN test_data.Performance_Level <> 'Proficient' THEN 1 END) AS 'student body not Proficient',
COUNT(CASE WHEN test_data.Performance_Level = 'Proficient' THEN 1 END) AS 'student body Proficient',
cast(
     COUNT(CASE WHEN test_data.Performance_Level = 'Proficient' THEN 1 END) * 100 /
     COUNT(person_data.MOSIS_ID)
 as decimal(5,2)) as '% of population Proficient'
from [spring 2024 eoc] as person_data, [spring 2024 eoc per] as test_data
where person_data.MOSIS_ID = test_data.MOSIS_ID and person_data.sessions = test_data.Sessions;

--CTE to perfomr Caculation on Partition By in previous queary 

with SBvsPRO 
as 
(
select COUNT(person_data.MOSIS_ID) AS 'student_body',
COUNT(CASE WHEN test_data.Performance_Level <> 'Proficient' THEN 1 END) AS 'student_body_not_Proficient',
COUNT(CASE WHEN test_data.Performance_Level = 'Proficient' THEN 1 END) AS 'student_body_Proficient',
cast(
     COUNT(CASE WHEN test_data.Performance_Level = 'Proficient' THEN 1 END) * 100 /
     COUNT(person_data.MOSIS_ID)
 as decimal(5,2)) as '%_of_population_Proficient'
from [spring 2024 eoc] as person_data, [spring 2024 eoc per] as test_data
where person_data.MOSIS_ID = test_data.MOSIS_ID and person_data.sessions = test_data.Sessions
)

select *, (student_body_not_Proficient*100/student_body) as precent_not_proficient
from SBvsPRO

--using temp tables to perfomr caculation on partiton by in previous query

drop table if exists #PrecentPopProficient
Create Table #PrecentPopProficient
(
student_body smallint,
SB_not_prof smallint,
SB_prof smallint,
per_prof float
)
Insert into #PrecentPopProficient
select COUNT(person_data.MOSIS_ID) AS 'student_body',
COUNT(CASE WHEN test_data.Performance_Level <> 'Proficient' THEN 1 END) AS 'SB_not_prof',
COUNT(CASE WHEN test_data.Performance_Level = 'Proficient' THEN 1 END) AS 'SB_prof',
cast(
     COUNT(CASE WHEN test_data.Performance_Level = 'Proficient' THEN 1 END) * 100 /
     COUNT(person_data.MOSIS_ID)
 as decimal(5,2)) as 'per_prof'
from [spring 2024 eoc] as person_data, [spring 2024 eoc per] as test_data
where person_data.MOSIS_ID = test_data.MOSIS_ID and person_data.sessions = test_data.Sessions;

select *, 
CAST(SB_not_prof * 100.0 / student_body AS DECIMAL(5,2)) AS per_not_prof
from #PrecentPopProficient;

--creating view to store data for later visualization
go
create view #PrecentPopProficient as 
select
COUNT(person_data.MOSIS_ID) AS 'student_body',
COUNT(CASE WHEN test_data.Performance_Level <> 'Proficient' THEN 1 END) AS 'SB_not_prof',
COUNT(CASE WHEN test_data.Performance_Level = 'Proficient' THEN 1 END) AS 'SB_prof',
cast(
     COUNT(CASE WHEN test_data.Performance_Level = 'Proficient' THEN 1 END) * 100 /
     COUNT(person_data.MOSIS_ID)
 as decimal(5,2)) as 'per_prof'
from [spring 2024 eoc] as person_data, [spring 2024 eoc per] as test_data
where person_data.MOSIS_ID = test_data.MOSIS_ID 
and person_data.sessions = test_data.Sessions;
go