--1.

select count(MOSIS_ID) AS student_body,
count(case when Percent_Correct <= 59.5 then 1 end) as failing, 
cast(
	count(case when Percent_Correct <= 59.5 then 1 end) *100.0 /
	count(MOSIS_ID) as decimal(5,2)
) as failing_percent
from [spring 2024 eoc]

--just a double check based off the data porvided
--2.

select Grade, 
count(case  when Percent_Correct <= 59.5 then 1 end) as Amount_failed
from [spring 2024 eoc]
where Scale_Score is not null
group by Grade
order by Grade



--get data for tablu
--3.

select grade, count(MOSIS_ID) as student_body, 
count(case when Percent_Correct <= 59.5 then 1 end) as Amount_failed,
cast(
	count(case when Percent_Correct <=59.5 then 1 end) *100.0 /
	count(MOSIS_ID) as decimal(5,2)
) as Percent_of_student_body_failed
from [spring 2024 eoc]
group by Grade
order by Percent_of_student_body_failed desc

/*
District_Code	District_Name	School_Code	School_Name	MOSIS_ID	Grade	Administration	Course	Points_Earned	Points_Possible	Percent_Correct	Scale_Score	sessions
*/
-- more tablue data
select Grade,
    count(MOSIS_ID) as student_body,
    max(Percent_Correct) as Highest_Percent_Correct,
    min(Percent_Correct) as Lowest_Percent_Correct,
    count(case when Percent_Correct <= 59.5 then 1 end) as SB_failing,
    cast(
        count(case when Percent_Correct <= 59.5 then 1 end) * 100.0 /
        COUNT(MOSIS_ID)
        as decimal(5,2)
    ) AS Percent_failing
from [spring 2024 eoc]
group by Grade
order by Percent_failing desc;
