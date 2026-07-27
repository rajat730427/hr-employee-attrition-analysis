/* =====================================================================
   HR EMPLOYEE ATTRITION - SQL ANALYSIS
   =====================================================================
   Database   : hr_attrition.db (SQLite)  -- also works on MySQL/PostgreSQL
                with minor syntax tweaks (noted where relevant)
   Table      : employees  (1470 rows, one row per employee)
   How to run : sqlite3 hr_attrition.db  then paste any query below
                OR: open hr_attrition.db in DB Browser for SQLite
   ===================================================================== */

/* ---------------------------------------------------------------------
   0. SCHEMA (for reference / recreating the table from the raw CSV)
   --------------------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS employees (
    Age                     INTEGER,
    Attrition               TEXT,          -- 'Yes' / 'No'
    BusinessTravel          TEXT,
    DailyRate                INTEGER,
    Department               TEXT,
    DistanceFromHome         INTEGER,
    Education                 INTEGER,
    EducationField            TEXT,
    EmployeeNumber            INTEGER PRIMARY KEY,
    EnvironmentSatisfaction   INTEGER,
    Gender                    TEXT,
    HourlyRate                INTEGER,
    JobInvolvement             INTEGER,
    JobLevel                   INTEGER,
    JobRole                    TEXT,
    JobSatisfaction            INTEGER,
    MaritalStatus               TEXT,
    MonthlyIncome                INTEGER,
    MonthlyRate                   INTEGER,
    NumCompaniesWorked             INTEGER,
    OverTime                        TEXT,
    PercentSalaryHike                INTEGER,
    PerformanceRating                 INTEGER,
    RelationshipSatisfaction           INTEGER,
    StockOptionLevel                    INTEGER,
    TotalWorkingYears                    INTEGER,
    TrainingTimesLastYear                 INTEGER,
    WorkLifeBalance                        INTEGER,
    YearsAtCompany                          INTEGER,
    YearsInCurrentRole                       INTEGER,
    YearsSinceLastPromotion                   INTEGER,
    YearsWithCurrManager                       INTEGER,
    AttritionFlag                               INTEGER   -- 1 = Left, 0 = Stayed
);


/* ---------------------------------------------------------------------
   1. OVERALL ATTRITION RATE
   --------------------------------------------------------------------- */
SELECT
    COUNT(*)                                   AS total_employees,
    SUM(AttritionFlag)                         AS employees_left,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees;


/* ---------------------------------------------------------------------
   2. ATTRITION RATE BY DEPARTMENT
   --------------------------------------------------------------------- */
SELECT
    Department,
    COUNT(*)                                        AS headcount,
    SUM(AttritionFlag)                               AS left_count,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY Department
ORDER BY attrition_rate_pct DESC;


/* ---------------------------------------------------------------------
   3. ATTRITION RATE BY JOB ROLE (Top risk roles first)
   --------------------------------------------------------------------- */
SELECT
    JobRole,
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY JobRole
ORDER BY attrition_rate_pct DESC;


/* ---------------------------------------------------------------------
   4. OVERTIME vs ATTRITION -- strongest single driver in this dataset
   --------------------------------------------------------------------- */
SELECT
    OverTime,
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY OverTime;


/* ---------------------------------------------------------------------
   5. INCOME COMPARISON: Employees who left vs stayed
   --------------------------------------------------------------------- */
SELECT
    Attrition,
    ROUND(AVG(MonthlyIncome), 0)   AS avg_monthly_income,
    ROUND(AVG(PercentSalaryHike),1) AS avg_salary_hike_pct
FROM employees
GROUP BY Attrition;


/* ---------------------------------------------------------------------
   6. AGE-BAND ATTRITION (younger employees more at risk?)
   --------------------------------------------------------------------- */
SELECT
    CASE
        WHEN Age < 25 THEN '18-24'
        WHEN Age < 35 THEN '25-34'
        WHEN Age < 45 THEN '35-44'
        WHEN Age < 55 THEN '45-54'
        ELSE '55+'
    END AS age_band,
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY age_band
ORDER BY age_band;


/* ---------------------------------------------------------------------
   7. TENURE BUCKETS -- Years at company vs attrition
   --------------------------------------------------------------------- */
SELECT
    CASE
        WHEN YearsAtCompany <= 1 THEN '0-1 yrs'
        WHEN YearsAtCompany <= 3 THEN '2-3 yrs'
        WHEN YearsAtCompany <= 5 THEN '4-5 yrs'
        WHEN YearsAtCompany <= 10 THEN '6-10 yrs'
        ELSE '10+ yrs'
    END AS tenure_band,
    COUNT(*)                                       AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY tenure_band
ORDER BY MIN(YearsAtCompany);


/* ---------------------------------------------------------------------
   8. JOB SATISFACTION SCORE vs ATTRITION
   --------------------------------------------------------------------- */
SELECT
    JobSatisfaction,          -- 1 (low) to 4 (high)
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;


/* ---------------------------------------------------------------------
   9. WORK-LIFE BALANCE vs ATTRITION
   --------------------------------------------------------------------- */
SELECT
    WorkLifeBalance,          -- 1 (bad) to 4 (best)
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;


/* ---------------------------------------------------------------------
   10. MARITAL STATUS vs ATTRITION
   --------------------------------------------------------------------- */
SELECT
    MaritalStatus,
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY MaritalStatus
ORDER BY attrition_rate_pct DESC;


/* ---------------------------------------------------------------------
   11. BUSINESS TRAVEL FREQUENCY vs ATTRITION
   --------------------------------------------------------------------- */
SELECT
    BusinessTravel,
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY BusinessTravel
ORDER BY attrition_rate_pct DESC;


/* ---------------------------------------------------------------------
   12. YEARS SINCE LAST PROMOTION -- stagnation risk
   --------------------------------------------------------------------- */
SELECT
    YearsSinceLastPromotion,
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY YearsSinceLastPromotion
ORDER BY YearsSinceLastPromotion;


/* ---------------------------------------------------------------------
   13. DEPARTMENT x OVERTIME interaction -- where's the biggest risk pocket?
   --------------------------------------------------------------------- */
SELECT
    Department,
    OverTime,
    COUNT(*)                                        AS headcount,
    ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2)  AS attrition_rate_pct
FROM employees
GROUP BY Department, OverTime
ORDER BY attrition_rate_pct DESC;


/* ---------------------------------------------------------------------
   14. TOP 10 HIGHEST-RISK PROFILE: high performers who left
       (useful to flag "regretted attrition" -- good performers walking out)
   --------------------------------------------------------------------- */
SELECT
    EmployeeNumber, JobRole, Department, PerformanceRating,
    MonthlyIncome, YearsAtCompany, OverTime, JobSatisfaction
FROM employees
WHERE Attrition = 'Yes' AND PerformanceRating >= 3
ORDER BY MonthlyIncome DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   15. RANK DEPARTMENTS BY ATTRITION RATE (window function)
       Note: RANK()/OVER works in SQLite 3.25+, MySQL 8+, PostgreSQL, SQL Server
   --------------------------------------------------------------------- */
SELECT
    Department,
    attrition_rate_pct,
    RANK() OVER (ORDER BY attrition_rate_pct DESC) AS risk_rank
FROM (
    SELECT
        Department,
        ROUND(100.0 * SUM(AttritionFlag) / COUNT(*), 2) AS attrition_rate_pct
    FROM employees
    GROUP BY Department
);


/* ---------------------------------------------------------------------
   16. EMPLOYEES CURRENTLY AT HIGH RISK (still employed but risk profile
       matches common attrition pattern: overtime + low satisfaction)
       -- useful "retention watchlist" for HR
   --------------------------------------------------------------------- */
SELECT
    EmployeeNumber, JobRole, Department, MonthlyIncome,
    JobSatisfaction, WorkLifeBalance, YearsAtCompany
FROM employees
WHERE Attrition = 'No'
  AND OverTime = 'Yes'
  AND JobSatisfaction <= 2
  AND WorkLifeBalance <= 2
ORDER BY YearsAtCompany DESC;
