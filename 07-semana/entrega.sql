-- ============================================
-- PROYECTO SEMANAL: NULL y Constraints
-- Semana 07 — NOT NULL, UNIQUE, CHECK, FK
-- ============================================

-- NOTA: Adaptado al dominio de Alquiler de Equipos de Construcción.

-- Activar claves foráneas (En PostgreSQL ya vienen activadas por defecto, en SQLite se usa el PRAGMA)
-- PRAGMA foreign_keys = ON;

-- ============================================
-- PARTE 1: ESQUEMA CON CONSTRAINTS
-- ============================================

-- Se rea la tabla de categorías/grupos del dominio
--       Incluir: PK, NOT NULL, UNIQUE donde aplique
CREATE TABLE categorias_equipos (
    categoria_id SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

-- TODO: Crear la tabla principal con todos los constraints
--       Incluir: PK, FK, NOT NULL, UNIQUE, CHECK, DEFAULT
CREATE TABLE equipos_detalle (
    equipo_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    serial_placa VARCHAR(30) NOT NULL UNIQUE, -- Columna con UNIQUE (Matrícula/Serial único de la máquina)
    tarifa_diaria NUMERIC(10, 2) NOT NULL CONSTRAINT chk_tarifa CHECK (tarifa_diaria > 0),
    estado VARCHAR(20) DEFAULT 'Disponible' CONSTRAINT chk_estado_equipo CHECK (estado IN ('Disponible', 'Alquilado', 'Mantenimiento')), -- Columna con DEFAULT
    marca_motor VARCHAR(50), -- Columna que acepta valores null
    categoria_id INT NOT NULL REFERENCES categorias_equipos(categoria_id) ON DELETE RESTRICT -- FK
);


-- ============================================
-- PARTE 2: DATOS DE PRUEBA
-- ============================================

-- TODO: Insertar 3 categorías
INSERT INTO categorias_equipos (categoria_id, nombre_categoria, descripcion) VALUES
(1, 'Maquinaria Pesada', 'Equipos grandes para movimiento de tierras y excavación'),
(2, 'Herramientas Eléctricas', 'Equipos menores y herramientas de mano motorizadas'),
(3, 'Sistemas de Energía', 'Generadores y torres de iluminación para obras');

-- TODO: Insertar 6 items, al menos 2 con columna_opcional = NULL
-- Nota: La columna opcional es 'marca_motor' (algunos equipos como andamios o torres LED no llevan motor o no se especifica)
INSERT INTO equipos_detalle (nombre, serial_placa, tarifa_diaria, estado, marca_motor, categoria_id) VALUES
('Excavadora Caterpillar 320', 'CAT320X-9921', 250.00, 'Alquilado', 'Caterpillar', 1),
('Retroexcavadora John Deere', 'JD410K-4412', 280.00, 'Disponible', 'John Deere', 1),
('Martillo Demoledor Bosch', 'BOSCH-HEX-01', 35.00, 'Alquilado', NULL, 2), -- marca_motor es NULL
('Cortadora de Pavimento STIHL', 'STIHL-FS-55', 40.00, 'Disponible', 'Stihl', 2),
('Generador Eléctrico 10KVA', 'GEN-10KVA-88', 80.00, 'Mantenimiento', 'Honda', 3),
('Torre de Iluminación LED', 'TOWER-LED-03', 95.00, 'Disponible', NULL, 3); -- marca_motor es NULL


-- ============================================
-- PARTE 3: CONSULTAS CON NULL
-- ============================================

-- TODO: Mostrar items donde columna_opcional IS NULL
SELECT 
    equipo_id, 
    nombre, 
    serial_placa
FROM equipos_detalle
WHERE marca_motor IS NULL;


-- TODO: Mostrar todos los items usando COALESCE para reemplazar NULL
SELECT
    nombre,
    serial_placa,
    COALESCE(marca_motor, 'No aplica / No especificado') AS motor_display
FROM equipos_detalle;