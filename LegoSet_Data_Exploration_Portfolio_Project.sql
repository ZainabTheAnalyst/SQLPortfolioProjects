/*        Lego Set Explanatory Analysis 
This report provides an overview of the Lego sets and its history, 
highlighting trends in set releases, parts, as well as color usage.*/


SELECT * FROM themes;
SELECT * FROM sets;
SELECT * FROM inventories;
SELECT * FROM inventory_parts;
SELECT * FROM parts;
SELECT * FROM colors;

--1. What is the total number of parts per theme?
SELECT 
      t.name AS theme,
      SUM(cast(s.num_parts as numeric)) AS total_no_of_parts
FROM sets s
LEFT JOIN themes t ON s.theme_id = t.id
GROUP BY t.name
ORDER BY 2 DESC; -- Technic, Star Wars & Friends are top 3 themes with highest number of parts 

-- 2. What is the total number of parts per year? 

SELECT 
      s.year,
      SUM(cast(s.num_parts as numeric)) AS total_no_of_parts
FROM sets s
GROUP BY s.year
ORDER BY 2 DESC; -- Top 5 years with the most number of parts are 2022, 2021, 2020, 2019, 2017.

-- 3. What is the average number of Lego sets released per year?
SELECT 
      year,
	  AVG(total_sets) AS avg_no_of_sets
FROM(SELECT 
            year, COUNT(set_num) AS total_sets
	 FROM sets
	 GROUP BY year) sets_by_year
GROUP BY year
ORDER BY 1 DESC; -- Fairly consistent increase in the no. of sets released per year since 2016.


-- 4. How many lego sets were released in each century? 

SELECT 
    CASE 
	    WHEN year BETWEEN 1901 AND 2000 THEN '20th_Century'
		WHEN year BETWEEN 2001 AND 2100 THEN '21st_Century'
    END AS Century,
    COUNT(set_num) as Total_sets
FROM sets
GROUP BY CASE 
	    WHEN year BETWEEN 1901 AND 2000 THEN '20th_Century'
		WHEN year BETWEEN 2001 AND 2100 THEN '21st_Century'
    END; -- 15,608 Sets in 21st Century & 4995 Sets in 20th Century.

-- 5. What percentage of sets ever released in 21st Century were Harry Potter themed? 
CREATE VIEW set_themes_view AS

SELECT 
       s.set_num, 
	   s.name as set_name, 
	   s.year, s.theme_id, 
	   CAST(s.num_parts AS numeric) num_parts, 
	   t.name as theme_name,
       CASE
	       WHEN s.year BETWEEN 1901 AND 2000 THEN '20th_Century'
	       WHEN s.year BETWEEN 2001 AND 2100 THEN '21st_Century'
	END AS Century
FROM sets s
LEFT JOIN themes t
	ON s.theme_id = t.id;


 WITH Century_sets_cte AS(

 SELECT
      Century,
      theme_name,
	  COUNT(set_num) AS total_sets
FROM set_themes_view
WHERE Century = '21st_Century'
GROUP BY Century,theme_name)

SELECT
      SUM(percentage) -- Cause there were 3 diff Harry Potter themes 
FROM(SELECT 
           Century, 
		   theme_name, 
		   total_sets, 
		   SUM(total_sets) OVER() as sum_total_sets, 
		   CAST(1.00 * total_sets/SUM(total_sets) OVER() AS DECIMAL (5,4))*100 Percentage
	from Century_sets_cte) new
WHERE theme_name LIKE '%harry potter%'; -- 1.2% of sets released in 21st century were Harry Potter themed.

-- 6. What was the popular theme by year in 21st Century?

SELECT * 
FROM set_themes_view;

SELECT
      year,
	  theme_name,
	  total_sets
FROM
(SELECT
      year, 
	  theme_name,
	  COUNT(set_num) AS total_sets,
	  ROW_NUMBER() OVER(PARTITION BY year ORDER BY COUNT(set_num)DESC) AS rank -- to rank the themes based on highest count
FROM set_themes_view 
WHERE Century = '21st_Century'
GROUP BY year, theme_name
) AS theme_ranked
WHERE rank = 1
ORDER BY year DESC; -- Star Wars & Bionicle seem to the two most popular themes as they had highest number of sets in multiple years.

--7. What is the most produced color of lego in terms of quantity of parts? 

SELECT
       color_name, 
	   SUM(quantity) as quantity_of_parts
FROM 
	(SELECT
	       c.name as color_name,
		   CAST(inv.quantity as numeric) quantity
	  FROM inventory_parts inv
	  INNER JOIN colors c
			on inv.color_id = c.id) AS color_qty
GROUP BY color_name
ORDER BY 2 DESC; -- Black is the most produced Lego color with 691,002 number of parts produced while Rust Orange is the least produced color.




