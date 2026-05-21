-- ============================================
-- PROYECTO SEMANAL: Funciones de Agregación
-- Semana 06 — COUNT, SUM, AVG, GROUP BY, HAVING
-- ============================================

-- ============================================
-- REPORTE 1: Totales globales
-- Se cuenta todo los alquileres, se suma la columna costo_total y el promedio de la misma columna, pero redondeando
SELECT
    COUNT(*)               AS total_alquileres_realizados,
    SUM(costo_total)       AS ingresos_totales_alquiler,
    ROUND(AVG(costo_total), 2) AS promedio_por_alquiler
FROM alquileres;


-- ============================================
-- REPORTE 2: Extremos
-- ============================================
-- Se obtiene cuál ha sido el costo de mantenimiento más barato (MIN) 
--           y cuál ha sido el más caro (MAX) registrado en el taller.
SELECT
    MIN(costo) AS costo_mantenimiento_minimo,
    MAX(costo) AS costo_mantenimiento_maximo
FROM mantenimientos;


-- ============================================
-- REPORTE 3: Subtotales por categoría (GROUP BY)
-- ============================================
-- Se agrupa los equipos por su categoría (Maquinaria Pesada, Herramientas, etc.) 
--           para saber cuántos equipos tenemos en cada una y cuál es su tarifa diaria promedio.
SELECT
    categoria,
    COUNT(*)                  AS total_equipos,
    ROUND(AVG(tarifa_diaria), 2) AS tarifa_promedio_diaria
FROM equipos
GROUP BY categoria
ORDER BY total_equipos DESC;


-- ============================================
-- REPORTE 4: Filtro de grupos (HAVING)
-- ============================================
-- Se muestra las categorías de equipos que tengan más de 5 unidades 
--           registradas en nuestra bodega (usando el umbral de negocio > 5).
SELECT
    categoria,
    COUNT(*) AS total_equipos_en_categoria
FROM equipos
GROUP BY categoria
HAVING COUNT(*) > 5;