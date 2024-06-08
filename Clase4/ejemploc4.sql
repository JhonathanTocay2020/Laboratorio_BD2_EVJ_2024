create database clase4;
use clase4;

CREATE TABLE productos(
	id INT PRIMARY KEY IDENTITY,
	nombre VARCHAR(100),
	precio DECIMAL(10, 2),
	stock INT,
);

CREATE TABLE clientes(
	id INT PRIMARY KEY IDENTITY,
	nombre VARCHAR(100),
	email VARCHAR(100)
);

CREATE TABLE pedidos(
	id INT PRIMARY KEY IDENTITY,
	cliente_id INT,
	fecha DATE,
	FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE detalle_pedidos(
	id INT PRIMARY KEY IDENTITY,
	pedido_id INT,
	producto_id INT,
	cantidad INT,
	precio DECIMAL(10, 2),
	FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
	FOREIGN KEY (producto_id) REFERENCES productos(id),
);

-- ------------------------INSERTAR DATOS ------------------------
insert into productos (nombre, precio, stock) VALUES
('Cafe',10.00,40),
('Chocolate',10.00,38),
('Pepsi',10.00,15),
('Cereal',25.00,20),
('Coca cola',20.00,20);

Select * from productos;

insert into clientes (nombre, email) VALUES
('Eduardo','eduardo@gmail.com'),
('Andre','eduardo@gmail.com');

Select * from clientes;

-- Registrar Ventas

CREATE PROCEDURE RegistrarVenta
	@nombre_cliente VARCHAR(100),
	@nombre_producto VARCHAR(100),
	@cantidad INT
AS
BEGIN
	-- INICIO DE LA TRANSACCION
	BEGIN TRANSACTION;
	DECLARE @cliente_id INT;
	DECLARE @producto_id INT;
	DECLARE @pedido_id INT;

	SELECT @cliente_id = id FROM clientes where	nombre = @nombre_cliente;

	IF @cliente_id IS NULL
	BEGIN
		ROLLBACK;
		PRINT 'NO SE HA ENCONTRADO EL CLIENTE';
		RETURN;
	END

	SELECT @producto_id = id FROM productos where nombre = @nombre_producto;

	IF @producto_id IS NULL
	BEGIN
		ROLLBACK;
		PRINT 'NO SE HA ENCONTRADO EL PRODUCTO';
		RETURN;
	END

	IF(SELECT stock FROM productos where id = @producto_id) >= @cantidad
	BEGIN
		-- INSERTAR EL NUEVO PEDIDO
		INSERT INTO pedidos(cliente_id, fecha) VALUES (@cliente_id, GETDATE());
		SET @pedido_id = SCOPE_IDENTITY(); -- RETORNA EL ULTIMO VALOR IDENTITY

		-- INSERTAR EN DETALLES DEL PEDIDO
		insert into detalle_pedidos(pedido_id, producto_id, cantidad, precio)
		values (@pedido_id, @producto_id, @cantidad, (SELECT precio from productos WHERE id = @producto_id)* @cantidad);

		-- Actualizar Stock producto
		UPDATE productos set stock = stock - @cantidad where id = @producto_id;
		COMMIT;
		PRINT 'VENTA REGISTRADA CON EXITO';
	END
	ELSE
	BEGIN
		ROLLBACK;
		PRINT 'STOCK INSUFICIENTE';
	END	
END;

EXEC RegistrarVenta @nombre_cliente = 'Andre', @nombre_producto  = 'Cafe', @cantidad = 2;
DROP PROCEDURE RegistrarVenta;

-- CANCELAR PEDIDO

CREATE PROCEDURE CancelarPedido
	@pedido_id INT
AS
BEGIN
	-- inicio de la transaccion
	BEGIN TRANSACTION;
		IF NOT EXISTS (SELECT 1 FROM pedidos where id = @pedido_id)
		BEGIN
			ROLLBACK;
			PRINT 'NO SE HA ENCONTRADO EL PEDIDO';
			RETURN; 
		END

		-- REVERTIR EL STOCK 
		update productos set stock = stock + dp.cantidad
		from productos p
		JOIN detalle_pedidos dp on p.id = dp.producto_id
		where dp.pedido_id = @pedido_id;

		-- eliminar detalles del pedido
		DELETE  from detalle_pedidos where pedido_id = @pedido_id;

		-- eliminar el pedido
		DELETE  from pedidos where id = @pedido_id;

		IF @@ERROR = 0
		BEGIN
			COMMIT;
			PRINT 'PEDIDO CANCELADO CORRECTAMENTE';
		END
		ELSE
		BEGIN
			ROLLBACK;
			PRINT 'ERROR AL CANCELAR EL PEDIO';
		END;
END;

EXEC CancelarPedido @pedido_id= 1;

Select * from productos;
Select * from clientes;
Select * from pedidos;
Select * from detalle_pedidos;
