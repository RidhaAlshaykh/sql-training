/*
    QUESTION TO ANSWER: what are the top most paying jobs posted for Business Analysts?
    -----------------------------------------------------------------------------------
    this query answers that question
*/
SELECT
    jobs.job_id,
    jobs.job_title,
    companies.name,
    jobs.job_location ,
    jobs.job_schedule_type,
    jobs.salary_year_avg,
    jobs.job_posted_date,
    companies.link_google as website

FROM job_postings_fact AS jobs

-- A left join to get the company names and websites
LEFT JOIN company_dim AS companies ON
    companies.company_id = jobs.company_id
WHERE
    jobs.salary_year_avg IS NOT NULL
    AND
    jobs.job_title LIKE '%Business%Analyst%'
    AND
    -- filter for remote jobs, they are labled as 'Anywhere', and loctions that are close, or locations of my own choice
    jobs.job_location LIKE ANY (ARRAY['Anywhere','%Saudi%Arabia%', '%Kuwait%', '%UAE%',
                                 '%Bahrain%', '%Oman%', '%Qatar%', '%Jordan%', '%Egypt%'])

ORDER BY
    jobs.salary_year_avg DESC

-- optional limit statment for only pulling the top 10
-- LIMIT 10
