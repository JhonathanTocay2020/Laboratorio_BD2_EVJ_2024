create database clase4;
use clase4;

CREATE TABLE productos (
    id INT PRIMARY KEY IDENTITY,
    nombre VARCHAR(100),
    precio DECIMAL(10, 2),
    stock INT
);

CREATE TABLE clientes (
    id INT PRIMARY KEY IDENTITY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY IDENTITY,
    cliente_id INT,
    fecha DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE detalle_pedidos (
    id INT PRIMARY KEY IDENTITY,
    pedido_id INT,
    producto_id INT,
    cantidad INT,
    precio DECIMAL(10, 2),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

--  --------------------------- INSERTAR DATOS ---------------------------
-- Insertar datos en la tabla productos
INSERT INTO productos (nombre, precio, stock) VALUES
('Laptop XYZ', 1000.00, 50),
('Smartphone ABC', 500.00, 100),
('Tablet DEF', 300.00, 75);

-- Insertar datos en la tabla clientes
INSERT INTO clientes (nombre, email) VALUES
('Juan Pérez', 'juan.perez@example.com'),
('Ana Gómez', 'ana.gomez@example.com'),
('Carlos Díaz', 'carlos.diaz@example.com');