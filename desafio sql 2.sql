DROP DATABASE IF EXISTS tienda_ropa;

CREATE DATABASE tienda_ropa;
USE tienda_ropa;

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(150),
    correo_electronico VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50),
    stock INT
);

CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR(20),
    total DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

INSERT INTO clientes (id_cliente, nombre, apellido, direccion, correo_electronico, telefono) VALUES
(1, 'Juan',   'Pérez',     'Av. Bolívar, Valencia',      'juan.perez@correo.com',   '0414-1234567'),
(2, 'María',  'Gómez',     'Calle 5, Maracay',           'maria.gomez@correo.com',  '0424-2345678'),
(3, 'Carlos', 'Rodríguez', 'Urb. Los Jardines, Caracas', 'carlos.r@correo.com',     '0412-3456789'),
(4, 'Ana',    'Martínez',  'Av. Libertador, Barquisimeto','ana.martinez@correo.com','0416-4567890'),
(5, 'Luis',   'Fernández', 'Calle Sucre, Maracaibo',     'luis.f@correo.com',       '0426-5678901'),
(6, 'Elena',  'Torres',    'Av. Principal, Mérida',      'elena.t@correo.com',      '0414-6789012');

INSERT INTO productos (id_producto, nombre, descripcion, precio, categoria, stock) VALUES
(1, 'Camiseta Básica Blanca', 'Camiseta de algodón cuello redondo', 25.00,  'Camisetas',  100),
(2, 'Camiseta Estampada',     'Camiseta con diseño gráfico',        30.00,  'Camisetas',   80),
(3, 'Jean Clásico',           'Pantalón jean corte recto',          60.00,  'Pantalones',  50),
(4, 'Chaqueta de Cuero',      'Chaqueta de cuero sintético',       120.00,  'Chaquetas',   20),
(5, 'Zapatillas Deportivas',  'Calzado deportivo unisex',           80.00,  'Calzado',     40),
(6, 'Gorra Negra',            'Gorra ajustable',                    15.00,  'Accesorios',  60);

INSERT INTO pedidos (id_pedido, id_cliente, fecha, estado, total) VALUES
(1001, 1, CURDATE() - INTERVAL 5 DAY,   'Entregado', 110.00),
(1002, 1, CURDATE() - INTERVAL 12 DAY,  'Enviado',    90.00),
(1003, 2, CURDATE() - INTERVAL 20 DAY,  'Pagado',    130.00),
(1004, 3, CURDATE() - INTERVAL 45 DAY,  'Entregado', 120.00),
(1005, 3, CURDATE() - INTERVAL 100 DAY, 'Entregado',  80.00),
(1006, 4, CURDATE() - INTERVAL 200 DAY, 'Entregado',  60.00),
(1007, 1, CURDATE() - INTERVAL 150 DAY, 'Entregado', 120.00),
(1008, 2, CURDATE() - INTERVAL 8 DAY,   'Pendiente',  45.00),
(1009, 5, CURDATE() - INTERVAL 400 DAY, 'Entregado',  25.00),
(1010, 3, CURDATE() - INTERVAL 3 DAY,   'Pagado',    105.00);

INSERT INTO ventas (id_venta, id_pedido, id_producto, cantidad, precio_venta) VALUES
(1,  1001, 1, 2, 25.00),
(2,  1001, 3, 1, 60.00),
(3,  1002, 2, 3, 30.00),
(4,  1003, 1, 4, 25.00),
(5,  1003, 6, 2, 15.00),
(6,  1004, 4, 1, 120.00),
(7,  1005, 5, 1, 80.00),
(8,  1006, 2, 2, 30.00),
(9,  1007, 3, 2, 60.00),
(10, 1009, 1, 1, 25.00),
(11, 1010, 5, 1, 80.00),
(12, 1010, 1, 1, 25.00);

SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM pedidos;
SELECT * FROM ventas;

SELECT DISTINCT
       CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
       c.direccion,
       c.correo_electronico
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.fecha >= CURDATE() - INTERVAL 30 DAY;

SELECT pr.nombre AS producto,
       SUM(v.cantidad) AS cantidad_vendida,
       SUM(v.cantidad * v.precio_venta) AS total_vendido
FROM ventas v
INNER JOIN pedidos pe ON v.id_pedido = pe.id_pedido
INNER JOIN productos pr ON v.id_producto = pr.id_producto
WHERE pe.fecha >= CURDATE() - INTERVAL 30 DAY
GROUP BY pr.id_producto, pr.nombre
ORDER BY cantidad_vendida DESC;

SELECT CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
       COUNT(p.id_pedido) AS cantidad_pedidos
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.fecha >= CURDATE() - INTERVAL 1 YEAR
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY cantidad_pedidos DESC;

-- Workbench bloquea UPDATE/DELETE cuyo WHERE no use la clave primaria (error 1175)
SET SQL_SAFE_UPDATES = 0;

SELECT id_producto, nombre, categoria, precio
FROM productos
WHERE categoria = 'Camisetas';

UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Camisetas';

SELECT id_producto, nombre, categoria, precio
FROM productos
ORDER BY categoria;

SELECT * FROM pedidos
WHERE id_pedido NOT IN (SELECT id_pedido FROM ventas);

DELETE FROM pedidos
WHERE id_pedido NOT IN (SELECT id_pedido FROM ventas);

SELECT * FROM pedidos;

SET SQL_SAFE_UPDATES = 1;

CREATE OR REPLACE VIEW vista_clientes_pedidos AS
SELECT CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
       p.fecha AS fecha_pedido,
       p.total AS total_pedido
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente;

SELECT * FROM vista_clientes_pedidos;