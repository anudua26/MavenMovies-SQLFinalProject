/* 
1. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 
SELECT 
       staff.store_id AS store_id,
       -- store.manager_staff_id,
       staff.first_name AS manager_first_name,
       staff.last_name AS manager_last_name,
       CONCAT(staff.first_name, '  ', staff.last_name) AS manager_full_name,
       address.address AS Store_street_address,
       address.district AS store_district,
       city.city AS store_city,
       country.country AS store_country,
       CONCAT(address.address, ',', ' ', address.district, ',', ' ', city.city, ',', ' ', country.country) AS store_full_address
FROM  staff 
INNER JOIN store
ON staff.store_id = store.store_id
INNER JOIN address
ON store.address_id = address.address_id  
INNER JOIN city
ON address.city_id  = city.city_id
INNER JOIN country
ON city.country_id = country.country_id;
              
	
/*
2.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/

SELECT 
	  inventory.store_id,
	  inventory.inventory_id,
      film.title AS film_name,
      film.rating AS film_rating,
      film.rental_rate AS film_rental_rate,
      film.replacement_cost
	
 FROM film   
 INNER JOIN inventory 
 ON film.film_id = inventory.film_id;
	
       

/* 
3.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/

SELECT 
	  inventory.store_id, 
	  COUNT(inventory.inventory_id) AS inventory_list,
      film.rating

FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
GROUP BY inventory.store_id,
		 film.rating;

/* 
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 
SELECT 
	inventory.store_id,
	category.name AS film_category,
    COUNT(film.film_id) AS number_of_films,  
       AVG(film.replacement_cost) AS average_replacement_cost,
       SUM(film.replacement_cost) AS total_replacement_cost
       
FROM film
INNER JOIN inventory   ON film.film_id = inventory.film_id
INNER JOIN film_category ON inventory.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY 1, 2
ORDER BY total_replacement_cost  DESC;


/*
5.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/

SELECT  
	   customer.store_id,
      customer.first_name AS customer_first_name,
      customer.last_name AS customer_last_name,
      CONCAT(customer.first_name, ' ', customer.last_name) AS customer_full_name,
      CASE WHEN customer.store_id = 1 AND customer.active = 1 THEN 'active' ELSE 'inactive' END AS customer_store_1_activity, 
      CASE WHEN customer.store_id = 2 AND customer.active = 1 THEN 'active' ELSE 'inactive' END AS customer_store_2_activity,
       address.address AS street_address,
       address.district AS district,
       city.city AS city,
       country.country AS country,
       CONCAT(address.address, ',', ' ', address.district, ',', ' ', city.city, ',', ' ', country.country) AS full_address
      
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id  
INNER JOIN city
ON address.city_id  = city.city_id
INNER JOIN country
ON city.country_id = country.country_id;


/*
6.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/
SELECT  
	  customer.store_id,
      customer.first_name AS customer_first_name,
      customer.last_name AS customer_last_name,
      CONCAT(customer.first_name, ' ', customer.last_name) AS customer_full_name,
      COUNT(rental.rental_id) AS total_rentals,
      SUM(payment.amount) AS total_payment
      
FROM customer  
INNER JOIN payment    ON customer.customer_id = payment.customer_id    
INNER JOIN rental ON payment.rental_id = rental.rental_id
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film ON inventory.film_id = film.film_id
GROUP BY customer.store_id, customer_full_name
ORDER BY total_payment DESC;

    
/*
7. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/
SELECT 'advisor' as type, 
        first_name, 
        last_name, 
         NULL
FROM    advisor
UNION
SELECT 'investor' as type, 
        first_name, 
        last_name, 
        company_name 
FROM    investor;


/*
8. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/
SELECT   
         CASE 
         WHEN (actor_award.awards = 'Emmy' OR actor_award.awards = 'Oscar' OR actor_award.awards ='Tony') THEN '1 Award'
         WHEN (actor_award.awards = ('Emmy, Oscar') OR actor_award.awards = ('Oscar,Tony') OR actor_award.awards = ('Emmy,Tony')) THEN '2 Awards'
         ELSE '3 Awards'
         END AS 'awards_received',
		-- AVG(CASE WHEN actor_id IS NULL THEN 0 ELSE 1 END) AS actor_with_atleast_one_film
        AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS pct_w_one_film

FROM actor_award
GROUP BY CASE 
         WHEN (actor_award.awards = 'Emmy' OR actor_award.awards = 'Oscar' OR actor_award.awards ='Tony') THEN '1 Award'
         WHEN (actor_award.awards = ('Emmy, Oscar') OR actor_award.awards = ('Oscar,Tony') OR actor_award.awards = ('Emmy,Tony')) THEN '2 Awards'
         ELSE '3 Awards'
         END 
ORDER BY awards_received;


