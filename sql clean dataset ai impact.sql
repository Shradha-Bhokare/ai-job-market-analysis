CREATE DATABASE ai_project;
USE ai_project;

CREATE TABLE ai_jobs (
    posting_year INT,
    industry VARCHAR(150),
    job_title VARCHAR(200),
    ai_intensity_score FLOAT,
    salary_usd FLOAT,
    salary_change_vs_prev_year_percent FLOAT,
    automation_risk_score FLOAT,
    ai_job_displacement_risk VARCHAR(20),
    industry_ai_adoption_stage VARCHAR(50),
    reskilling_required VARCHAR(10),
    ai_keywords TEXT,
    ai_skills TEXT
);
SELECT COUNT(*) FROM ai_impact_jobs_2010_2025;

SELECT 
    COUNT(*) AS total_rows,               # for check nulls
    COUNT(job_id) AS job_id_count,
    COUNT(posting_year) AS year_count,
    COUNT(salary_usd) AS salary_count,
    COUNT(automation_risk_score) AS risk_score_count
FROM ai_impact_jobs_2010_2025;

SELECT job_id, COUNT(*)               # check for duplicates
FROM ai_impact_jobs_2010_2025
GROUP BY job_id
HAVING COUNT(*) > 1;

SELECT 
    MIN(salary_usd) AS min_salary,
    MAX(salary_usd) AS max_salary,
    AVG(salary_usd) AS avg_salary
FROM ai_impact_jobs_2010_2025;

SELECT 
    MIN(automation_risk_score),
    MAX(automation_risk_score)
FROM ai_impact_jobs_2010_2025;

SELECT 
    MIN(posting_year),
    MAX(posting_year)
FROM ai_impact_jobs_2010_2025;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(job_id) AS job_id_count,
    COUNT(posting_year) AS year_count,
    COUNT(salary_usd) AS salary_count,
    COUNT(automation_risk_score) AS risk_score_count,
    COUNT(industry_ai_adoption_stage) AS adoption_stage_count
FROM ai_impact_jobs_2010_2025;

SELECT                               
    job_id,                           # for creating automation risk column
    automation_risk_score,
    CASE  
        WHEN automation_risk_score < 0.4 THEN 'Low Risk'
        WHEN automation_risk_score BETWEEN 0.4 AND 0.7 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_category
FROM ai_impact_jobs_2010_2025;

ALTER TABLE ai_impact_jobs_2010_2025
ADD COLUMN risk_category VARCHAR(20);

SET SQL_SAFE_UPDATES = 0;   # this for when you not using where clause it gives error so thats why 
                              # update mode on
UPDATE ai_impact_jobs_2010_2025
SET risk_category = 
    CASE 
        WHEN automation_risk_score < 0.4 THEN 'Low Risk'
        WHEN automation_risk_score BETWEEN 0.4 AND 0.7 THEN 'Medium Risk'
        ELSE 'High Risk'
    END;
    SET SQL_SAFE_UPDATES = 1;  # update mode off
    
    SELECT risk_category, COUNT(*)     # check for risk score
FROM ai_impact_jobs_2010_2025
GROUP BY risk_category;     


SELECT industry, risk_category, COUNT(*) AS total_jobs      # Which industries have highest high-risk jobs.
FROM ai_impact_jobs_2010_2025
GROUP BY industry, risk_category
ORDER BY industry, total_jobs DESC;

SELECT risk_category,
       ROUND(AVG(salary_usd), 2) AS avg_salary      #This will show:Are high-risk jobs paid less? Or more?
FROM ai_impact_jobs_2010_2025
GROUP BY risk_category;

SELECT posting_year, risk_category, COUNT(*) AS total    #Is High Risk increasing over time?
FROM ai_impact_jobs_2010_2025
GROUP BY posting_year, risk_category
ORDER BY posting_year;

SELECT risk_category,
       ROUND(AVG(salary_usd),2) AS avg_salary   # Are low-risk jobs paying more?
FROM ai_impact_jobs_2010_2025
GROUP BY risk_category;

SELECT 
    posting_year,           # insted of count lets cal by percetang
    risk_category,
    COUNT(*) AS total_jobs,
    ROUND(
        COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER (PARTITION BY posting_year),
        2
    ) AS percentage_per_year
FROM ai_impact_jobs_2010_2025
GROUP BY posting_year, risk_category
ORDER BY posting_year;