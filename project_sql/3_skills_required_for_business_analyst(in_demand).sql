/*
    QUESTION TO ANSWER: what are the skills reuired for a Business Analyst?
    we are going to use counts for each skill as the metric for the demand
*/

-- a CTE using a similar query to the first query, pulling the top paying jobs


SELECT
    skills_dim.skills AS skill_name,
    COUNT(skills_job_dim.skill_id) AS skill_counts

FROM
    skills_job_dim

INNER JOIN skills_dim ON
    skills_job_dim.skill_id = skills_dim.skill_id
LEFT JOIN job_postings_fact as jobs ON
    jobs.job_id = skills_job_dim.job_id

WHERE
    jobs.job_title LIKE '%Business%Analyst%'
    AND
    -- filter for remote jobs, they are labled as 'Anywhere', and loctions that are close, or locations of my own choice
    jobs.job_location LIKE ANY (ARRAY['Anywhere','%Saudi%Arabia%', '%Kuwait%', '%UAE%',
                                 '%Bahrain%', '%Oman%', '%Qatar%', '%Jordan%', '%Egypt%'])

GROUP BY
    skills_dim.skills

ORDER BY
    COUNT(skills_job_dim.skill_id) DESC


