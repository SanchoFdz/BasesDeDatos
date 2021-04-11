"EJERCICIO 3
Obtenemos los datos de rentas y juntamos la tabla con lo obtenido en el ejercicio 1"
with rentas as(with histrent as (
	select r.rental_date as fecha, r.rental_id as id from rental r
),clientes as(
	select r2.customer_id, sum(age(histrent.fecha, r2.rental_date)) as sumaT, count(r2.rental_id) as N 
	from rental r2 join histrent on (r2.rental_id = histrent.id-1)
	where age(histrent.fecha, r2.rental_date)>'00:00'::interval
	group by r2.customer_id 
) 
select c.customer_id as "Id Cliente", (clientes.sumaT/clientes.N) as "Promedio entre pagos"
from payment pay join clientes on (pay.customer_id = clientes.customer_id)
join customer c on (clientes.customer_id = c.customer_id)
group by c.customer_id,(clientes.sumaT/clientes.N)
order by c.customer_id asc),
pagos as(with historial as (
	select p.payment_date as fecha, p.payment_id as id from payment p
),clientes as(
	select p2.customer_id, sum(age(historial.fecha, p2.payment_date)) as sumaT, count(p2.payment_id) as N 
	from payment p2 join historial on (p2.payment_id = historial.id-1)
	where age(historial.fecha, p2.payment_date)>'00:00'::interval
	group by p2.customer_id 
) 
select c.customer_id as "Id Cliente", (clientes.sumaT/clientes.N) as "Promedio entre pagos"
from payment pay join clientes on (pay.customer_id = clientes.customer_id)
join customer c on (clientes.customer_id = c.customer_id)
group by c.customer_id,(clientes.sumaT/clientes.N)
order by c.customer_id asc)
select pagos."Id Cliente", pagos."Promedio entre pagos"-rentas."Promedio entre pagos" as diferencia
from pagos, rentas
where pagos."Id Cliente"=rentas."Id Cliente"
group by pagos."Id Cliente",pagos."Promedio entre pagos",rentas."Promedio entre pagos"
order by diferencia asc
"Notaremos que no hay una relacion muy fuerte entre el periodo entre pagos y el periodo entre rentas"