-- section 1
	select title, release_year from Film
	where Film.release_year > 2006;
	
-- section 2
	select film.title from film
	join Language
	on Language.language_id = film.language_id
 	where language.name = 'English' and film.release_year = 2007;
	
-- section 3
	select film.title from film
	join film_category as fc
	on film.film_id = fc.film_id
	join category as c
	on fc.category_id = c.category_id
	where c.name = 'Action';
	
-- section 4
	select film.title from film
	join inventory
	on film.film_id = inventory.film_id
	join rental
	on inventory.inventory_id = rental.inventory_id
	join payment
	on rental.rental_id = payment.rental_id
	where payment.amount > 10;

-- section 5
	select film.title from film
	join inventory
	on film.film_id = inventory.film_id
	join rental
	on inventory.inventory_id = rental.inventory_id
	join payment
	on rental.rental_id = payment.rental_id
	where payment.amount >= 9 and payment.amount <= 11;

-- section 6
	select staff.first_name, staff.last_name from staff
	join address
	on staff.address_id = address.address_id
	join city
	on address.city_id = city.city_id
	join country
	on city.country_id = country.country_id
	where country = 'Canada';
	
-- section 7
	select customer.first_name, customer.last_name from customer
	join address
	on customer.address_id = address.address_id
	join city
	on address.city_id = city.city_id
	where city = 'London'or city = 'Stockport';

-- section 8
	select Actor.first_name, Actor.last_name from Actor
	join Film_Actor
	on Actor.actor_id = Film_Actor.actor_id
	join Film
	on Film_Actor.film_id = Film.film_id
	join Language
	on Film.language_id = Language.language_id
	where Language.name != 'English' and Language.name = 'German';
	
-- section 9
	select actor.first_name, actor.last_name from actor
	join film_actor
	on actor.actor_id = film_actor.actor_id
	join film
	on film_actor.film_id = film.film_id
	join film_category
	on film.film_id = film_category.film_id
	join category
	on film_category.category_id = category.category_id
 	where category.name = 'Comedy' or category.name = 'Drama'
	group by actor.actor_id;
	
-- section 10
	select subquery.first_name, subquery.last_name from
	(select actor.first_name, actor.last_name, count(distinct category.name) as numbers from actor
	join film_actor
	on actor.actor_id = film_actor.actor_id
	join film_category
	on film_actor.film_id = film_category.film_id
	join category
	on film_category.category_id = category.category_id
  	group by actor.actor_id) as subquery
	where numbers > 15;

	