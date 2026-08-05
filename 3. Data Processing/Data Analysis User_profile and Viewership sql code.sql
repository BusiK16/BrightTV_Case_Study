-- Databricks notebook source
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

-- Are the any rows where UserID is NULL
SELECT COUNT(*) AS cnt
FROM brighttv.raw_data.user_profiles
WHERE UserID IS NULL;

-- Distinct UseID
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

--- Updated BIG CODE with EVERYTHING and filtering
-- CTE using both tables to create one combined script
WITH
cleaned_user_profiles AS
(SELECT UserID,
           CASE ---Creating gender classification
                 WHEN Gender = 'None' THEN 'unknown'
                 WHEN Gender = ' ' THEN 'unknown'
                 WHEN Gender IS NULL THEN 'unknown'
                 ELSE Gender
              END AS Gender,
               
             CASE---classifying race
                 WHEN Race = 'None' THEN 'unknown'
                 WHEN Race = ' ' THEN 'unknown'
                 WHEN Race = 'other' THEN 'unknown'
                 WHEN Race IS NULL THEN 'unknown'
                 ELSE Race
             END AS Ethnicity,

            CASE ---classifying Age
               WHEN Age = 0 THEN 'infant'
               WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
               WHEN Age BETWEEN 13 AND 17 THEN 'youth'
               WHEN Age BETWEEN 18 AND 35 THEN 'youth Adults'
               WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
               WHEN Age > 50 AND Age<=60 THEN 'Elder'
               WHEN Age > 60 THEN 'Pensioner'
            END AS Age_group,

          CASE --classifying province
                WHEN Province = 'None' THEN 'Unclassified'
                WHEN Province = ' ' THEN 'Unclassified'
                WHEN Province = 'other' THEN 'Unclassified'
                WHEN Province IS NULL THEN 'Unclassified'
                ELSE Province
             END AS Region,

          CASE --classifying email
                WHEN 'Email' IS NOT NULL THEN 1
                WHEN 'Email'<> ' ' THEN 1
                ELSE 0
           END AS Email_flag,

        CASE --classifying social media handle
            WHEN 'Social Media Handle' IS NOT NULL THEN 1
            ELSE 0
        END AS Social_media_handle_flag

    FROM brighttv.raw_data.user_profiles),

base_viewership AS (
    SELECT
        COALESCE (UserID0, userid4) AS User_ID, -- combining two user ids into one
        From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg') AS RecordDate_SAST,--converting timestamp to SA time
        Channel2,
        `Duration 2`        
FROM brighttv.raw_data.viewership
),

cleaned_viewership AS(
    SELECT
        User_ID,
        RecordDate_SAST,
        TO_CHAR(RecordDate_SAST, 'yyyyMM') AS month_id,
        TO_CHAR(RecordDate_SAST, 'DD') AS day_of_week,
        TO_DATE(RecordDate_SAST) AS watch_date, -- Convert a string into a date YYYY-MM=-DD
        DAYNAME(TO_DATE(RecordDate_SAST))AS day_name, -- Extract the day name
        MONTHNAME(TO_DATE(RecordDate_SAST)) AS month_name, -- Extracts the month name
        YEAR(TO_DATE(RecordDate_SAST)) AS event_year, -- Extracts the year value
        DAY(TO_DATE(RecordDate_SAST)) AS event_day, -- Extracts the day value
        HOUR(RecordDate_SAST) AS Hour_of_day,--extracts hour of day

        CASE
               WHEN DAYNAME(TO_DATE(RecordDate_SAST)) IN ('Sat', 'Sun') THEN '02. Weekend'
               ELSE '01. Weekday'
        END AS day_classification,

        DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') AS Watch_time,--converting date format to time
        CASE
                WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
                WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
                WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
                WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
        END AS Time_of_day, 

        `Duration 2`,
        DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS Duration,--converting duration into time format
        HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) +
        MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 60.0 + --converting minutes to seconds
        SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 3600.0--converting seconds to minutes
        AS Duration_hours,

        HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 + -- converting hours to minutes
        MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) + 
        SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 60.0 --converting seconds to minutes
        AS Duration_minutes,

        HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 + --converting hours to seconds
        MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 + ---converting minutes to seconds
        SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))
        AS Duration_seconds,    

        CASE
                WHEN Duration_seconds BETWEEN 300 AND 1800 THEN '01. Low Usage (<30 min)'
                WHEN Duration_seconds BETWEEN 1801 AND 3599 THEN '02. Medium Usage (<60 min)'
                WHEN Duration_seconds >= 3600 THEN '03. High Usage (>60 min)'
                ELSE '04. No Usage'
        END AS Screen_time_bucket,

        CASE --cleaning channel
                WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
                WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
                ELSE Channel2
        END AS Tv_channel
FROM base_viewership)

--- Creating the final cleaned table
SELECT
      COALESCE (A. User_ID, B. UserID) AS Sub_ID,
          Gender,
          Ethnicity,
          Age_group,
          Region,
          Email_flag,
          Social_media_handle_flag,
          RecordDate_SAST,
          Watch_date,
          Day_name,
          Day_of_week,
          Month_id,
          Month_name,
          Event_year,
          Event_day,
          Hour_of_day,
          Day_classification,
          Watch_time,
          Time_of_day,
          Duration,
          Duration_hours,
          Duration_minutes,
          Duration_seconds,
          Screen_time_bucket,
          Tv_channel
FROM cleaned_viewership AS A
LEFT JOIN cleaned_user_profiles AS B
ON A.User_ID = B.UserID;
