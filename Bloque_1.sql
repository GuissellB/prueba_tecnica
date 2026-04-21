-- ============================================================
-- BLOQUE 1 — SQL AVANZADO
-- Prueba Técnica · Data Analyst · Retail Multiformato
-- Motor: MySQL
-- ============================================================
 
-- ============================================================
-- QUERY 1: Ventas Comparables (Comp Sales) — YoY
-- Métrica estándar de retail
-- Solo tiendas con más de 13 meses de operación
-- GMV año actual vs anterior, por país y formato
-- ============================================================
with base_ventas as(
    SELECT 
    t.store_id,
	t.country,
	t.format,
	YEAR(trn.transaction_date) AS anio,
    MONTH(trn.transaction_date) AS mes,
	ROUND(SUM(total_amount),2) AS venta
    FROM transactions trn
    INNER JOIN stores t
	ON t.store_id = trn.store_id
	WHERE TIMESTAMPDIFF(MONTH, opening_date, CURDATE()) >= 13 
    GROUP BY 1,2,3,4,5
)

SELECT 
a.anio as anio_actual,
b.anio as anio_anterior,
a.mes,
a.store_id,
a.country,
a.format,
a.venta AS Venta_actual,
b.venta AS Venta_anterior,
ROUND((a.venta - b.venta) / b.venta * 100, 2) AS sales_growth_pct,
RANK() OVER (PARTITION BY a.format ORDER BY ROUND((a.venta - b.venta) / b.venta * 100, 2) DESC) AS ranking_formato
FROM base_ventas a
INNER JOIN base_ventas b
on a.store_id = b.store_id
and a.anio = b.anio + 1
and a.mes = b.mes;

-- ============================================================
-- QUERY 2: Productividad por Metro Cuadrado
-- KPI operativo — último trimestre disponible
-- ============================================================
WITH ultima_fecha AS (
    SELECT 
    YEAR(MAX(transaction_date)) AS ultimo_anio,
    QUARTER(MAX(transaction_date)) AS ultimo_qrt,
    MAX(transaction_date) AS fecha_max
    FROM transactions
),
base_ventas as(
    SELECT 
    t.store_id,
	t.country,
	t.format,
	YEAR(trn.transaction_date) AS anio,
    QUARTER(trn.transaction_date) AS Qrt,
    size_sqm,
	ROUND(SUM(total_amount),2) AS venta
    FROM transactions trn
    INNER JOIN stores t
	ON t.store_id = trn.store_id
    GROUP BY 1,2,3,4,5,6
)

SELECT 
a.anio,
a.Qrt,
a.store_id,
a.country,
a.format,
a.venta,
a.size_sqm,
(venta/size_sqm) VENTA_M2,
RANK() OVER (PARTITION BY a.format ORDER BY (venta/size_sqm) DESC)  AS ranking_formato,
PERCENT_RANK() OVER (PARTITION BY a.format ORDER BY (venta/size_sqm)) AS ranking_pct_25,
CASE 
    WHEN PERCENT_RANK() OVER (PARTITION BY a.format ORDER BY (venta/size_sqm)) <= 0.25 
    THEN 'BAJO_RENDIMIENTO'
    ELSE 'NORMAL'
END AS categoria_rendimiento
FROM base_ventas a
CROSS JOIN ultima_fecha u
WHERE a.anio = ultimo_anio
AND a.Qrt = ultimo_qrt;


-- ============================================================
-- QUERY 3: Cohortes de Clientes con Tarjeta de Lealtad
-- Retención mensual por cohorte
-- ============================================================
WITH primera_compra AS (
    SELECT
	customer_id,
	MIN(transaction_date) AS fecha_primera_compra,
	DATE_FORMAT(MIN(transaction_date), '%Y-%m') AS cohorte
    FROM transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),

base_cohorte AS (
    SELECT cohorte, COUNT(DISTINCT customer_id) AS total_clientes
    FROM primera_compra
    GROUP BY cohorte
),

base as (
SELECT
p.customer_id,
p.cohorte,
TIMESTAMPDIFF(MONTH, p.fecha_primera_compra, t.transaction_date) AS dif_mes_inicial,
T.total_amount 
FROM primera_compra p
JOIN transactions t ON p.customer_id = t.customer_id
WHERE p.customer_id IS NOT NULL
),

calculos as (
SELECT
    cohorte,
    dif_mes_inicial,
    COUNT(DISTINCT customer_id) AS clientes_activos,
    AVG(total_amount) AS ticket_promedio
FROM base
WHERE dif_mes_inicial IN (0, 1, 2, 3, 6)
GROUP BY cohorte, dif_mes_inicial
),

pivot AS (
SELECT
c.cohorte,
c.dif_mes_inicial,
c.clientes_activos,
cc.total_clientes,
ROUND(c.clientes_activos / cc.total_clientes * 100, 2) AS tasa_retencion_pct,
ROUND(ticket_promedio, 2) AS ticket_promedio
FROM calculos c
LEFT JOIN base_cohorte cc ON c.cohorte = cc.cohorte 
)

SELECT
    cohorte,
    MAX(total_clientes)  AS total_cohorte,
    MAX(ticket_promedio) AS ticket_promedio,
    MAX(CASE WHEN dif_mes_inicial = 0 THEN tasa_retencion_pct END) AS mes_0,
    MAX(CASE WHEN dif_mes_inicial = 1 THEN tasa_retencion_pct END) AS mes_1,
    MAX(CASE WHEN dif_mes_inicial = 2 THEN tasa_retencion_pct END) AS mes_2,
    MAX(CASE WHEN dif_mes_inicial = 3 THEN tasa_retencion_pct END) AS mes_3,
    MAX(CASE WHEN dif_mes_inicial = 6 THEN tasa_retencion_pct END) AS mes_6
FROM pivot
GROUP BY cohorte;


-- ============================================================
-- QUERY 4: GMROI por Proveedor y Categoría
-- Gross Margin Return on Investment
-- GMROI = Margen Bruto / Costo Total
-- ============================================================

SELECT
v.vendor_name,
p.category,
ROUND(SUM(ti.quantity * ti.unit_price), 2) AS GMV,
ROUND(SUM(ti.quantity * p.cost), 2) AS costo_total,
ROUND(SUM(ti.quantity * (ti.unit_price - p.cost)), 2) AS margen_bruto,
ROUND(SUM(ti.quantity * (ti.unit_price - p.cost))/ NULLIF(SUM(ti.quantity * p.cost), 0), 4) AS GMROI,
COUNT(DISTINCT CASE WHEN t.status = 'COMPLETED' THEN p.item_id END) AS skus_activos,
ROUND(SUM(ti.quantity)/ NULLIF(DATEDIFF(MAX(t.transaction_date), MIN(t.transaction_date)), 0), 2)  AS velocidad_venta_uds_dia,
CASE WHEN SUM(ti.quantity * (ti.unit_price - p.cost))/ NULLIF(SUM(ti.quantity * p.cost), 0) < 1
	THEN 'GMROI < 1' ELSE 'OK' END alerta_gmroi
from transaction_items ti
JOIN transactions t ON ti.transaction_id = t.transaction_id
JOIN products p ON ti.item_id = p.item_id
JOIN vendors v ON p.vendor_id = v.vendor_id
WHERE t.status = 'COMPLETED'
GROUP BY v.vendor_name, p.category;

-- ============================================================
-- QUERY 5: Detección de Posibles Quiebres de Stock
-- Gap de 3+ días consecutivos sin venta en tienda donde sí vendía
-- ============================================================
#Historicamente si lo vendía, significa un rango ? además ayuda s filtrar cantidad de datos 
with items_historicos AS (
    SELECT 
        store_id, 
        item_id,
        COUNT(DISTINCT DATE(transaction_date)) AS dias_con_venta
    FROM transactions t
    JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
    WHERE t.status = 'COMPLETED'
    GROUP BY store_id, item_id
    HAVING dias_con_venta >= 7
),

ventas_por_dia as (
SELECT DISTINCT
t.store_id,
ti.item_id,
DATE(t.transaction_date) AS fecha_venta
FROM transactions t
JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
JOIN items_historicos ih  
ON t.store_id = ih.store_id 
AND ti.item_id = ih.item_id 
WHERE t.status = 'COMPLETED'
),

ventas_diarias AS (
SELECT
t.store_id,
ti.item_id,
DATE(t.transaction_date) AS fecha,
SUM(ti.quantity) AS unidades_dia
FROM transactions t
JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
WHERE t.status = 'COMPLETED'
GROUP BY t.store_id, ti.item_id, DATE(t.transaction_date)
),

ventas_con_gap AS (
SELECT store_id ,
item_id , 
Fecha_venta ,
LEAD(fecha_venta) OVER ( PARTITION BY store_id, item_id ORDER BY fecha_venta) AS siguiente_venta
FROM ventas_por_dia
)

SELECT 
g.store_id,
g.item_id,
p.category,
g.fecha_venta AS fecha_inicio_gap,
g.siguiente_venta AS fecha_fin_gap,
DATEDIFF(siguiente_venta, fecha_venta) AS dias_sin_venta,
AVG(vd.unidades_dia) AS ventas_promedio_diarias
FROM ventas_con_gap g
JOIN products p ON g.item_id = p.item_id
JOIN ventas_diarias vd 
ON g.store_id = vd.store_id
AND g.item_id = vd.item_id
AND vd.fecha < g.fecha_venta  
WHERE DATEDIFF(g.siguiente_venta, g.fecha_venta) >= 3
AND g.siguiente_venta IS NOT NULL
GROUP BY g.store_id, g.item_id, p.category, g.fecha_venta, g.siguiente_venta;

-- ============================================================
-- QUERY 6: Impacto de Promociones en Ticket y Volumen
-- Basket Analysis — promo vs no promo por categoría
-- ============================================================
with base as (SELECT
ti.transaction_id,
p.category,
MAX(CASE WHEN ti.was_on_promo = TRUE THEN 1 ELSE 0 END) AS tuvo_promo,
SUM(ti.quantity) AS unidades,
t.total_amount
FROM transaction_items ti
JOIN products p ON ti.item_id = p.item_id
JOIN transactions t ON ti.transaction_id = t.transaction_id
WHERE t.status = 'COMPLETED'
GROUP BY ti.transaction_id, p.category, t.total_amount
)
SELECT
    category,
    CASE WHEN tuvo_promo = 1 THEN 'CON_PROMO' ELSE 'SIN_PROMO' END AS tipo,
    ROUND(AVG(total_amount), 2) AS ticket_promedio,
    ROUND(AVG(unidades), 2) AS unidades_promedio,
    COUNT(DISTINCT transaction_id) AS num_transacciones
FROM  base
GROUP BY category, tuvo_promo
ORDER BY category, tuvo_promo DESC





