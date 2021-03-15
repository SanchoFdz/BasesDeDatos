"1. Obtener nombre y correo de todos nuestros clientes en Canada"
select concat(c.first_name,' ',c.last_name),c.email from customer c join address a 
using(address_id) join city c2 using(city_id) where c2.country_id = 20

"2.Obtener cliente que más rentas de la sección de adultos ha hecho"
select concat(c.first_name,' ',c.last_name),count(r.rental_id) from customer c join rental r using(customer_id)
join inventory i using(inventory_id) join film f using(film_id) where f.rating ='NC-17' group by c.customer_id 
order by count(r.rental_id) desc limit 1

"3. Qué peliculas son las más rentadas en nuestras stores?"
select distinct on (t.store_id) t.store_id, t.title,t."count" from (select f.title, count(r.rental_id),i.store_id from film f join inventory i 
using(film_id) join rental r using(inventory_id) group by i.store_id, f.film_id 
order by i.store_id asc, count(r.rental_id) desc) as t

"4. Cual es el revenue de nuestros stores"
select s.store_id,sum(p.amount) from store s join inventory i using(store_id)
join rental r using(inventory_id) join payment p using(rental_id) 
group by store_id order by store_id asc