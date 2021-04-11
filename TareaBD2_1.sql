"EJERCICIO 1"
with historial as (
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
order by c.customer_id asc;


"EJERCICIO 2"
"Aquí sacamos la desviacion y la media"
create view mediaDesv as (with ej1 as (with historial as (
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
order by c.customer_id asc),
prom as (
	select avg(ej1."Promedio entre pagos") as "media" from ej1
),
estdevArg as(
	select sum(power((extract(epoch from (select ej1."Promedio entre pagos"-prom."media")))::int,2)) as den,
	count(ej1."Promedio entre pagos") as N
	from ej1, prom
),
estDev as (
	select sqrt(estdevArg.den/estdevArg.N) as estdev from estdevArg	
)
select estDev.estdev as "s",extract(epoch from prom."media") as "m" from estDev,prom);

"Aquí vamos a ver si cumple la regla 68-95-99.7"
select w.seg, div((w.num*100),599) from
(select t.segmento seg, t.num_customers num from (select parametros.segmento, count(*) num_customers
from
(with historial as (
	select p.payment_date as fecha, p.payment_id as id from payment p
),clientes as(
	select p2.customer_id, sum(age(historial.fecha, p2.payment_date)) as sumaT, count(p2.payment_id) as N 
	from payment p2 join historial on (p2.payment_id = historial.id-1)
	where age(historial.fecha, p2.payment_date)>'00:00'::interval
	group by p2.customer_id 
) 
select c.customer_id as id, (clientes.sumaT/clientes.N) as tot_payments
from payment pay join clientes on (pay.customer_id = clientes.customer_id)
join customer c on (clientes.customer_id = c.customer_id)
group by c.customer_id,(clientes.sumaT/clientes.N)
order by c.customer_id asc) as pagos join 
(select '+-3' segmento, (mediaDesv."m"-3*mediaDesv."s") as limite_inferior, (mediaDesv."m"+3*mediaDesv."s") as limite_superior from mediaDesv
union all select '+-2' segmento, (mediaDesv."m"-2*mediaDesv."s") as limite_inferior, (mediaDesv."m"+2*mediaDesv."s") as limite_superior from mediaDesv
union all select '+-1' segmento, (mediaDesv."m"-1*mediaDesv."s") as limite_inferior, (mediaDesv."m"+1*mediaDesv."s") as limite_superior from mediaDesv) as parametros
on (extract(epoch from pagos.tot_payments) between parametros.limite_inferior and parametros.limite_superior)
group by parametros.segmento) as t) as w order by seg asc 
"Viendo los resultados podemos ver que no se cumple con lo necesario para que nuestros datos formen una distribución normal"

"EJERCICIO 3
Ya tenemos los datos es solo juntarlos"
select datos."Id Cliente",extract(epoch from datos."Promedio entre pagos")-mediaDesv."m" from (with historial as (
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
order by c.customer_id asc) as datos,mediaDesv;


