-- Q1
select actor.first_name, actor.last_name, film.title
from actor
join film_actor
on actor.actor_id = film_actor.actor_id
join film
on film_actor.film_id = film.film_id;

-- Q1.1
select actor.first_name, actor.last_name, film.title 
from actor, film, film_actor 
where actor.actor_id = film_actor.actor_id
and film.film_id = film_actor.film_id;

-- Q2
select actor.first_name, actor.last_name, film.title
from film
join film_actor
on film.film_id = film_actor.film_id
join actor
on film_actor.actor_id = actor.actor_id
where concat(actor.first_name, ' ', actor.last_name) = 'Rock Dukakis';

-- Q2.1
select actor.first_name ,actor.last_name, film.title 
from film , film_actor, actor
where film.film_id = film_actor.film_id
and actor.actor_id = film_actor.actor_id
and actor.first_name = 'Rock' and actor.last_name = 'Dukakis';

-- Q3
select actor.first_name, actor.last_name, count(film.film_id) as number_of_films
from actor
join film_actor
on actor.actor_id = film_actor.actor_id
join film
on film_actor.film_id = film.film_id
group by actor.actor_id;

-- Q3.1
select actor.first_name, actor.last_name , count(film_actor.film_id) as number_of_films 
from actor, film_actor, film
where actor.actor_id = film_actor.actor_id
and film.film_id = film_actor.film_id
group by actor.actor_id;	

-- Q4
select category.name, count(film.film_id)
from category
left join film_category
on category.category_id = film_category.category_id
left join film
on film_category.film_id = film.film_id
group by category.category_id;

-- Q4.1
select category.name,
(select count(*) from film_category 
where film_category.category_id = category.category_id) as count from category;

-- Q5
select category.name, count(film.film_id)
from category
join film_category
on category.category_id = film_category.category_id
join film
on film_category.film_id = film.film_id
group by category.category_id;

-- Q5.1
select category.name , count(film_category.film_id) as count 
from category , film_category, film 
where category.category_id = film_category.category_id
and film.film_id = film_category.film_id 
group by category.category_id;

-- Q6
select actor.actor_id, actor.first_name, actor.last_name, category.name, count(film_actor.film_id)
from actor
join film_actor
on actor.actor_id = film_actor.actor_id
join film_category
on film_actor.film_id = film_category.film_id
join category
on film_category.category_id = category.category_id
group by category.category_id, actor.actor_id
order by actor.actor_id, category.name;

-- Q6.1
select actor.actor_id, actor.first_name, actor.last_name, category.name,total.count 
from actor 
join (
	select film_actor.actor_id,film_category.category_id,
	count(film_category.film_id) as count 
	from film_actor
	join film_category 
	on film_actor.film_id = film_category.film_id
	group by film_actor.actor_id, film_category.category_id) as total
on actor.actor_id = total.actor_id
join category ON total.category_id = category.category_id
order by actor.actor_id, category.name;

-- Q7
select actor.actor_id, actor.first_name, actor.last_name
from actor
where actor.actor_id not in(
	select actor.actor_id
	from actor
	join film_actor
	on actor.actor_id = film_actor.actor_id
	join film_category
	on film_actor.film_id = film_category.film_id
	join category
	on film_category.category_id = category.category_id
	join film
	on film_category.film_id = film.film_id
	where film.length > 90 and film.rating = 'PG-13' and category.name = 'Sci-Fi'
)
order by actor.actor_id;

-- Q7.1
select distinct actor.actor_id, actor.first_name, actor.last_name 
from actor
left join (
	select film_actor.actor_id
	from film_actor
	join film 
	on film_actor.film_id = film.film_id
	join film_category 
	on film.film_id = film_category.film_id
	join category 
	on film_category.category_id = category.category_id
	where film.length > 90 and category.name = 'Sci-Fi' and film.rating = 'PG-13') as c1
on actor.actor_id = c1.actor_id
where c1.actor_id is NULL
order by actor.actor_id;

-- Q8
select actor.first_name, actor.last_name, film.title
from actor
join film_actor
on actor.actor_id = film_actor.actor_id
join film 
on film_actor.film_id = film.film_id
where film.film_id in(
	select film.film_id 
	from actor
	join film_actor 
	on actor.actor_id = film_actor.actor_id
	join film 
	on film.film_id = film_actor.film_id
	join film_category 
	on film_category.film_id = film.film_id
	join category 
	on category.category_id = film_category.category_id
	where concat(actor.first_name, ' ', actor.last_name) = 'Sandra Peck'
	and category.name = 'Action'
)
and concat(actor.first_name, ' ', actor.last_name) != 'Sandra Peck';

-- Q8.1
select title, actor.first_name, actor.last_name 
from ((((category 
		join film_category 
		on category.category_id = film_category.category_id)
        join film 
		on
		film_category.film_id = film.film_id)
        join film_actor 
	    on film.film_id = film_actor.film_id)
        join actor 
	    on film_actor.actor_id = actor.actor_id)
      	where film.title in (select film.title from
        ((((category 
		join film_category 
	    on category.category_id = film_category.category_id)
        join film 
		on film_category.film_id = film.film_id)
        join film_actor 
		on film.film_id = film_actor.film_id)
        join actor 
		on film_actor.actor_id = actor.actor_id)
        where category.name = 'Action' 
		and actor.first_name = 'Sandra' and actor.last_name = 'Peck')
        and actor.first_name <> 'Sandra' and actor.last_name <> 'Peck'
        order by title;
		
-- Q9
select film.title, film.length
from film
join film_actor
on film.film_id = film_actor.film_id
join actor
on film_actor.actor_id = actor.actor_id
where concat(actor.first_name, ' ', actor.last_name) = 'Sandra Peck'
intersect
select film.title, film.length
from film
join film_actor
on film.film_id = film_actor.film_id
join actor
on film_actor.actor_id = actor.actor_id
where concat(actor.first_name, ' ', actor.last_name) = 'Ralph Cruz';

-- Q9.1
select film.title, film.length 
from film
join film_actor as film_actor1 
on film.film_id = film_actor1.film_id
join actor as actor1 
on film_actor1.actor_id = actor1.actor_id 
and actor1.first_name = 'Ralph' and actor1.last_name = 'Cruz'
join film_actor as film_actor2 
on film.film_id = film_actor2.film_id
join actor as actor2 
on film_actor2.actor_id = actor2.actor_id 
and actor2.first_name = 'Sandra' and actor2.last_name = 'Peck';

-- Q10
select film.title, film.length
from film
where film.film_id
not in (
	select film.film_id
	from film
	join film_actor
	on film.film_id = film_actor.film_id
	join actor
	on film_actor.actor_id = actor.actor_id
	where concat(actor.first_name, ' ', actor.last_name) = 'Sandra Peck'
	union
	select film.film_id
	from film
	join film_actor
	on film.film_id = film_actor.film_id
	join actor
	on film_actor.actor_id = actor.actor_id
	where concat(actor.first_name, ' ', actor.last_name) = 'Ralph Cruz'
)
and film.length > 100;

-- Q10.1
select film.title , film.length 
from film
where film_id not in ( 
	select distinct film.film_id 
	from film 
	join film_actor 
	on film.film_id = film_actor.film_id 
	join actor 
	on film_actor.actor_id = actor.actor_id 
	where (actor.first_name = 'Ralph' and actor.last_name = 'Cruz') 
	or (
		actor.first_name = 'Sandra' and actor.last_name = 'Peck')
)and length > 100;

-- Q11
select language.name, count(film.film_id)
from film
right join language
on film.language_id = language.language_id
group by language.language_id;

-- Q11.1
select language.name, (select count(*) 
	from film 
	where film.language_id = language.language_id) as count 
from language;

-- Q12
select c1.first_name, c1.last_name, c2.first_name as first_name_1, c2.last_name as last_name_2
from customer as c1, customer as c2
where c1.address_id = c2.address_id and c1.customer_id != c2.customer_id;

-- Q12.1
select customer1.first_name, customer1.last_name, 
customer2.first_name as first_name_2, customer2.last_name as last_name_2 
from customer as customer1
join customer as customer2 
on customer1.address_id = customer2.address_id 
and customer1.customer_id <> customer2.customer_id;

-- Q13
select film.title, count(rental.rental_id)
from film
join inventory
on film.film_id = inventory.film_id
join rental
on inventory.inventory_id = rental.inventory_id
group by film.film_id
order by count
limit 1;

-- Q13.1
select title, count from 
	(select film.title as title, count(rental.rental_id) as count 
	from film
	join inventory 
	on film.film_id = inventory.film_id 
	join rental 
	on inventory.inventory_id = rental.inventory_id
	group by film.title
	) as t1 where count > 0
order by count
limit 1;

-- Q14
select film.title
from film
join inventory
on film.film_id = inventory.film_id
join rental
on inventory.inventory_id = rental.inventory_id
group by film.film_id
having count(film.film_id) = (
	select count(rental.rental_id)
	from film
	join inventory
	on film.film_id = inventory.film_id
	join rental
	on inventory.inventory_id = rental.inventory_id
	group by film.film_id
	order by count desc
	limit 1 offset 2
);

-- Q14.1
select film.title 
from rental 
join inventory 
on rental.inventory_id = inventory.inventory_id
join film 
on inventory.film_id = film.film_id
group by film.film_id 
order by count(rental_id) desc 
limit 5 offset 2;

-- Q15
select film.title
from film
where film.film_id not in(
	select film.film_id
	from film
	left join inventory
	on film.film_id = inventory.film_id
	left join store
	on inventory.store_id = store.store_id
	where store.store_id = 1 
	intersect
	select film.film_id
	from film
	left join inventory
	on film.film_id = inventory.film_id
	left join store
	on inventory.store_id = store.store_id
	where store.store_id = 2
)
group by film.film_id;

-- Q15.1
select film.title 
from film
where not exists (
    select 1 
	from inventory
    join store
	on inventory.store_id = store.store_id 
    where inventory.film_id = film.film_id 
    and store.store_id in (1, 2)
    and exists (
        select 1 
		from inventory as i
        join store as s
		on i.store_id = s.store_id 
        where i.film_id = film.film_id and s.store_id <> store.store_id
    )
)
order by film.title;

-- extra 1
select f.title, f.replacement_cost, f.rating, (
select min(film.replacement_cost)
	from film
	where f.rating = film.rating
) as min_replacement_cost
from film as f
order by f.rating, f.replacement_cost;

-- extra 1.1
select f.title, f.replacement_cost, f.rating, 
min(f.replacement_cost) over(partition by f.rating) as min_replacement_cost
from film as f
order by f.rating, f.replacement_cost;

-- extra 2
select film.title, film.rental_rate, film.rating,
rank() over(partition by film.rating order by film.rental_rate desc) as rank
from film
order by film.rating, film.rental_rate desc;
