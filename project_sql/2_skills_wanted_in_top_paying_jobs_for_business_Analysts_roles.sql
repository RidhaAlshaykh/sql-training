SELECT
    jobs.job_id,
    jobs.job_title,
    companies.name,
    jobs.job_location ,
    jobs.job_schedule_type,
    jobs.salary_year_avg,
    jobs.job_posted_date,
    skills_dim.skills,
    companies.link_google as website

FROM job_postings_fact AS jobs

-- A left join to get the company names and websites
LEFT JOIN company_dim AS companies ON
    companies.company_id = jobs.company_id

-- innner joins to get the name of the skills
INNER JOIN skills_job_dim ON
    skills_job_dim.job_id = jobs.job_id
INNER JOIN skills_dim ON
    skills_dim.skill_id = skills_job_dim.skill_id
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

-- a limit to get the top 10, i see it as something optional
-- LIMIT 10