----------CONSULTAS----------

-- 1) Listado de todas las fechas y nombres de los conciertos
-- realizados en el año 2016, ordenados de forma ascendente.
select c.FECHA, c.GIRA_NOMBRE
from conciertos c
where year(c.FECHA) = 2016
order by c.FECHA asc;

-- 2) Listado del sueldo medio por año de nacimiento, la media
-- debe estar a redondeada 2 decimales.
select year(p.FECHA_NACIMIENTO) as AñoNacimiento, round(avg(SUELDO), 2) as mediaSalarial
from personal p
group by AñoNacimiento
order by AñoNacimiento desc;

-- 3) Nombre de las giras del artista que tenga el mayor sueldo.
select *
from gira g
where g.ARTISTAS_NOMBRE = (
 	select a.NOMBRE
 	from artistas a
 	order by a.SUELDO desc limit 1
);

-- 4) Listado de las 10 entradas más caras en la instalación
-- con mayor capacidad.
select e.*
from entradas e
join conciertos c ON e.CONCIERTOS_FECHA = c.FECHA
join instalaciones i on i.ID_INSTALACIONES = c.INSTALACIONES_idINSTALACIONES
where i .nombre = (select i2.NOMBRE
 	from instalaciones i2
 	order by i2.CAPACIDAD desc limit 1
)
order by e.PRECIO desc limit 10;

-- 5) Seleccionar el nombre de los artistas que tengan un
-- sueldo mayor a 150.000 o que estén registrados en el 
-- género musical ‘Rap’. Realizándose con 2 consultas unidas.
select a.NOMBRE, a.SUELDO, a.GÉNERO_MUSICAL
from artistas a
where a.SUELDO > 150000
union
select a.NOMBRE, a.SUELDO, a.GÉNERO_MUSICAL
from artistas a
where a.GÉNERO_MUSICAL = 'Rap';


----------VISTAS----------

-- Vista creada a partir de la consulta nº5, que muestra 
-- artistas que cobran más de 150000 o pertenezcan al género 'RAP'.
create view Artistas_Sueldo_O_Rap as
select a.NOMBRE, a.SUELDO, a.GÉNERO_MUSICAL
from artistas a
where a.SUELDO > 150000
union
select a.NOMBRE, a.SUELDO, a.GÉNERO_MUSICAL
from artistas a
where a.GÉNERO_MUSICAL = 'Rap';

-- Vista creada a partir de la consulta nº2, que recoge
-- la media salarial (Redondeada a 2 cifras) agrupandolá
-- por año de nacimiento.
create view Resumen_Salario_Medio as
select year(p.FECHA_NACIMIENTO) as AñoNacimiento, round(avg(SUELDO), 2) as mediaSalarial
from personal p
group by AñoNacimiento
order by AñoNacimiento desc;


----------FUNCIONES----------

-- Función que devolverá datos simples (Nombre, Apellido y Teléfono)
-- de un empleado del personal pasando su ID; si este no existe,
-- se devolverá el mensaje “Este empleado no existe o no está registrado”.
delimiter $$
create function Datos_Empleados(idEmpleado int)
returns varchar(100) deterministic
begin
	declare respuesta varchar(100);
	declare nombre varchar(45);
	declare apellido varchar(45);
	declare telefono varchar(10);
	declare cantidad int;
	
select p.NOMBRE, p.APELLIDOS, p.TELEFONO into nombre, apellido, telefono
	from personal p
	where p.ID_PERSONAL = idEmpleado;
	select count(*) into cantidad
	from personal p2
	where p2.ID_PERSONAL = idEmpleado
	group by p2.ID_PERSONAL;
	
if cantidad > 0 then
set respuesta = concat('Datos: ',nombre,' ', apellido,' ', telefono);
	else
set respuesta = 'Este empleado no existe o no está registrado';
	end if;
	
	return respuesta;
end $$
delimiter ;

-- Función que devuelve el precio medio de las entradas
-- de un determinado tipo, redondeado a 2 decimales.
delimiter $$
create function Media_Precio_Entradas(tipoEntrada varchar(10))
returns decimal(10,2) deterministic
begin
	declare MediaPrecio decimal(10,2);

	select round(avg(e.PRECIO), 2) into MediaPrecio
	from entradas e
	where e.TIPO = tipoEntrada
	group by e.TIPO;

	return MediaPrecio;
end $$
delimiter ;


----------PROCEDIMIENTOS----------

-- Procedimiento al que se le pasará un tipo de entrada, diga 
-- el número de entradas totales, precio máximo y mínimo de este,
-- y utilizando la función anterior, también muestre la media.
delimiter $$
create procedure Informe_Entrada(in tipoEntrada varchar(10))
begin
	select e.TIPO as Tipo, count(*) as Total, max(e.PRECIO) as Maximo, min(e.PRECIO) as Minimo, Media_Precio_Entradas(tipoEntrada) as Media 
	from entradas e
	where e.TIPO = tipoEntrada
	group by e.TIPO;
end $$
delimiter ;

-- Utilizando un cursor, mostrar por pantalla el número de conciertos
-- en cada mes y año que haya guardado en la base de datos.
delimiter $$
create procedure Calcular_Conciertos_Por_Mes()
begin
   declare done boolean default false;
   declare salida varchar(10000) = '';
   declare anyo int;
   declare mes int;
   declare numconciertos int;
   declare cursor1 cursor for
       select year(fecha) as anyo, month(fecha) as mes, count(*) as numconciertos 
       from conciertos c
       group by year(fecha), month(fecha)
       order by year(fecha), month(fecha);
   declare continue handler for not found set done = true;
   
open cursor1;
   bucle_conciertos: loop
       fetch cursor1 into anyo, mes, numconciertos;
       if done then
           leave bucle_conciertos;
       end if;
     
set salida = concat(salida, ' Año: ', anyo, ', Mes: ', mes, ', Número de conciertos: ', numconciertos, '\n');
   end loop bucle_conciertos;
close cursor1;
 
   select salida;
end $$
delimiter ;

-- Procedimiento al que se la pasa el país de origen con
-- el que se quiere cribar la tabla; si este país no está
-- registrado, mandará un mensaje de aviso.
delimiter $$
create procedure Listado_Pais(in paramPais varchar(45))
begin
	declare cantidad int;
	
	select count(*) into cantidad 
	from artistas a 
	where a.PAÍS_ORIGEN = paramPais;

	if cantidad > 0 then
		select * 
		from artistas a 
		where a.PAÍS_ORIGEN = paramPais;
	else
		select "El país no se encuentra registrado en la base de datos" as Respuesta;
	end if;
end $$
delimiter ;


----------TRIGGERS----------

-- Crear un trigger que guarde en una tabla conocida como
-- "copia_seguridad_conciertos" todos los datos de este antes
-- de borrar cualquier dato de la tabla "Conciertos".
delimiter $$
create trigger CopiaSeguridadConciertos
before delete 
on conciertos for each row 
begin 
	insert into copia_seguridad_conciertos  
	values(old.FECHA, old.DURACIÓN, old.ID_INSTALACIÓN, old.GIRA_NOMBRE);
end $$
delimiter ;