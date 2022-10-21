-- Lab | SQL Join (Part II)

-- 1. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country FROM store as s
INNER JOIN sakila.address as a
ON s.address_id = a.address_id
INNER JOIN sakila.city as c
ON a.city_id= c.city_id
INNER JOIN sakila.country as co
ON c.country_id = co.country_id;

-- 2. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, round(SUM(p.amount),2) AS total_amount
FROM sakila.store as s
INNER JOIN sakila.payment AS p
ON s.manager_staff_id = p.staff_id
GROUP BY s.store_id;

-- 3. Which film categories are longest?
SELECT fc.category_id, c.name, f.length FROM film_category as fc
INNER JOIN sakila.film as f
ON fc.film_id = f.film_id
INNER JOIN sakila.category as c
ON fc.category_id= c.category_id
ORDER BY f.length DESC
limit 1;

-- 4. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) as 'frequency' FROM rental as r
INNER JOIN inventory as i
ON r.inventory_id = i.inventory_id
INNER JOIN film as f
ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY frequency DESC;

-- 5. List the top five genres in gross revenue in descending order.
SELECT c.name, round(SUM(p.amount),2) AS gross_revenue
FROM sakila.category as c
INNER JOIN sakila.film_category AS fc
ON c.category_id = fc.category_id
INNER JOIN inventory AS i
ON fc.film_id= i.film_id
INNER JOIN rental as r
ON i.inventory_id=r.inventory_id
INNER JOIN payment as p
ON r.rental_id=p.rental_id
GROUP BY c.name
ORDER BY gross_revenue DESC;

-- 6.  Is "Academy Dinosaur" available for rent from Store 1?
SELECT f.title, i.store_id,i.inventory_id FROM film as f
INNER JOIN inventory as i
ON f.film_id = i.film_id
GROUP BY i.store_id;

-- 7. Get all pairs of actors that worked together.
USE sakila
SELECT fa1.film_id as film_id1, fa2.film_id as film_id2, 
CONCAT (a.first_name,' ', a.last_name) as actor1, CONCAT(a2.first_name,' ', a2.last_name) as actor2
FROM film_actor as fa1
JOIN actor as a
ON fa1.actor_id=a.actor_id
CROSS JOIN film_actor as fa2
ON fa1.film_id = fa2.film_id
AND fa1.actor_id>fa2.actor_id
JOIN actor as a2
ON fa2.actor_id = a2.actor_id
ORDER BY film_id1; 

-- 8. Get all pairs of customers that have rented the same film more than 3 times.
create temporary table sakila.rmovies
SELECT r1.rental_id, r1.inventory_id, r1.customer_id, i.film_id, CONCAT(customer_id,film_id) as freq
FROM rental as r1
JOIN inventory as i
ON r1.inventory_id=i.inventory_id; 

create temporary table sakila.rmovies2
SELECT rental_id, inventory_id, customer_id, film_id, COUNT(freq) FROM sakila.rmovies
GROUP BY film_id
HAVING COUNT(freq)>3;

create temporary table sakila.rmovies3
SELECT rental_id, inventory_id, customer_id, film_id, COUNT(freq) FROM sakila.rmovies
GROUP BY film_id
HAVING COUNT(freq)>3;

# Don´t know how to do it, I tried different things now and it doesn´t return the values
SELECT rm2.customer_id as customer_id1, rm3.customer_id as customer_id2, rm2.film_id, rm3.film_id
FROM sakila.rmovies2 as rm2
JOIN sakila.rmovies3 as rm3
ON rm2.film_id=rm3.film_id
AND rm2.film_id>rm3.film_id
GROUP BY rm2.film_id;








-- 9. For each film, list actor that has acted in more films.
create temporary table sakila.actor_nmovies1
SELECT fa.actor_id, CONCAT(a.first_name,' ', a.last_name) as actor, COUNT(film_id) as n_movies
FROM film_actor as fa
JOIN actor as a
ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id
ORDER BY n_movies DESC;

create temporary table sakila.actor_nmovies2
SELECT fa.actor_id, CONCAT(a.first_name,' ', a.last_name) as actor, COUNT(film_id) as n_movies
FROM film_actor as fa
JOIN actor as a
ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id
ORDER BY n_movies DESC;

select * from sakila.actor_nmovies1;

create temporary table sakila.pairs_actors
SELECT f1.film_id as film_id, f1.actor_id as actor1 , f2.actor_id as actor2 FROM sakila.film_actor as f1
join  sakila.film_actor as f2
on f1.film_id = f2.film_id and f1.actor_id < f2.actor_id
order by film_id asc, actor1 asc, actor2 asc;

select * from sakila.pairs_actors;

select p.film_id, a.actor_id as actor1, a.n_movies as n_movies1, p.actor2 from actor_nmovies as a
join sakila.pairs_actors as p
on a.actor_id = p.actor1;

create temporary table sakila.pairs_movies
select a1.actor_id as actor1, a1.n_movies as n_movies1, a2.actor_id as actor2, a2.n_movies as n_movies2 from sakila.actor_nmovies1 as a1
join sakila.actor_nmovies2 as a2
on a1.actor_id <> a2.actor_id;

select * from sakila.pairs_movies;

select pa.film_id, pa.actor1, pm.n_movies1, pa.actor2, pm.n_movies2 from sakila.pairs_actors as pa
join sakila.pairs_movies as pm
on pa.actor1 = pm.actor1  and pa.actor1 <> pm.actor2
where pm.actor1 < pm.actor2;

SELECT fa1.film_id as film_id1, CONCAT (a.first_name,' ', a.last_name) as actor1, 
CONCAT(a2.first_name,' ', a2.last_name) as actor2,
COUNT(fa1.actor_id) as n_movies,COUNT(fa2.actor_id) as n2_movies
FROM film_actor as fa1
JOIN actor as a
ON fa1.actor_id=a.actor_id
CROSS JOIN film_actor as fa2
ON fa1.film_id = fa2.film_id
AND fa1.actor_id<>fa2.actor_id
JOIN actor as a2
ON fa2.actor_id = a2.actor_id
GROUP BY a.actor_id; 