/*
    QUESTION TO ANSWER: what are the top skills based on salaries?
    i used the inter-quartile range (IQR) for the conparisons, i believe it is more accurate than using the average for comparisons,
    since the IQR is the middle 50% of a set of values
*/


SELECT
    skills_dim.skills,
    COUNT(skills_job_dim.skill_id),
    (
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) - 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC)
    ) AS salary_iqr,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) AS median_salary
FROM job_postings_fact as jobs
inner join skills_job_dim on skills_job_dim.job_id = jobs.job_id
inner join skills_dim on skills_dim.skill_id = skills_job_dim.skill_id

WHERE
    jobs.salary_year_avg IS NOT NULL AND 
    jobs.job_title LIKE '%Business%Analyst%'

GROUP BY 
    skills_dim.skills


-- ordering by the medain + the iqr
ORDER BY 
   (
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) - 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC)
    ) + PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) DESC

-- a limit expression to pull the top 5, 10, 15, 20, or any amount of values you want, i prefer pulling everything
-- LIMIT 20