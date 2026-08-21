# 📺 BrightTV Case Study

## Project Overview

The BrightTV Case Study is a SQL-based data analytics project that demonstrates the complete data analysis process, from data cleaning to business insight generation. The project uses viewership and user data to answer business questions, identify viewing trends, and provide recommendations that support data-driven decision-making.

This case study was completed as part of a Data Analytics learning programme and focuses on applying SQL best practices in a real-world business scenario.

---

## Project Objectives

The objectives of this project were to:

- Clean and prepare raw datasets for analysis.
- Handle missing and inconsistent values.
- Convert and standardize date and time formats.
- Analyse customer viewing behaviour.
- Generate business insights using SQL.
- Present findings in a clear and meaningful way.

---

## Dataset

The project uses two primary datasets:

### 1. Viewership Dataset
Contains information about viewing activity, including:

- User ID
- Content watched
- Viewing duration
- Device used
- Record date
- Viewing timestamps

### 2. Users Dataset
Contains customer demographic information such as:

- User ID
- Gender
- Province
- Race
- Age
- Email
- Social Media Handle

---

## Data Cleaning

Several data quality issues were addressed before analysis, including:

- Handling NULL values
- Replacing blank values
- Standardising inconsistent text
- Converting timestamps into usable dates
- Cleaning duration values
- Creating indicator flags using CASE statements
- Removing duplicate and invalid records where necessary

SQL functions used include:

- CASE
- COALESCE
- NULLIF
- IFNULL
- CURRENT_DATE
- YEAR
- MONTH
- DAYNAME
- MONTHNAME
- DATEDIFF
- TO_DATE

---

## SQL Concepts Demonstrated

This project demonstrates practical use of:

- SELECT statements
- WHERE filtering
- ORDER BY
- GROUP BY
- HAVING
- Aggregate Functions
  - COUNT()
  - SUM()
  - AVG()
  - MAX()
  - MIN()
- CASE statements
- Common Table Expressions (CTEs)
- LEFT JOIN
- INNER JOIN
- Date Functions
- Temporary transformations
- Aliasing
- Data aggregation

---

## Business Questions Answered

Examples of business insights generated include:

- Which content receives the highest number of views?
- Which provinces have the highest audience?
- What devices are most commonly used?
- Which days of the week have the highest viewership?
- What is the average viewing duration?
- How complete is the customer profile information?
- Which users have provided email addresses or social media handles?

---

## Repository Structure

```
BrightTV_Case_Study/
│
├── Dataset/
│   ├── Viewership Dataset
│   └── Users Dataset
│
├── SQL/
│   ├── Data Cleaning
│   ├── Viewership Analysis
│   ├── User Analysis
│   └── Final Queries
│
├── Presentation/
│   └── BrightTV Presentation
│      └── BrightTV_Dashboard.xsls
│      └── BrightTV_Dasborard.pdf
│      └── BrightTV_PowerBI_dashboard screenshhots
│      └── BrightTV_Looker_studio.pdf
│      └── BrightTV_Lovable_Dashboard link
│      └── BrightTV Databricks
└── README.md
```

---
## Interactive Dashboard
[View the BrightTV Interactive Data/Looker Studio Dashboard] (https://datastudio.google.com/s/kGPjwwRloeA)
([View the BrightTV Interactive Lovable Dashboard] (https://tv-insights-hub.lovable.app/)
## Tools Used

- Databricks Community Edition
- SQL
- Git
- GitHub
- Microsoft Excel
- Microsoft PowerPoint

---

## Skills Demonstrated

- SQL Programming
- Data Cleaning
- Data Transformation
- Business Analysis
- Data Exploration
- Data Aggregation
- Analytical Thinking
- Problem Solving
- Data Storytelling
- Version Control using Git & GitHub

---

## Key Learnings

Through this project I gained practical experience in:

- Writing efficient SQL queries
- Cleaning messy datasets
- Working with real business data
- Using joins to combine multiple datasets
- Building reusable SQL logic with CTEs
- Applying date functions for trend analysis
- Translating technical results into business insights

---

## Future Improvements

Potential future enhancements include:

- Building an interactive Power BI dashboard.
- Creating automated SQL pipelines.
- Adding advanced SQL window functions.
- Performing predictive analytics on viewing behaviour.

---

## Author

**Busisiwe Khoza**

Aspiring Data Analyst passionate about transforming raw data into meaningful insights through SQL, analytics, and business intelligence.

GitHub:
https://github.com/BusiK16

---

## License

This repository is intended for educational and portfolio purposes.
