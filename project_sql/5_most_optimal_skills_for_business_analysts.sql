/*
    -QUESTION TO ANSWER: what are the most optimal skills for business analysts?
    a ranking of of skills based on their salary IQR and median with the counts of each skill
*/

WITH demanded_skills AS (
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

    ),

highest_pay_skills AS (
        
    SELECT
        skills_dim.skills AS skill_name,
        COUNT(skills_job_dim.skill_id),
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) AS first_quarter,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) AS third_quarter,
        (
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) - 
            PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC)
        )AS salary_iqr,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) AS median_salary

        FROM 
            job_postings_fact as jobs
            
        inner join skills_job_dim on skills_job_dim.job_id = jobs.job_id
        inner join skills_dim on skills_dim.skill_id = skills_job_dim.skill_id

        WHERE
            jobs.salary_year_avg IS NOT NULL AND 
            jobs.job_title LIKE '%Business%Analyst%'

        GROUP BY 
            skills_dim.skills


        -- ordering by the lowest IQR. i fucosed more on the low dispersion of salaries,
        -- the higher the IQR, the larger the range of the of salaries
        ORDER BY 
        (
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC) - 
            PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY jobs.salary_year_avg ASC)
            ) ASC

        -- a limit expression to pull the top 5, 10, 15, 20, or any amount of values you want, i prefer pulling everything
        -- LIMIT 20
    ),

optimal_skills AS(

    SELECT demanded_skills.skill_name AS skill_name

    FROM
        demanded_skills

LEFT JOIN highest_pay_skills on
    demanded_skills.skill_name = highest_pay_skills.skill_name

    WHERE 
        demanded_skills.skill_counts > 100
        AND
        (highest_pay_skills.salary_iqr + highest_pay_skills.median_salary) >= 100000

GROUP BY demanded_skills.skill_name


)

SELECT
    optimal_skills.skill_name,
    demanded_skills.skill_counts,
    highest_pay_skills.first_quarter,
    highest_pay_skills.median_salary,
    highest_pay_skills.third_quarter,
    highest_pay_skills.salary_iqr


FROM
    optimal_skills

INNER JOIN demanded_skills on
    demanded_skills.skill_name = optimal_skills.skill_name
INNER JOIN highest_pay_skills ON
    highest_pay_skills.skill_name = demanded_skills.skill_name

