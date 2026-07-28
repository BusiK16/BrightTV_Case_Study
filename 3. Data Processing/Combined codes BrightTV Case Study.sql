-- Databricks notebook source
--USER_PROFILE CODE

-- This is to check what my data looks like.
SELECT *
FROM brighttv.raw_data.user_profiles
LIMIT 5;
-------------------------------------------
-- Gender Checks
-------------------------------------------
SELECT DISTINCT gender
FROM brighttv.raw_data.user_profiles;

SELECT DISTINCT
       CASE 
            WHEN gender = 'None' THEN 'unknown' -- Replaces the value None with unknown 
            WHEN gender = ' ' THEN 'unknown' -- Replaces the empty space with unknown 
            WHEN gender IS NULL THEN 'unknown' -- Replaces the null with unknown 
       ELSE gender -- if gender is male or female return it as it is 
       END AS sex -- new column name
FROM brighttv.raw_data.user_profiles;
-------------------------------------------
-- Race Checks
-------------------------------------------
SELECT DISTINCT race
FROM brighttv.raw_data.user_profiles;

SELECT COUNT(DISTINCT userid) AS subscribers,
        CASE 
            WHEN race = 'other' THEN 'unknown' -- Replace other with unknown 
            WHEN race = 'None' THEN 'unknown' -- Replaces None with unknown 
            WHEN race = ' ' THEN 'unknown' -- Replaces the empty space with unknown 
            WHEN race IS NULL THEN 'unknown'-- Replaces the null with unknown 
        ELSE race -- keep the race as it is
        END AS ethnicity -- new column name 
FROM brighttv.raw_data.user_profiles
GROUP BY ethnicity;

-------------------------------------------
-- Province Checks
-------------------------------------------

SELECT DISTINCT province
FROM brighttv.raw_data.user_profiles;

SELECT DISTINCT
        CASE 
            WHEN province = 'None' THEN 'unknown' -- Replaces None with unknown 
            WHEN province = ' ' THEN 'unknown' -- Replaces the empty space with unknown 
            WHEN province IS NULL THEN 'unknown'-- Replaces the null with unknown 
        ELSE province -- keep theprovince as it is
        END AS region -- new column name 
FROM brighttv.raw_data.user_profiles;

--------------------------------------------
-- Age Checks
--------------------------------------------

SELECT MIN(Age) AS min_age, -- Check the youngest person
       MAX(Age) AS max_age, -- Find the oldest person
       AVG(Age) AS mean_age -- Find the average age between upper bound and lower bound
FROM brighttv.raw_data.user_profiles;
-- Groupings
SELECT 
        CASE 
            WHEN Age = '0' THEN 'Infant'
            WHEN Age BETWEEN 1 AND 12 THEN 'Child'
            WHEN Age BETWEEN 13 AND 17 THEN 'Teenager'
            WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult'
            WHEN Age BETWEEN 36 AND 50 THEN 'Adult'
            WHEN Age > 50 AND Age <= 60 THEN 'Elder' -- Another way of doing a BETWEEN statement using operations
            WHEN Age > 60 THEN 'Pensioner'
        END AS Age_group
FROM brighttv.raw_data.user_profiles;
----------------------------------------------------------
-- Returning all the columns on the user profile dataset, putting everything under one SELECT statement AND Creating Temporary Table/ View
----------------------------------------------------------
CREATE OR REPLACE TEMPORARY VIEW processed_user_profiles AS(
SELECT 
    UserID,
    CASE 
           WHEN (`Email` IS NOT NULL) AND (`Email` <>' ') AND (`Email` NOT IN ('None', 'other')) THEN 1
            ELSE 0
    END AS email_flag,

    CASE 
            WHEN (`Social Media Handle` IS NOT NULL) AND (`Social Media Handle` <>' ') AND (`Social Media Handle` NOT IN ('None', 'other')) THEN 1
            ELSE 0
    END AS social_media_flag,
      
     CASE 
            WHEN gender = 'None' THEN 'unknown'  
            WHEN gender = ' ' THEN 'unknown'  
            WHEN gender IS NULL THEN 'unknown'  
       ELSE gender  
       END AS sex,

       CASE 
            WHEN race = 'other' THEN 'unknown' -- Replace other with unknown 
            WHEN race = 'None' THEN 'unknown' -- Replaces None with unknown 
            WHEN race = ' ' THEN 'unknown' -- Replaces the empty space with unknown 
            WHEN race IS NULL THEN 'unknown'-- Replaces the null with unknown 
        ELSE race -- keep the race as it is
        END AS ethnicity,
        
        CASE 
            WHEN province = 'None' THEN 'unknown'  
            WHEN province = ' ' THEN 'unknown'  
            WHEN province IS NULL THEN 'unknown'
        ELSE province 
        END AS region, 

        AGE,
        CASE 
            WHEN Age = '0' THEN '01.Infant: 0'
            WHEN Age BETWEEN 1 AND 12 THEN '02.Child: 1-12'
            WHEN Age BETWEEN 13 AND 17 THEN '03.Teenager: 13-17'
            WHEN Age BETWEEN 18 AND 35 THEN '04.Young Adult: 18-35'
            WHEN Age BETWEEN 36 AND 50 THEN '05.Adult: 36-50'
            WHEN Age > 50 AND Age <= 60 THEN '06.Elder: 50-60' 
            WHEN Age > 60 THEN '07.Pensioner: >60'
        END AS Age_group

FROM brighttv.raw_data.user_profiles);

SELECT *
FROM processed_user_profiles;

-- Checking Active Subscribers
SELECT COUNT(*) AS cnt,
       COUNT(DISTINCT UserID) AS active_subscribers
FROM processed_user_profiles;

-- Checking for duplicates
SELECT COUNT(*) AS cnt,
       UserID
FROM processed_user_profiles
GROUP BY UserID
HAVING COUNT(*)>1; -- if there are any duplicates, it will return a count greater than 1, if not it will return no rows

----------------------------------------
--VIEWERSHIP CODE
---------------------------------------- 
-- The first code SELECT* is to help see what is in the table
SELECT*
FROM brighttv.raw_data.viewership
LIMIT 10;

-- Second code: Applying DATE FUNCTIONS, these are used in the date column to extract date i.e. day, month, year
-- In this select statement 'RecordDate2' is a date column a.k.a timestamp and it will return watch_time in the YYY-MM-DD format 
SELECT TO_DATE(RecordDate2) AS watch_date --TO_DATE Converts a string into a date YYYT-MM-DD
FROM brighttv.raw_data.viewership;

-- In this code, we just added the RecordDate2 column to the select statement and the watch_date column to return both columns
SELECT 
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date --TO_DATE Converts a string into a date YYYY-MM-DD
FROM brighttv.raw_data.viewership;

-- Now let's extract the dates using more DATE FUNCTIONS names, year, and day
-- You can add visuals to them from the database
SELECT
    UserID0,
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date, --TO_DATE Converts a string into a date YYYY-MM-DD
    DAYNAME(TO_DATE(RecordDate2)) AS day_name, -- Extracts the day name
    MONTHNAME(TO_DATE(RecordDate2)) AS month_name, -- Extracts the month name
    YEAR(TO_DATE(RecordDate2)) AS event_year, -- Extracts the year value
    DAY(TO_DATE(RecordDate2)) AS event_dt -- Extracts day value
FROM brighttv.raw_data.viewership;

-- DATE FUNCTIONS allow us to build a CASE statement within them
-- Also returning Count Distinct number of subscribers
-- And then create a Temporary TABLE to save the results and create your own version of the table, here it will be called 'viewership'
CREATE OR REPLACE TEMPORARY VIEW viewership AS (
SELECT 
    COUNT(DISTINCT UserID0) AS number_of_subs,
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date, --TO_DATE Converts a string into a date YYYT-MM-DD
    DAYNAME(TO_DATE(RecordDate2)) AS day_name, -- Extracts the day name
    CASE 
        WHEN DAYNAME(TO_DATE(RecordDate2)) IN ('Sat', 'Sun') THEN '02. Weekend'
        ELSE '01. Weekday'
    END AS Day_classification,
    MONTHNAME(TO_DATE(RecordDate2)) AS month_name, -- Extracts the month name
    YEAR(TO_DATE(RecordDate2)) AS event_year, -- Extracts the year value
    DAY(TO_DATE(RecordDate2)) AS event_dt -- Extracts day value
FROM brighttv.raw_data.viewership
WHERE UserID0 IS NOT NULL
GROUP BY ALL
ORDER BY watch_date DESC);

-- How many people are watching Weekdays and Weekends
SELECT SUM (number_of_subs) AS subs,
        day_classification
FROM viewership
Group BY day_classification;

--Viewership table check
SELECT *
FROM viewership;

--------------------------------------------
--BIG CODE: USER_PROFILE X VIEWERSHIP
--------------------------------------------

-- I wanted to see the whole table before I start doing any analysis on it
SELECT *
FROM brighttv.raw_data.user_profiles; 

-- checking for duplicates in my data
SELECT UserID,
 COUNT(*) AS duplicate_count
FROM brighttv.raw_data.user_profiles
GROUP BY UserID
HAVING COUNT(*) > 1;

-- I am checking the size pf the data
SELECT COUNT(*) AS number_of_rows,
 COUNT(DISTINCT UserID) AS number_subs
FROM brighttv.raw_data.user_profiles;

-- Are there any rows where UserID is NULL
SELECT COUNT(*) AS cnt
FROM brighttv.raw_data.user_profiles
WHERE UserID IS NULL;

-- Distinct UserID
SELECT DISTINCT UserID
FROM brighttv.raw_data.user_profiles;
---------------------------------------------------------
--Gender Checks
---------------------------------------------------------
SELECT DISTINCT gender
FROM brighttv.raw_data.user_profiles;
-- SELECT COUNT(*)
-- FROM workspace.default.bright_tv_user_profiles
-- WHERE gender=' ';

SELECT
    COUNT(DISTINCT userid) AS subs,
    CASE
    WHEN gender =' ' THEN 'None'
 ELSE gender
 END AS Gender
FROM brighttv.raw_data.user_profiles
GROUP BY Gender;
---------------------------------------------------------
--Race Checks
---------------------------------------------------------
SELECT COUNT(*) AS num_rows
FROM brighttv.raw_data.user_profiles
WHERE Race IS NULL;
SELECT DISTINCT Race
FROM brighttv.raw_data.user_profiles;

SELECT DISTINCT
    CASE
    WHEN Race='other' THEN 'None'
    WHEN Race=' ' THEN 'None'
    ELSE Race
END AS Race
FROM brighttv.raw_data.user_profiles;
---------------------------------------------------------
--Province Checks
---------------------------------------------------------
SELECT DISTINCT Province
FROM brighttv.raw_data.user_profiles;
SELECT DISTINCT
    CASE
    WHEN Province=' ' THEN 'Uncategorized'
    WHEN Province='None' THEN 'Uncategorized'
    ELSE Province
    END AS Region
FROM brighttv.raw_data.user_profiles;

---------------------------------------------------------
--Age
---------------------------------------------------------
SELECT MIN(Age) AS min_age, --- = 0
 MAX(Age) AS max_age -- = 114
FROM brighttv.raw_data.user_profiles;
SELECT COUNT(*) AS cnt
FROM brighttv.raw_data.user_profiles
WHERE age IS NULL;

--CTE using both tables
WITH 
user_profiles AS (
SELECT UserID,
    CASE
            WHEN Province=' ' THEN 'Uncategorized'
            WHEN Province='None' THEN 'Uncategorized'
    ELSE Province
    END AS Region,
            age,
    CASE
            WHEN age = 0 THEN 'Infants'
            WHEN age BETWEEN 1 AND 12 THEN 'Kids'
            WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
            WHEN age BETWEEN 20 AND 35 THEN 'Youth'
            WHEN age BETWEEN 36 AND 50 THEN 'Adult'
            WHEN age BETWEEN 51 AND 65 THEN 'Elder'
            WHEN age >65 THEN 'Pensioner'
    END AS age_groups,

    CASE
            WHEN (email IS NOT NULL )OR (email=' ') OR (email NOT IN ('None'))THEN 1
    ELSE 0
    END AS email_flag,

    CASE
            WHEN `Social Media Handle` IS NOT NULL OR `Social Media Handle`=' ' OR `Social Media Handle` NOT IN ('None')THEN 1
    ELSE 0
    END AS sm_flag,
    
    CASE
            WHEN Race='other' THEN 'None'
            WHEN Race=' ' THEN 'None'
    ELSE Race
    END AS Race,

    CASE
            WHEN gender =' ' THEN 'None'
    ELSE gender
    END AS Gender
FROM brighttv.raw_data.user_profiles
),

viewership AS (
 SELECT
 COALESCE(UserID0,userid4) AS userid,
        TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
        TO_DATE(RecordDate2) AS watch_date, --TIME(RecordDate2) AS watch_time,
        TO_CHAR(RecordDate2, 'DD') AS day_of_week,
        DAYNAME(RecordDate2) AS day_name,

    CASE
            WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
    ELSE 'weekday'
    END AS day_classification,
            MONTHNAME(RecordDate2) AS month_name,

    CASE
            WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
            WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
    ELSE Channel2
    END AS Tv_channel,
            date_format(RecordDate2, 'HH:mm:ss') AS watch_time,

    CASE
            WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
            WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
            WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
            WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
    END AS time_of_day,
            DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,

    CASE
            WHEN duration BETWEEN '00:05:00' AND '00:30:00' THEN '01. Low Usage: <30 min'
            WHEN duration BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage: <60 min'
            WHEN duration > '00:59:59' THEN '03. High Usage: >60 min'
    ELSE '04. No Usage'
    END AS screen_time_bucket,
    HOUR(RecordDate2) AS hour_of_day
FROM brighttv.raw_data.viewership
)
SELECT Coalesce(A.userid,B.userid) AS sub_id,
    month_id,
    watch_date,
    day_of_week,
    day_name,
    day_classification,
    month_name,
    Tv_channel,
    time_of_day,
    hour_of_day,
    screen_time_bucket,
 --user_flag,
    duration,
    Region,
    age_groups,
    email_flag,
    sm_flag,
    Race,
    Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
ON A.userid=B.userid;








