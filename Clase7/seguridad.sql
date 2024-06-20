-- Crear Base de datos
Create database BDVentas;
use BDVentas;

-- 2. Crear tabla producto
create table producto(
	id INT auto_increment primary key,
    nombre VARCHAR(100),
    precio decimal(10,2),
    stock int
);

-- 3. Crear tabla venta
create table ventas(
	id INT auto_increment primary key,
    producto_id int,
    cantidad int,
    fecha date,
    total Decimal(10,2),
    foreign key (producto_id) references producto(id)
);

-- Insertar 3 registros en productos
insert into producto(nombre, precio, stock) values 
('televisor', 1000.00, 100),
('laptop', 3030.00, 50),
('tablet', 1400.00, 20);

select * from producto;
-- 
insert into ventas(producto_id, cantidad, fecha, total) values 
(1, 2, now(), 2000.00),
(2, 1,  now(), 50);

select * from ventas;
-- CREACION DE USUARIOS 

CREATE USER 'adminVenta'@'localhost' identified by 'admin1234';
CREATE USER 'usuarioVenta'@'localhost' identified by 'usuario1234';
CREATE USER 'auditor'@'localhost' identified by 'auditor1234';

SELECT user, host from mysql.user;

SHOW GRANTS FOR 'adminVenta'@'localhost';
SHOW GRANTS FOR 'usuarioVenta'@'localhost';
SHOW GRANTS FOR 'usuarioVenta'@'localhost';

-- PERMISOS PARA EL ADMINISTRADOR
GRANT SELECT, INSERT, UPDATE, DELETE ON BDVentas.producto TO 'adminVenta'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON BDVentas.ventas TO 'adminVenta'@'localhost';
SHOW GRANTS FOR 'adminVenta'@'localhost';

GRANT EXECUTE ON procedure BDVentas.insertar_venta1 TO 'adminVenta'@'localhost';

revoke delete on BDVentas.producto from 'adminVenta'@'localhost';
GRANT DELETE ON BDVentas.producto TO 'adminVenta'@'localhost';

-- PERMISOS PARA EL usuario Ventas
GRANT SELECT, INSERT, UPDATE ON BDVentas.producto TO 'usuarioVenta'@'localhost';
GRANT SELECT, INSERT, UPDATE ON BDVentas.ventas TO 'usuarioVenta'@'localhost';
SHOW GRANTS FOR 'usuarioVenta'@'localhost';

-- PERMISOS PARA EL usuario auditor
GRANT SELECT ON BDVentas.producto TO 'auditor'@'localhost';
GRANT SELECT ON BDVentas.ventas TO 'auditor'@'localhost';
SHOW GRANTS FOR 'auditor'@'localhost';

DROP USER 'auditor'@'localhost';

select * from producto;

select * from ventas;
Delimiter ;
Delimiter // 
create procedure insertar_venta1(
	in p_producto varchar(100),
    in p_cantidad int
) begin
	DECLARE v_producto_id int;
    DECLARE v_precio decimal(10,2);
    DECLARE v_total decimal(10,2);
	
    SELECT id, precio INTO v_producto_id, v_precio from producto where nombre = p_producto;
    -- Calcular el total
    set v_total = v_precio * p_cantidad;
    
    -- insertar en tabla ventas
    insert into ventas(producto_id, cantidad, fecha, total) values (v_producto_id, p_cantidad, now(), v_total);
end//

call insertar_venta1('laptop',3);
