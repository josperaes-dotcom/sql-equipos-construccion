-- ============================================
-- PROYECTO SEMANAL: JOINs aplicados a tu dominio
-- Semana 09 — INNER JOIN y LEFT JOIN
-- ============================================

-- NOTA: Adaptado al dominio real de Alquiler de Equipos de Construcción.
-- Tablas reales del esquema: categorias_equipos, equipos, alquileres.

-- ============================================
-- CONSULTA 1: INNER JOIN principal
-- OBJETIVO: Une las dos tablas más importantes (equipos y alquileres).
--           Muestra solo los equipos que SÍ han sido alquilados.
-- ============================================
SELECT
    eq.nombre       AS equipo,
    al.fecha_inicio AS fecha_alquiler,
    al.costo_total  AS total_pagado
FROM equipos eq
INNER JOIN alquileres al ON al.equipo_id = eq.equipo_id;


-- ============================================
-- CONSULTA 2: JOIN con tres tablas
-- OBJETIVO: Encadena equipos + alquileres + categorias_equipos
--           para ver el detalle completo de la transacción con su categoría.
-- ============================================
SELECT
    eq.nombre           AS equipo,
    cat.nombre_categoria AS categoria,
    al.fecha_inicio     AS fecha_alquiler
FROM equipos eq
INNER JOIN categorias_equipos cat ON eq.categoria_id = cat.categoria_id
INNER JOIN alquileres al      ON al.equipo_id    = eq.equipo_id;


-- ============================================
-- CONSULTA 3: LEFT JOIN — todos los registros
-- OBJETIVO: Obtén todos los equipos aunque no tengan alquileres registrados.
--           (Aquí los equipos sin historial aparecerán con valores NULL en la derecha).
-- ============================================
SELECT
    eq.nombre       AS equipo,
    al.fecha_inicio AS fecha_actividad,
    COALESCE(al.costo_total, 0.00) AS monto
FROM equipos eq
LEFT JOIN alquileres al ON al.equipo_id = eq.equipo_id;


-- ============================================
-- CONSULTA 4: Detectar huérfanos (registros sin actividad)
-- OBJETIVO: Muestra SOLO los equipos que nunca se han alquilado en el sistema.
-- ============================================
SELECT
    eq.nombre AS equipo_sin_actividad
FROM equipos eq
LEFT JOIN alquileres al ON al.equipo_id = eq.equipo_id
WHERE al.alquiler_id IS NULL;


-- ============================================
-- CONSULTA 5: Reporte agregado con LEFT JOIN + COUNT
-- OBJETIVO: Cantidad de alquileres por equipo (incluye los que tienen cero).
-- ============================================
SELECT
    eq.nombre        AS equipo,
    COUNT(al.alquiler_id) AS total_alquileres
FROM equipos eq
LEFT JOIN alquileres al ON al.equipo_id = eq.equipo_id
GROUP BY eq.nombre
ORDER BY total_alquileres DESC;