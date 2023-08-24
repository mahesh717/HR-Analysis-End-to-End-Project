
/*Problem Statement : 
                     Our Client a leading multinatinal corporation has been experiencing some puzzling trends in their employee turnover rates,
                     they suspect that there may be hidden factors causing  valuable employees to leave?
                  => As a data analyst its our job to dig deep into their HR data and uncover the truth!!! */
                  

                         -- Creating Table --
create table HR(
id text,
first_name varchar(30),
last_name varchar(30),
birthdate text,
gender varchar(10),
race varchar(30),
department varchar(30),
jobtitle varchar(30),
location varchar(30),
hire_date text,
termdate text,
location_city varchar(15),
location_state varchar(15)
);

                    -- Inserting Data  --
                    
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Human_Resources.csv'
INTO TABLE HR
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



           -- Data Cleaning & Pre-Processing --
           
select * from hr;       
select count(*) from hr
where termdate is null;
describe hr;


-- 1. changing data type
ALTER TABLE hr
change column id emp_id varchar(30);


-- 2. changing text to date (for birthdate, hiredate & termdate)
UPDATE hr
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%c/%e/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%c-%e-%Y'), '%Y-%m-%d') 
    ELSE NULL
END;


UPDATE hr
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%c/%e/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%c-%e-%Y'), '%Y-%m-%d') 
    ELSE NULL
END;


UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != " " ;



UPDATE HR
SET termdate = null
where termdate = '0000-00-00 00:00:00';



-- 3. changing data-type (birthdate,hiredate & termdate)
ALTER TABLE HR
MODIFY COLUMN birthdate date;

ALTER TABLE HR
MODIFY COLUMN hire_date date;

ALTER TABLE HR
MODIFY COLUMN termdate datetime;


-- creating an age column and retreving age based on (birthdate)
ALTER TABLE HR
ADD COLUMN age int;

UPDATE HR
SET age = timestampdiff(year,birthdate,curdate());
 
 
 
 -- Queries 
 
 -- 1. what is the gender breakdown of the current employees in the company ?
 select gender, count(gender) as count
 from hr
 where termdate is null 
 group by gender;
 
 
 -- 2. what is the race breakdown of the current employees in the company ?
  select race, gender, count(*) as count
  from hr
  where termdate is null
  group by race, gender;
  
  
  -- 3. what is the age distribution of the current employees in the company ?
   select
   case 
   when age >=18 and age <=24 then "18-24"
   when age >=25 and age <=34 then "25-34"
   when age >=35 and age <=44 then "35-44"
   when age >=45 and age <=54 then "45-54"
   when age >=55 and age <=64 then "55-64"
   else "65+"
   end as age_group,gender,
   count(*) as count
   from hr
   where termdate is null
   group by age_group,gender
   order by age_group asc;



-- 4. No of employees working in headquaters and remote?
select location, gender,count(*) as count
from hr
where termdate is null 
group by location, gender;


-- 5. what is the average length of employement who has been terminated ?
select round(avg(year(termdate) - year(hire_date))) as length_of_employement
from hr
where termdate is not null AND termdate <= curdate() ;


-- 6. How does the gender distribution vary across dept & job titles ?
select department, jobtitle, gender, count(*) as count
from hr
where termdate is null
group by gender, department, jobtitle 
order by department, jobtitle ;


-- 7. what is the distribution of jobtitle across the company ?
select jobtitle, count(*) as count
from hr
where termdate is null
group by jobtitle ;


-- 8. which department has the highest turnover rate ?
select department,
count(*) as total_count,
count(case
          when termdate is not null and termdate <= curdate() then 1 end) as turnover_count,
round((count(case
          when termdate is not null and termdate <= curdate() then 1 end) / count(*))*100,2) as turnover_rate
from hr
group by department
order by turnover_rate desc;



-- 9. what is the distribution of the employees across states ?
select location_state, gender, count(*) as count
from hr
where termdate is null
group by location_state, gender ;


-- 10. how has the company employees count changed over time based on hire and termination date ?
select year,
       hires,
       terminations,
       -- gender,
       hires-terminations as net_change,
       round((hires-terminations)/hires*100,2) as change_percent
from (
	select year(hire_date) as year,
             count(*) as hires,
             -- gender,
			 sum(case when termdate is not null and termdate <= curdate() then 1 end) as terminations 
             from hr
			 group by year(hire_date)) as a
-- group by year
order by year ;
       
       
       
-- 11. what is the tenure distribution in each department ?
select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr
where termdate is not null and termdate <= curdate()
group by department ;



-- 12. Termination & hire breakdown as per Gender ?
select gender,
hires,
terminations,
round((terminations/hires)*100,2) as termination_rate
from(
      select gender,
      count(*) as hires,
	  count(case when termdate is not null and termdate <= curdate() then 1 end) as terminations
      from hr
      group by gender) a
group by gender
order by termination_rate desc;



-- 13. Termination & hire breakdown as per age ?
select age, gender,
hires,
terminations,
round((terminations/hires)*100,2) as termination_rate
from(
      select age,gender,
      count(*) as hires,
      count(case when termdate is not null and termdate <= curdate() then 1 end) as terminations
      from hr
      group by age)a
group by age, gender
order by termination_rate desc;



-- 14. Termination & hire breakdown as per department ?
select department,
hires,
terminations,
round((terminations/hires)*100,2) as termination_rate
from(
     select department,
     count(*) as hires,
	 count(case when termdate is not null and termdate <= curdate() then 1 end) as terminations
     from hr
     group by department)a
group by department
order by termination_rate desc;



-- 15. Termination & hire breakdown as per race ?
select race,
hires,
terminations,
round((terminations/hires)*100,2) as termination_rate
from(
     select race,
     count(*) as hires,
	 count(case when termdate is not null and termdate <= curdate() then 1 end) as terminations
	 from hr
	 group by race) a 
order by termination_rate;



-- 16. Termination & hire breakdown as per year ?
select years, 
hires,
terminations,
gender,
round((terminations/hires)*100,2) as termination_rate,
round((hires/terminations)*100,2) as hire_rate
from(
     select year(hire_date) as years, gender,
     count(*) as hires,
	 count(case when termdate is not null and termdate <= curdate() then 1 end) as terminations
	 from hr
	 group by year(hire_date)) a 
order by termination_rate;



-- 17. emp details
select * from hr;

select count(*) as total 
from hr
where termdate is null ;

select count(*) 
from hr
where gender = 'Male' 
and termdate is null;

select count(*) 
from hr
where gender = 'Female'
and termdate is null;

select count(*) 
from hr
where gender = 'Non-confor'
and termdate is null;


-- method 1 to calculate male percent
select 
sum(case when gender = 'Male' then 1 else 0 end) as male,
count(*) as total,
sum(case when gender = 'Male' then 1 else 0 end) / count(*)*100 as male_percent,
sum(case when gender = 'Female' then 1 else 0 end) as female,
-- count(*) as total,
sum(case when gender = 'Female' then 1 else 0 end) / count(*)*100 as female_percent,
sum(case when gender = 'Non-Confor' then 1 else 0 end) as non_confor,
-- count(*) as total,
sum(case when gender = 'Non-Confor' then 1 else 0 end) / count(*)*100 as non_confor_percent
from hr
where termdate is null;


-- method 2 to calculate male percent
SELECT
 SUM(gender = 'Male') / (COUNT(*)) * 100  AS percentage_male
FROM
  hr
  where termdate is null;
  
  
-- method 3 to calculate male percent (using variable)
select 
@total:= count(*) as total_count,
@male:= sum(gender = 'male') as male_count,
round((@male/@total)*100,2) as percent_male
from hr 
where termdate is null;























   



















