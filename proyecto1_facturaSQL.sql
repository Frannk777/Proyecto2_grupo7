USE facturacion;

-- Parte 1

-- ¿Cuántos registros existen en la tabla de clientes?
select count(*) as cantidad_clientes from customers;

-- ¿Cuántas facturas hay registradas en total?
select count(*) as cantidad_facturas from invoices;

-- ¿Cuántos productos diferentes están disponibles?
select count(distinct product_id) as productos_diferentes from products;

-- Muestra la estructura de la tabla de detalles de factura (campos y tipos de datos).
describe invoices;

-- Parte 2

-- ¿Cuál es el cliente con mayor monto total de compras?
select c.customer_id, c.first_name, c.last_name, sum(it.qty * it.amount) as monto_total_compras from customers c
inner join (invoices i, invoice_items it)
on(c.customer_id = i.customer_id and i.invoice_id = it.invoice_id)
group by c.customer_id
order by monto_total_compras desc
limit 1;

-- ¿Muestre el top 5 de ciudades que han generado un mayor número de facturas?
select c.city, count(distinct i.invoice_id) as numero_facturas from customers c
inner join (invoices i, invoice_items it)
on(c.customer_id = i.customer_id and i.invoice_id = it.invoice_id)
group by c.city
order by numero_facturas desc
limit 5;

-- ¿Qué categoría de productos concentra el mayor volumen de ventas (en monto total)?
select c.category_name , sum(it.qty * it.amount) as monto_total_ventas from categories c
inner join(products p, invoice_items it)
on(c.category_id = p.category_id and p.product_id = it.product_id)
group by p.category_id
order by monto_total_ventas desc;

-- ¿Cuál es el producto más vendido por cantidad de unidades?
select p.product_name, sum(it.qty) as cantidad_unidades_vendidas from products p
inner join(invoice_items it)
using(product_id)
group by p.product_id
order by cantidad_unidades_vendidas desc
limit 1;

-- ¿Cómo ha variado el número de facturas emitidas por año y mes?
select  year(invoice_date) as Anio,
		month(invoice_date) as Mes,
        count(distinct invoice_id) as cantidad_facturas_emitidas
from invoices i
group by Mes, Anio
order by anio asc, mes asc;

-- ¿Cúantos clientes han comprado productos de más de una categoría diferente?

SELECT
    COUNT(customer_id) AS total_clientes_con_multiples_categorias_compradas
FROM (
    SELECT i.customer_id FROM invoices i
    INNER JOIN (invoice_items it, products p)
    ON (i.invoice_id = it.invoice_id and it.product_id = p.product_id)
    GROUP BY i.customer_id
    HAVING COUNT(DISTINCT p.category_id) > 1
) AS tabla_intermedia;

-- Parte 3
-- Escoger 1 pregunta de la parte 2 
-- 6) Top 5 de ciudades que han generado un mayor número de facturas
select c.city, count(distinct i.invoice_id) as numero_facturas from customers c
inner join (invoices i, invoice_items it)
on(c.customer_id = i.customer_id and i.invoice_id = it.invoice_id)
group by c.city
order by numero_facturas desc
limit 5;

-- PREGUNTAS INDIVIDUALES

-- 1. ¿Qué producto generó el mayor ingreso total en todas las facturas?

SELECT p.product_name AS producto,
SUM(it.amount) AS ingreso_total
FROM products p
JOIN invoice_items it ON p.product_id = it.product_id
GROUP
BY p.product_id
ORDER BY ingreso_total DESC
LIMIT 1;

-- 2. ¿QUE CLIENTES HAN REALIZADO SOLO UNA COMPRA?
SELECT
    c.customer_id,
    c.first_name,
    c.email,
    COUNT(i.invoice_id) AS NumeroDeCompras
FROM
    customers AS c
JOIN
    invoices AS i ON c.customer_id = i.customer_id
GROUP BY
    c.customer_id, c.first_name, c.email
HAVING
    COUNT(i.invoice_id) = 1;

-- 3. ¿Cuales son los cliente con el mayor número de productos distintos comprados?
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT it.product_id) AS cantidad_productos_distintos
FROM customers c
INNER JOIN invoices i ON c.customer_id = i.customer_id
INNER JOIN invoice_items it ON i.invoice_id = it.invoice_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT it.product_id) = (
    SELECT 
        MAX(cantidad_productos_distintos)
    FROM (
        SELECT 
            c.customer_id,
            COUNT(DISTINCT it.product_id) AS cantidad_productos_distintos
        FROM customers c
        INNER JOIN invoices i ON c.customer_id = i.customer_id
        INNER JOIN invoice_items it ON i.invoice_id = it.invoice_id
        GROUP BY c.customer_id
    ) AS subquery
);

-- 4. ¿Top categorías ordenadas de manera descendente que tienen el mayor ticket promedio por cliente?

SELECT 
    cat.category_name as categoria,
    ROUND(SUM(it.amount) / COUNT(DISTINCT i.customer_id), 2) AS ticket_promedio_cliente
FROM invoice_items it
JOIN products p ON it.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
JOIN invoices i ON it.invoice_id = i.invoice_id
GROUP BY cat.category_name
ORDER BY ticket_promedio_cliente DESC;

-- 5. Para cada cliente, ¿cuál fue la fecha de su primera y su última compra?
select c.customer_id, c.first_name, c.last_name,
		min(i.invoice_date) as Primera_Compra,
        max(i.invoice_date) as Ultima_Compra
from customers c
inner join(invoices i)
using(customer_id)
group by c.customer_id
order by c.customer_id;
