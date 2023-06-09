-- section 1
select staff_id, first_name, last_name from staff;

-- section 2
select customer_id, last_name, first_name from customer
order by last_name;

-- section 3
select city_id, city from city
where country_id = 60;

-- section 4
select * from customer
where store_id = 1 and first_name like 'J%';

-- section 5
select * from film
order by rental_rate desc
limit 5;

-- section 6
select distinct(amount) from payment
order by amount;

-- section 7
select count(customer_id) from payment
where amount in (0, 0.99, 4.99);

-- section 8
select count(distinct(customer_id)) from rental;

-- section 9
select distinct(customer_id) from rental;

-- section 10
select count(rating) as "Number of Movies", rating from film
group by rating;

-- section extra_1
select customer.first_name, customer.last_name and, payment.* from payment
natural join customer
where customer.customer_id = 344
and payment_date between '2007-02-15' and '2007-02-20';

-- section extra_2
select concat(first_name, ' ', last_name) as full_name from customer;

-- section extra_3
update film
set rental_rate = round(0.8 * rental_rate, 2);
