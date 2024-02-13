USE kickstarter;
SET SQL_SAFE_UPDATES = 0;

# Inspect all the tables in the database
SELECT * 
FROM campaign;

SELECT * 
FROM category;

SELECT * 
FROM country;

SELECT * 
FROM currency;

SELECT *
FROM sub_category;


-- Data Cleaning

-- Handle Missing Values
# Get the number of missing values of each column in the `campaign` table
SELECT 
	COUNT(CASE WHEN id IS NULL THEN 1 END) AS num_missing_id,
    COUNT(CASE WHEN name  IS NULL THEN 1 END) AS num_missing_name,
	COUNT(CASE WHEN sub_category_id IS NULL THEN 1 END) AS num_missing_subcat,
    COUNT(CASE WHEN country_id IS NULL THEN 1 END) AS num_missing_country,
    COUNT(CASE WHEN launched IS NULL THEN 1 END) AS num_missing_launched,
    COUNT(CASE WHEN deadline IS NULL THEN 1 END) AS num_missing_deadline,
    COUNT(CASE WHEN goal IS NULL THEN 1 END) AS num_missing_goal,
    COUNT(CASE WHEN pledged IS NULL THEN 1 END) AS num_missing_pledged,
    COUNT(CASE WHEN backers IS NULL THEN 1 END) AS num_missing_backers,
    COUNT(CASE WHEN outcome IS NULL THEN 1 END) AS num_missing_outcome
FROM campaign;
# Perfect! There is no missing values in the table
    

--  Remove Duplicates
# Check if there is duplicated data in the `campaign` table
SELECT COUNT(DISTINCT id)
FROM campaign;

# Check duplicates at a more granular level
# I am adding a row number to each data, if the row_num is 2 means it is a duplicate
WITH duplicatesCTE AS(
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY name) AS row_num
	FROM campaign)
SELECT *
FROM duplicatesCTE
WHERE row_num > 1;

# Look at these duplicates
SELECT *
FROM campaign
WHERE name IN (
	'behind the mask',
    'cancelled (Canceled)',
	'Champions of Hara',
    'Chipembele Film Project',
    'New EP/Music Development',
    'Project cancelled (Canceled)',
    'Sausage Fest Travel',
    'The Gift',
    'Under the Sun');
# Even though these rows have duplicated names they are not necessarily duplicates, i.e. they are under different categories or different launch time
# I will keep them for now, we can treat them as different projects as long as they have unique IDs

# There are projects are of names like "Cancelled (Cancelled)", let's check if there is any other campaigns with such names
SELECT *
FROM campaign
WHERE name LIKE '%cancelled%'
	OR name LIKE '%canceled%'
    OR name LIKE '%successful%'
    OR name LIKE '%failed%'
    OR name LIKE '%undefined%';
    
SELECT DISTINCT outcome
FROM campaign
WHERE name LIKE '%cancelled%'
	OR name LIKE '%canceled%'
    OR name LIKE '%successful%'
    OR name LIKE '%failed%'
    OR name LIKE '%undefined%';
# Projects that have result-like names in their names are either cancelled or undefined, except "The 6th Papa Lemon Book: The First Successful Heart Surgery" and "Failed States, a journal of indeterminate geographies" but their names are valid


-- Correct Invalid Country Code
# After inspecting the tables, I noticed that country with id 11 is registered as N,0", this is invalid for a country code, let's replace them with valid country codes
 
# Get rows with "N,0"" in the country column
SELECT *
FROM campaign
WHERE country_id = 11;
# There are 155 rows this country code, but they all have valid currency_id, this is how we can impute the correct corresponding country code
 
# Get the distinct currency codes for country "N,0""
SELECT DISTINCT currency_id
FROM campaign
WHERE country_id = 11;

# Look at the countries that use currency 2
SELECT DISTINCT country_id
FROM campaign
WHERE currency_id = 2;
# Only US and N,0" use USD, so this N,0" code is most likely to be entry error. Let's replace N,0" with US

# Change country code to US
UPDATE campaign
SET country_id = 2
WHERE country_id = 11 AND currency_id = 2;

# Change the rest of country codes
SELECT DISTINCT country_id
FROM campaign
WHERE currency_id = 1;

UPDATE campaign
SET country_id = 1
WHERE country_id = 11 AND currency_id = 1;

SELECT DISTINCT country_id
FROM campaign
WHERE currency_id = 9;

UPDATE campaign
SET country_id = 15
WHERE country_id = 11 AND currency_id = 9;

SELECT DISTINCT country_id
FROM campaign
WHERE currency_id = 4;

UPDATE campaign
SET country_id = 4
WHERE country_id = 11 AND currency_id = 4;

SELECT DISTINCT country_id
FROM campaign
WHERE currency_id = 3;

UPDATE campaign
SET country_id = 3
WHERE country_id = 11 AND currency_id = 3;

SELECT DISTINCT country_id
FROM campaign
WHERE currency_id = 6;
# There are several countries use EUR, I will impute it with the most frequent country

# Get the most frequent country that use EUR
SELECT 
	country_id,
	COUNT(*) AS frequency
FROM campaign
WHERE currency_id = 6
GROUP BY country_id
ORDER BY frequency DESC
LIMIT 1;

# Impute with country_id 7
UPDATE campaign
SET country_id = 7
WHERE country_id = 11 AND currency_id = 6;

SELECT DISTINCT country_id
FROM campaign
WHERE currency_id = 10;

UPDATE campaign
SET country_id = 16
WHERE country_id = 11 AND currency_id = 10;

SELECT DISTINCT country_id
FROM campaign
WHERE currency_id = 8;

UPDATE campaign
SET country_id = 12
WHERE country_id = 11 AND currency_id = 8;

# Check
SELECT *
FROM campaign
WHERE country_id = 11;


-- Convert Currency
# Aggregate financial figures by currency
SELECT 
	cu.name, 
    AVG(c.goal) AS avg_goal, 
    AVG(c.pledged) AS avg_pledged
FROM campaign c
LEFT JOIN currency cu
ON c.currency_id = cu.id
GROUP BY  currency_id;
# The most significant disparities are seen in the European campaigns, for this project I will convert all the currencies to USD

# Update `campaign` with converted financial figures
UPDATE campaign
SET
	goal = CASE
				WHEN currency_id = 1 THEN goal * 1.27
                WHEN currency_id = 3 THEN goal * 0.74
                WHEN currency_id = 4 THEN goal * 0.66
                WHEN currency_id = 5 THEN goal * 0.095
                WHEN currency_id = 6 THEN goal * 1.08
                WHEN currency_id = 7 THEN goal * 0.058
                WHEN currency_id = 8 THEN goal * 0.096
                WHEN currency_id = 9 THEN goal * 0.61
                WHEN currency_id = 10 THEN goal * 1.16
                WHEN currency_id = 11 THEN goal * 0.15
                WHEN currency_id = 12 THEN goal * 0.13
                WHEN currency_id = 13 THEN goal * 0.75
                WHEN currency_id = 14 THEN goal * 0.0068
                ELSE goal
			END,
	pledged = CASE
				WHEN currency_id = 1 THEN pledged * 1.27
                WHEN currency_id = 3 THEN pledged * 0.74
                WHEN currency_id = 4 THEN pledged * 0.66
                WHEN currency_id = 5 THEN pledged * 0.095
                WHEN currency_id = 6 THEN pledged * 1.08
                WHEN currency_id = 7 THEN pledged * 0.058
                WHEN currency_id = 8 THEN pledged * 0.096
                WHEN currency_id = 9 THEN pledged * 0.61
                WHEN currency_id = 10 THEN pledged * 1.16
                WHEN currency_id = 11 THEN pledged * 0.15
                WHEN currency_id = 12 THEN pledged * 0.13
                WHEN currency_id = 13 THEN pledged * 0.75
                WHEN currency_id = 14 THEN pledged * 0.0068
                ELSE pledged
			END;
		
UPDATE campaign
SET goal = ROUND(goal,2),
	pledged = ROUND(pledged,2);


-- Convert Data Types

DESCRIBE campaign;
# `name` and `outcome` are of data type text, they could be converted to VARCHAR that are more suitable for queries

# Get the greatest length of strings in the two columns
SELECT MAX(LENGTH(name)) AS count_of_chars_name,
	   MAX(LENGTH(outcome)) AS count_of_chars_outcome
FROM campaign;

# Assign the new data type to this column
ALTER TABLE campaign
MODIFY name VARCHAR(100);

ALTER TABLE campaign
MODIFY outcome VARCHAR(10);

# The datetime data in `launched` and `deadline` columns have 00:00:00 time stamps, they are redundant should be dropped
# We can do this by simply convert the columns to date data type
ALTER TABLE campaign
MODIFY launched Date;

ALTER TABLE campaign
MODIFY deadline Date;

# Check
DESCRIBE campaign;

SELECT *
FROM campaign;


-- Handle Anomalies
# Get amount pledged per backer
SELECT 
	id, 
	name,
    outcome,
    pledged,
    backers,
    (pledged/backers) AS pledged_per_backer
FROM campaign
ORDER BY pledged_per_backer DESC;

# Campaigns with recorded pledged fundings and 0 backers
SELECT 
	id, 
	name,
    outcome,
    pledged,
    backers,
    (pledged/backers) AS pledged_per_backer
FROM campaign
WHERE backers = 0 AND pledged <> 0
ORDER BY pledged_per_backer DESC;
# There are 136 projects had 0 backers but rasied money from the campaigns, they can skew our analysis and should be dropped

# Drop these anomalies
DELETE FROM campaign
WHERE backers = 0 AND pledged <> 0;




-- Data Exploration

# For this project, my focus will be solely on projects with defined outcomes, specifically those categorized as 'successful' and 'failed'. I will exclude projects with any other types of outcomes
# Drop canceled, undefined, suspended, and live campaigns
SELECT outcome,
	COUNT(*) AS total_count
FROM campaign
GROUP BY outcome;

DELETE FROM campaign
WHERE outcome IN ('canceled','suspended','undefined','live');


-- Which categories and subcategories have the highest success rate?
# Create a table that joins categories and subcategories
DROP TABLE IF EXISTS cat_subcat; 
CREATE TABLE cat_subcat AS
SELECT 
	s.id,
    s.name AS subcategory,
    c.name AS category
FROM sub_category s
JOIN category c
ON s.category_id = c.id;
    
SELECT *
FROM cat_subcat;
	
# Get success and fail rate for each category and subcategory
SELECT 
	cs.category,
    SUM(CASE WHEN
				c.outcome = 'successful' THEN 1 
                ELSE k
                END) AS total_success,
	SUM(CASE WHEN
				c.outcome = 'failed' THEN 1 
                ELSE 0
                END) AS total_fail,
	ROUND(SUM(CASE WHEN
				c.outcome = 'successful' THEN 1 
                ELSE 0
                END)/COUNT(c.outcome) * 100,2) AS success_rate,
	ROUND(SUM(CASE WHEN
				c.outcome = 'failed' THEN 1 
                ELSE 0
                END)/COUNT(c.outcome) * 100,2) AS fail_rate
FROM campaign c
JOIN cat_subcat cs
ON c.sub_category_id = cs.id
GROUP BY cs.category;
	
# Do the same for subcategories
SELECT 
	cs.subcategory,
    SUM(CASE WHEN
				c.outcome = 'successful' THEN 1 
                ELSE 0
                END) AS total_success,
	SUM(CASE WHEN
				c.outcome = 'failed' THEN 1 
                ELSE 0
                END) AS total_fail,
	ROUND(SUM(CASE WHEN
				c.outcome = 'successful' THEN 1 
                ELSE 0
                END)/COUNT(c.outcome) * 100,2) AS success_rate,
	ROUND(SUM(CASE WHEN
				c.outcome = 'failed' THEN 1 
                ELSE 0
                END)/COUNT(c.outcome) * 100,2) AS fail_rate
FROM campaign c
JOIN cat_subcat cs
ON c.sub_category_id = cs.id
GROUP BY cs.subcategory;
# Note that some subcategories have a very low total campaigns, for this could skew the analysis. Let's set a threshold for the total number of campaigns

# Set threshold of 10 total campaigns
SELECT 
	cs.subcategory,
    SUM(CASE WHEN
				c.outcome = 'successful' THEN 1 
                ELSE 0
                END) AS total_success,
	SUM(CASE WHEN
				c.outcome = 'failed' THEN 1 
                ELSE 0
                END) AS total_fail,
	ROUND(SUM(CASE WHEN
				c.outcome = 'successful' THEN 1 
                ELSE 0
                END)/COUNT(c.outcome) * 100,2) AS success_rate,
	ROUND(SUM(CASE WHEN
				c.outcome = 'failed' THEN 1 
                ELSE 0
                END)/COUNT(c.outcome) * 100,2) AS fail_rate
FROM campaign c
JOIN cat_subcat cs
ON c.sub_category_id = cs.id
GROUP BY cs.subcategory
HAVING total_success+total_fail >= 10;

# For category: Dance has the highest success rate of 67.77% followed by Comics and Theater both consists 61% success rate. While Technology has the highest fail rate of 77.18% followed by Fashion 71.58% and Journalism 71.56%
# For subcategory: Webcomics has the highest succee rate of 94.74%, Anthologies comes to second with 80% success rate. All Candles campaigns failed.


-- Campaigns over the Years
WITH campaign_over_yearsCTE AS (
  SELECT
    YEAR(launched) AS launch_year,
    COUNT(*) AS total_campaigns,
    COUNT(CASE WHEN outcome = 'successful' THEN 1 END) AS total_success,
    COUNT(CASE WHEN outcome = 'failed' THEN 1 END) AS total_fail,
    ROUND(COUNT(CASE WHEN outcome = 'successful' THEN 1 END) * 100.0 / COUNT(*), 2) AS success_rate,
    ROUND(COUNT(CASE WHEN outcome = 'failed' THEN 1 END) * 100.0 / COUNT(*), 2) AS fail_rate
  FROM campaign
  GROUP BY YEAR(launched)
  ORDER BY YEAR(launched)
  )
SELECT
  launch_year,
  total_campaigns,
  total_campaigns - LAG(total_campaigns, 1) 
	OVER (ORDER BY launch_year) AS yoy_total_campaigns,  # get year-over-year change of the total number of campaigns
  total_success,
  total_fail,
  success_rate,
  fail_rate,
  success_rate - LAG(success_rate, 1)
	OVER (ORDER BY launch_year) AS yoy_success_rate  # get year-over-year change of the success rate
FROM campaign_over_yearsCTE
ORDER BY launch_year;

# Growth in Campaigns: There's a noticeable increase in the total number of campaigns from 52 in 2009 to 1669 in 2017. This shows a significant escalation in activities over the years, indicating an expanding effort or market
# Success Rates: The success rate fluctuates year-over-year but shows a general trend of decrease when comparing the earliest and latest years provided (55.77% in 2009 to 43.74% in 2017). This could suggest that as the number of campaigns increases, maintaining high success rates becomes more challenging


-- Outcome and Campaign Duration
# Dividing the duration into different duration brakcets, and calculate the success rate for each bracket
SELECT 
	ROUND(SUM(CASE 
		WHEN DATEDIFF(deadline,launched) BETWEEN 1 AND 30 AND outcome = 'successful' THEN 1 ELSE 0 END)/
		COUNT(CASE WHEN DATEDIFF(deadline,launched) BETWEEN 1 AND 30 THEN 1 END) * 100,2) AS '1-30 days',
	ROUND(SUM(CASE 
		WHEN DATEDIFF(deadline,launched) BETWEEN 31 AND 60 AND outcome = 'successful' THEN 1 ELSE 0 END)/
        COUNT(CASE WHEN DATEDIFF(deadline,launched) BETWEEN 31 AND 60 THEN 1 END) * 100,2) AS '31-60 days',
    ROUND(SUM(CASE 
		WHEN DATEDIFF(deadline,launched) > 60 AND outcome = 'successful' THEN 1 ELSE 0 END)/
        COUNT(CASE WHEN DATEDIFF(deadline,launched) > 60 THEN 1 END) * 100,2) AS '61+ days'
	FROM campaign;

# Campaigns that last longer than 60 days see an increase in success rate to 44.6%,  this indicates that longer campaigns, those extending beyond two months, have a higher likelihood of success. This could be due to several factors, such as more time to reach and expand their target audience, more opportunities for marketing and promotion, or possibly the nature of the campaign itself requiring a longer timeframe to achieve its goals


-- Categories/Subcategories and Duration
SELECT 
	cs.category,
	ROUND(AVG(DATEDIFF(c.deadline,launched)),2) AS average_duration_days
FROM campaign c
JOIN cat_subcat cs
ON c.sub_category_id = cs.id
GROUP BY cs.categorykick
ORDER BY average_duration_days DESC;
    
SELECT 
	cs.subcategory,
	ROUND(AVG(DATEDIFF(c.deadline,launched)),2) AS average_duration_days
FROM campaign c
JOIN cat_subcat cs
ON c.sub_category_id = cs.id
GROUP BY cs.subcategory
ORDER BY average_duration_days DESC;

# Music has the longest campaigns with an average duration of 35.7 days, crafts campaigns on average have shorest duration of 31.62 days
# Typography has the longest average duration of 57 days, followed by translation with 52.5 days on average. Stationary has the shortest duration of only 20.75 days
# Building upon our earlier analysis of success rates across different categories and subcategories, we see no linear relationship or correlation between campaign duration and success rate


-- Goal and Duration
# Calculating the average goal set by projects with different durations
SELECT 
	CASE 
		WHEN DATEDIFF(deadline,launched) BETWEEN 1 AND 30 THEN '1-30 days'
		WHEN DATEDIFF(deadline,launched) BETWEEN 31 AND 60 THEN '31-60 days'
		WHEN DATEDIFF(deadline,launched) > 60 THEN '61+ days'
		END AS duration,
	ROUND(AVG(goal),2) AS average_goal
FROM campaign
GROUP BY duration;
# Campaigns lasted between 31 and 60 days on average set their goals higher about $75619, and those lasted longer than 61 days set a drastic lower goal
# In conjunction with the previous analysis of success rate and duration, it appears that longer campaigns tend to have higher success rate may be attributed to lower funding goals


-- Pledged and Duration
# Calculating the average amount pledged by durations
SELECT 
	CASE 
		WHEN DATEDIFF(deadline,launched) BETWEEN 1 AND 30 THEN '1-30 days'
		WHEN DATEDIFF(deadline,launched) BETWEEN 31 AND 60 THEN '31-60 days'
		WHEN DATEDIFF(deadline,launched) > 60 THEN '61+ days'
		END AS duration,
	ROUND(AVG(pledged),2) AS average_pledged
FROM campaign
GROUP BY duration;
# Campaigns ran between 31 and 60 days pledged most money from the backers about $14814

 
 -- Backers and Duration
 # Calculating the average number of backers by durations
 SELECT 
	CASE 
		WHEN DATEDIFF(deadline,launched) BETWEEN 1 AND 30 THEN '1-30 days'
		WHEN DATEDIFF(deadline,launched) BETWEEN 31 AND 60 THEN '31-60 days'
		WHEN DATEDIFF(deadline,launched) > 60 THEN '61+ days'
		END AS duration,
	ROUND(AVG(backers),2) AS average_backers
FROM campaign
GROUP BY duration;  
# Campaigns that ran up to one month ginpower vbiained 103 backers in average this number increases to 168 for the ones that lastes between 31 days and 60 days. Surprisingly campaigns that lasted more than 2 months had less backers only 51 in average

	 
-- Goal(USD) and Outcome
# Count the number of campaigns for each outcome
SELECT 
	outcome,
	COUNT(*) AS total_count
FROM campaign
GROUP BY outcome;
# The majority of campaigns have outcomes of either 'failed' or 'successful'
# For this project we only focus on the campaigns with these two outcomes

# Aggregate goal in USD by outcome
SELECT 
	outcome,
	ROUND(SUM(goal),2) AS total_goal,
    ROUND(AVG(goal),2) AS average_goal
FROM campaign
GROUP BY outcome;
# On average, campaigns that failed had set their goals approximately 10 times higher than those that were successful
# The goals set by the two groups differ significantly, it is worth for a deeper look
# I'm querying a table that showcases the success rate for each goal bracket

# First, look at the statistical attributes of the goal column
SELECT
	COUNT(*) AS total_count,
	MIN(goal) AS min_goal,
    MAX(goal) AS max_goal,
    AVG(goal) AS average_goal
FROM campaign;

# Get success rate of each goal bracket
SELECT
	CASE 
		WHEN goal <= 10000 THEN "0-10k"
		WHEN goal > 10000 AND goal <= 20000 THEN "10k-20k"
        WHEN goal > 20000 AND goal <= 30000 THEN "20k-30k"
        WHEN goal > 30000 AND goal <= 40000 THEN "30k-40k"
        WHEN goal > 40000 AND goal <= 50000 THEN "40k-50k"
        WHEN goal > 50000 AND goal <= 60000 THEN "50k-60k"
        WHEN goal > 60000 THEN "60k+"
        END AS goal_bracket,
	ROUND(COUNT(CASE WHEN outcome='successful' THEN 1 END)/COUNT(*)*100,2) AS success_rate
FROM campaign
GROUP BY goal_bracket
ORDER BY goal_bracket;
# 0-10k group has the highest success rate, it drastically drops when the goal increases


-- Pledged(USD) and Outcome
# Aggregate pledged in USD by outcomes
SELECT 
	outcome,
	ROUND(SUM(pledged),2) AS total_pledged,
	ROUND(AVG(pledged),2) AS average_pledged
FROM campaign
GROUP BY outcome;
# Total of 125521367.37 and average of 23598.68 dollars were raised for successful campaigns
# Total of 11735283.82 and average of 1494.94 dollars were raised for failed campaigns
SELECT COUNT(DISTINCT name)
FROM campaign;

-- Backers and Outcome
SELECT 
	outcome,
    SUM(backers) AS total_backers,
    ROUND(AVG(backers),2) AS average_backers
FROM campaign
GROUP BY outcome;
# Failed campaigns had only 17.74 backers in average, while successful ones pledged money from 282.52 backers

# Average amount pledged per backer by outcome
SELECT 
	outcome,
    SUM(backers) AS total_backers,
    ROUND(AVG(backers),2) AS average_backers,
    ROUND(SUM(pledged)/SUM(backers),2) AS pledged_per_backer
FROM campaign
GROUP BY outcome;
# Amount of money raised per backer for each outcome is almost indifferent


-- Country and Outcome 
SELECT
	co.name AS country,
    COUNT(*) AS total_campaigns,
    COUNT(CASE WHEN c.outcome = 'successful' THEN 1 END) AS total_success,
    COUNT(CASE WHEN c.outcome = 'failed' THEN 1 END) AS total_fail,
    ROUND(COUNT(CASE WHEN c.outcome = 'successful' THEN 1 END)/COUNT(*)*100,2) AS success_rate
FROM campaign c
JOIN country co
ON c.country_id = co.id
GROUP BY co.name
ORDER BY success_rate DESC;
# US has the largest total number of campaigns (4365), Luxembourg (LU) has only 3 in total, the market was greatly dominated by US projects
# Luxembourg (LU) has a high succcess rate (66.67%) with just 3 total number of campaigns
# Norway (NO), Denmark (DK), Singapore (SG) have moderate activity levels, with 44.44% success rate
# Great Britain (GB) has high activity level with 1156 total number of campaigns and a success rate of 42.13%


-- Country and Categories/Subcategories
SELECT
	co.name AS country,
    cs.category,
    COUNT(*) AS total_campaigns,
    ROUND(COUNT(CASE WHEN c.outcome='successful' THEN 1 END)/COUNT(*)*100,2) AS success_rate
FROM campaign c
JOIN cat_subcat cs 
ON c.sub_category_id = cs.id
JOIN country co 
ON c.country_id = co.id
GROUP BY 
	co.name,
    cs.category
ORDER BY country, success_rate DESC;

SELECT
	co.name AS country,
    cs.subcategory,
    cs.category,
    COUNT(*) AS total_campaigns,
    ROUND(COUNT(CASE WHEN c.outcome='successful' THEN 1 END)/COUNT(*)*100,2) AS success_rate
FROM campaign c
JOIN cat_subcat cs 
ON c.sub_category_id = cs.id
JOIN country co 
ON c.country_id = co.id
GROUP BY 
	co.name,
    cs.subcategory,
    cs.category
ORDER BY country, success_rate DESC;


select *
from campaign
where goal<=pledged AND outcome='failed';