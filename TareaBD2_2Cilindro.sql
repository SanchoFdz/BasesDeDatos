"contamos las películas"
select i2.store_id, count(i2.inventory_id) from inventory i2 
group by i2.store_id 
"Supondremos que la maquina de peliculas mide 50cmx50cm y le daremos un espazcio de 1 cm para rotar con facilidad
Así, tenemos un cilindro formado por la maquina de diametro de 51cm (radio 25.5cm)
Calcularemos el perimtro de un disco del cilindro "
select 51*pi()
"La forma más eficiente de acomodarlas es con su cara de 8*30 como base
De tal forma que la cantidad de peliculas que podemos tener en cada nivel del cilindro estás dado por:"
select floor(51*pi()/8)
"Podemos colocar 20 peliculas en cada nivel. Ahora, si el maximo es de 50000 gr por cilindro y cada pelicula pesa
500 gr entonces podemos tener 100 peliculas por cilindro. Entonces:"
"Necesitaremos la siguiente cantidad de cilindros por tienda:"
select i.store_id as "tienda",ceiling(cast(count(i.inventory_id) as float)/cast(100 as float)) as "num_cilindros" from inventory i 
group by i.store_id 
"Si suponemos que entre cada disco del cilindro dejamos 2cm de colchon, nuestros cilindros tendran una altura de "
select 21*(100/20)+2*(100/20)
"Ahora, si cada pelicula mide 30cm de largo, tendremos un cilindro exterior sobre el que se pondran las películas
de 2x30+51 cm de diametro= 111 cm y con 55.5cm de radio, esto nos deja un cilindro de perimetro:"
select pi()*111
"Pero como tenemos que en total el perimetro de nuestras 20 peliculas es 160 entonces tenemos que analizar que pasa con el restante de:"
select pi()*111-160
"nos quedan 188.71cm de perimetro. Si consideramos que al estar sobre un circulo, las peliculas se separan (a manera de rayos)
a medida que se acercan al perimetro exterior. Esto forman 20 pequeños segmentos de circulo (en forma de pizzas) con radio de 30cm y arco de:"
select (pi()*111-160)/20
"Estas 20 'pizzas' tienen un volumen acumulado aproximado de:"
with semiperimetro as (select (2*30+(pi()*111-160)/20)/2 as "sem"),
areapizza as(select sqrt(semiperimetro."sem"*(semiperimetro."sem"-30)*(semiperimetro."sem"-30)*(semiperimetro."sem"-(pi()*111-160)/20)) as "area"
from semiperimetro)
select areapizza."area"*21*20 from areapizza
"Entonces, por cada disco de 20 peliculas tenemos un volumen de: "
select round(5040*20+58706.079429685626,3)
"Ahora, si tomamos 100 peliculas por cilindro, tenemos un cilindro con las siguientes especificaciones"
select 100 as "num_peliculas", 5 as "niveles", 500*100 as "peso peliculas", 105 as "altura",111 as "diametro", 159,506*5 as "Volumen Total"
"Si consideramos el cilindro central, cada cilindro tiene un volumen de: "
select (pi()*power(55.5,2)*105)/1000000 as "Volumen Cilindro m3"
"Por lo tanto, cada tiende deberá tener disponibles la siguiente cantidad de m3 para colocar los cilindros:"
select i.store_id as "tienda",ceiling(cast(count(i.inventory_id) as float)/cast(100 as float)) as "num_cilindros",
ceiling(cast(count(i.inventory_id) as float)/cast(100 as float))*1.016073530978096 as "Espacio requerido"
from inventory i 
group by i.store_id

