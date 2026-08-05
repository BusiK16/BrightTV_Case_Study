-- Databricks notebook source
---- UPDATED WITH DURATION AND TIMESTAMP CONVERSION

-- Inspecting our table - find out what is in the table columns 
SELECT *
FROM brighttv.raw_data.viewership
LIMIT 10;

-- Applying the DATE FUNCTIONS, they allow us to extract days, months, years YYYY-MM-DD  (RecordDate2)
SELECT
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date -- TO-DATE function helps convert a timestamp into a date YYYY-MM-DD
    FROM brighttv.raw_data.viewership;

-- Now let's extract the dates using more DATE FUNCTIONS names, year, and day
SELECT 
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date, --TO_DATE Converts a string into a date YYYY-MM-DD
    DAYNAME(TO_DATE(RecordDate2)) AS day_name, -- Extracts the day name
    MONTHNAME(TO_DATE(RecordDate2)) AS month_name, -- Extracts the month name
    YEAR(TO_DATE(RecordDate2)) AS event_year, -- Extracts the year value
    DAY(TO_DATE(RecordDate2)) AS event_dt, -- Extracts day value
    HOUR(RecordDate2) AS Hour_of_day --extracts hour of day
FROM brighttv.raw_data.viewership;

-- Converting timestamp from UTC to SAST
SELECT
    COALESCE (UserID0, userid4) AS User_id,-- combining two user ids into one
    RecordDate2,
    From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg') AS RecordDate_SAST --converting timestamp to SA time
FROM brighttv.raw_data.viewership;

-- Duration conversion to HH:mm:ss format
SELECT
    `Duration 2`,
     DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS Duration--converting duration into time format
FROM brighttv.raw_data.viewership;


-- Channel = See channels on BrighTV
SELECT DISTINCT(Channel2)
FROM brighttv.raw_data.viewership; -- results show that there are repetition of SawSee and SuperSport

-- Creating a temporary table/view - helps us analyze subscribers/ viewing pattern/trend
CREATE OR REPLACE TEMPORARY TABLE processed_viewership AS(
    SELECT
        COUNT(DISTINCT UserID0) AS number_of_subs,
        RecordDate2,
        From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg') AS RecordDate_SAST,
        TO_DATE(RecordDate2) AS watch_date,
        DAYNAME(TO_DATE(RecordDate2)) AS day_name,
        DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS Duration,--converting duration into time format
        HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) +
        MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 60.0 + --converting minutes to hours
        SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 3600.0--converting seconds to hours
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
            WHEN DAYNAME(TO_DATE(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg'))) IN ('Sat', 'Sun') THEN '02. Weekend'
            ELSE '01. Weekday'
            END AS day_classification,
            MONTHNAME(TO_DATE(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg'))) AS month_name,
            YEAR(TO_DATE(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg'))) AS event_year, 
            DAY(TO_DATE(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg'))) AS event_day,
            HOUR(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg')) AS Hour_of_day,--extracts hour of day

    CASE
      WHEN HOUR(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg')) BETWEEN 0 AND 5 THEN '01. Midnight'
        WHEN HOUR(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg')) BETWEEN 6 AND 11 THEN '02. Morning'
        WHEN HOUR(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg')) BETWEEN 12 AND 16 THEN '03. Afternoon'
        WHEN HOUR(From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg')) BETWEEN 17 AND 23 THEN '04. Evening'
    END AS Time_of_day
FROM brighttv.raw_data.viewership 
    WHERE UserID0 IS NOT NULL
    GROUP BY ALL
    ORDER BY watch_date DESC
);


-- Inspect the temporary table 
SELECT*
FROM  processed_viewership;

-- How many people are watching Weekdays and Weekends
SELECT SUM (number_of_subs) AS subs,
        day_classification
FROM processed_viewership
Group BY day_classification;

