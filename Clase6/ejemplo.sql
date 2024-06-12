create database ht1_g0;
use ht1_g0;

create table (
	id INT PRIMARY KEY auto_increment,
    nombre VARCHAR(100),
    edad int
);

select * from personas;


insert into personas(nombre, edad) values 
 ('Jhonathan',20),
('Jose',20),
('Elder',18),
('Juan',21),
('Luis',21);

insert into personas(nombre, edad) values 
('Angel', 22), 
('Daniel', 35),
('Harry 21',21);

truncate table personas;s