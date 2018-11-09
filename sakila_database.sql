-- Using sakila Database
USE sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name 
FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
CREATE VIEW actor_name AS
		SELECT  UPPER(CONCAT(first_name,'  ', last_name))  AS actor_name
		FROM actor;

SELECT * FROM actor_name;

-- Deliting column from table
ALTER TABLE actor DROP COLUMN actor_name;
                
-- * 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?			

SELECT  actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE '%Joe%';

-- * 2b. Find all actors whose last name contain the letters `GEN`:

SELECT  actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:

SELECT   last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';


-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:


SELECT   country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

 ALTER TABLE actor
 ADD description BLOB NOT NULL;
 
 SELECT * FROM actor;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS  number
FROM   actor
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name, COUNT(*) AS number
FROM   actor
GROUP BY last_name
HAVING number >= 2; 

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.

-- Cheking for  actors  with last_name  `WILLIAMS`
SELECT first_name, last_name 
FROM actor
WHERE last_name = 'WILLIAMS';

UPDATE actor SET first_name ='HARPO'  WHERE first_name='GROUCHO';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` 
-- was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor SET first_name = 'GROUCHO' WHERE first_name='HARPO' ;

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?--

-- Query is  showing the code to re-create a table
SHOW CREATE TABLE address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT s.first_name,s.last_name, a.address
FROM staff s
JOIN address a
ON (s.staff_id = a.address_id);

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

CREATE VIEW total_amount AS
	SELECT  s.staff_id, s.first_name, s.last_name, p.amount 
	FROM staff s
	JOIN payment p
	ON (s.staff_id = p.staff_id)
	WHERE p.payment_date  BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59' ; 

SELECT first_name, last_name, COUNT(amount) as amount
FROM total_amount
GROUP BY staff_id; 


-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
CREATE VIEW actor_count AS
	SELECT  f.film_id, f.title, fa.actor_id
	FROM film f
	INNER JOIN film_actor fa
	ON (f.film_id = fa.film_id);

SELECT title,  COUNT(actor_id) as actor_id
FROM actor_count
GROUP BY title; 

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(inventory_id) AS 'Number of copies'
FROM inventory
WHERE film_id IN
	(SELECT film_id
	FROM film
    WHERE title =  'Hunchback Impossible'
) ;


-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
 -- List the customers alphabetically by last name:
 
CREATE VIEW bill AS
	SELECT c.customer_id, c.first_name, c.last_name, p.amount
	FROM customer c
	INNER JOIN payment p
	ON (c.customer_id = p.customer_id);
 
SELECT first_name, last_name, COUNT(amount) as 'Total Amount Paid'
FROM bill
GROUP BY customer_id
ORDER BY  last_name ASC; 

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM film
WHERE title IN
(
	SELECT title
	FROM film
	WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND language_id = 1 
);

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
  )
);

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
-- and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT c.first_name, c.last_name, c.email
FROM customer c
    INNER JOIN address a
    ON (c.address_id=a.address_id)
		INNER JOIN city ci
		ON (a.city_id=ci.city_id)
			INNER JOIN country ct
			ON (ct.country_id=ci.country_id)
WHERE ct.country = 'Canada';


-- * 7d. Sales have been lagging among young families, and you wish to target all family movies 
-- for a promotion. Identify all movies categorized as _family_ films.

SELECT f.title
FROM film f
    INNER JOIN film_category fm
    ON (f.film_id = fm.film_id)
			INNER JOIN category c
			ON (fm.category_id = c.category_id)
WHERE c.name = 'Family';

-- * 7e. Display the most frequently rented movies in descending order.
CREATE VIEW rental_frequency  AS
	SELECT f.title, COUNT(rental_id) AS Frequency
	FROM rental r
		INNER JOIN inventory i
		ON (r.inventory_id = i.inventory_id)
			INNER JOIN film f
			ON (i.film_id =  f.film_id)
GROUP BY f.film_id;
    
SELECT * FROM rental_frequency
ORDER BY  frequency DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.

CREATE VIEW business_total  AS
	SELECT  s.store_id,  COUNT(amount) AS Gross
	FROM payment p
		INNER JOIN staff s
		ON (p.staff_id = s.staff_id)
			INNER JOIN store st
			ON (s.store_id = st.store_id)
GROUP BY st.store_id;

SELECT * FROM business_total;

-- * 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, c.city, ct.country
FROM store s
    INNER JOIN address a
    ON (s.address_id = a.address_id)
		INNER JOIN city c
		ON (a.city_id = c.city_id)
			INNER JOIN country ct
			ON (c.country_id = c.country_id);
    
-- * 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT  c.name, COUNT(amount) AS gross_revenue
FROM payment p
    INNER JOIN rental r
    ON (p.rental_id = r.rental_id)
		INNER JOIN inventory i
		ON (r.inventory_id = i.inventory_id)
			INNER JOIN film f
			ON (i.film_id = f.film_id)
				INNER JOIN film_category fm
				ON (f.film_id = fm.film_id)
					INNER JOIN category c
					ON (fm.category_id = c.category_id)
GROUP BY fm.category_id
ORDER BY gross_revenue  DESC
LIMIT 5;


-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
--  Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres  AS
	SELECT  c.name,  COUNT(amount) AS gross_revenue 
	FROM payment p
		INNER JOIN rental r
		ON (p.rental_id = r.rental_id)
			INNER JOIN inventory i
			ON (r.inventory_id = i.inventory_id)
				INNER JOIN film f
				ON (i.film_id = f.film_id)
					INNER JOIN film_category fm
					ON (f.film_id = fm.film_id)
						INNER JOIN category c
						ON (fm.category_id = c.category_id)
GROUP BY fm.category_id;

-- * 8b. How would you display the view that you created in 8a?
SELECT *  FROM top_five_genres 
ORDER BY  gross_revenue  DESC
LIMIT 5;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;