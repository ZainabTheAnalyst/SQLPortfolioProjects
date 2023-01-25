/* MAVEN MOVIE RENTALS 
THE SITUATION: A new client, the owner of Maven Movies DVD rental business, has reached out fo help restructuring their non normalized data.alter

THE OBJECTIVE: Use MySQL Database Administration skills to:
Design a better set of tables to store data in existing schema. Explain the owner why the current system is not optimized for scale , and how you propose to improve it.
Then create a new schema with with you  ideal specifications and populate it.*/

/* Q1. Take a look at the mavenmoviesmini schema. What do you notice about it? 
How many tables are there? What does the data represent? What do you think about the current schema?*/

USE mavenmoviesmini;
SELECT * FROM inventory_non_normalized;
/* ANS: The current is schema is very simple with only one table with all the data recorded in it. 
The current schema is very inefficient & redundant as the values are repeating over and over.*/


/* Q2. If you wanted to break out the data from the inventory_non_normalized table into multiple tables, how many tables do you think would be ideal?
What woiuld you name those tables?*/

/* ANS: I will break it down into 3 tables;
inventory(inventory_id, film_id, store_id)
film(film_id, title, description, release_year,rental_rate,rating)
store(store_id, store_manager_first_name, store_manager_last_name, store_address, store_city, store_district)*/

/* Q3. Based on your answer from Q2., create a new schema with the tables you think will best serve this data set.*/

CREATE SCHEMA mavenmoviesmini_normalized;
USE mavenmoviesmini_normalized;
CREATE TABLE inventory_normalized (
inventory_id INT NOT NULL,
film_id INT NOT NULL,
store_id INT NOT NULL,
PRIMARY KEY (inventory_id)
);

CREATE TABLE film_normalized (
film_id INT NOT NULL,
title VARCHAR(255) NOT NULL,
description VARCHAR(255) NOT NULL,
release_year INT NOT NULL,
rental_rate DECIMAL(6,2) NOT NULL,
rating VARCHAR(50) NOT NULL,
PRIMARY KEY (film_id)
);

CREATE TABLE store_normalized (
store_id INT NOT NULL,
store_manager_first_name VARCHAR(50) NOT NULL,
store_manager_last_name VARCHAR(50) NOT NULL,
store_address VARCHAR(250) NOT NULL,
store_city VARCHAR(50) NOT NULL,
store_district VARCHAR(50) NOT NULL,
PRIMARY KEY (store_id)
);

/* Q4. Use the data from original schema to populate the tables in your newly optimized schema*/

INSERT INTO inventory_normalized(inventory_id, film_id, store_id)
SELECT DISTINCT inventory_id, film_id, store_id
FROM mavenmoviesmini.inventory_non_normalized;

INSERT INTO film_normalized(film_id, title, description, release_year, rental_rate, rating)
SELECT DISTINCT film_id, title, description, release_year, rental_rate, rating
FROM mavenmoviesmini.inventory_non_normalized;

INSERT INTO store_normalized(store_id, store_manager_first_name, store_manager_last_name, store_address, store_city, store_district)
SELECT DISTINCT store_id, store_manager_first_name, store_manager_last_name, store_address, store_city, store_district
FROM mavenmoviesmini.inventory_non_normalized;


/* Q5. Make sure your new tables have the proper primary keys defined & that applicable foreign keys are added.
Add any constraints that you think might apply to data like unique or null.*/

-- ANS: Done in Workbench UI tools

/* Q6. Finally, write a brief summary of what you have done, in a way that you non technical client can understand. Communicate
what you did & why your schema design is better?*/

/* ANS: The schema for your business was non normalized. It was very inefficient & redundant with only one big table with all the data 
and duplicate records. I normalized the data by distributing it into multiple tables with their related fields like all the film 
related data in film table & store related data in store table and same with inventory. 
I, then related these tables with foreign keys that are values tat allow us to map to data stored in other tables.
This schema design makes data storage alot efficient and will help you in the future when the business expands.*/
















