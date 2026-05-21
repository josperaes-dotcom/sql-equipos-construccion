--Tabla de Categorías de Equipos
CREATE TABLE categorias_equipos (
    categoria_id SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);


-- Tabla de Clientes
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    documento VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT CURRENT_DATE
);


--Tabla de Equipos (Actualizada con FK a Categorías)
CREATE TABLE equipos (
    equipo_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria_id INT NOT NULL, -- Ahora es una relación numérica con la tabla de categorías
    tarifa_diaria NUMERIC(10, 2) NOT NULL CONSTRAINT chk_tarifa_diaria CHECK (tarifa_diaria > 0),
    estado VARCHAR(20) DEFAULT 'Disponible' CONSTRAINT chk_estado CHECK (estado IN ('Disponible', 'Alquilado', 'Mantenimiento')),
    fecha_compra DATE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_equipos(categoria_id) ON DELETE RESTRICT
);

--Tabla de Alquileres (Corregida con equipo_id)
CREATE TABLE alquileres (
    alquiler_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    equipo_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    costo_total NUMERIC(10, 2) NOT NULL DEFAULT 0,
    estado_pago VARCHAR(20) DEFAULT 'Pendiente' CONSTRAINT chk_estado_pago CHECK (estado_pago IN ('Pendiente', 'Pagado', 'Vencido')),
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE RESTRICT,
    FOREIGN KEY (equipo_id) REFERENCES equipos(equipo_id) ON DELETE RESTRICT,
    CONSTRAINT chk_fechas_coherentes CHECK (fecha_fin >= fecha_inicio)
);


--Tabla de Mantenimientos
CREATE TABLE mantenimientos (
    mantenimiento_id SERIAL PRIMARY KEY,
    equipo_id INT NOT NULL,
    fecha_mantenimiento DATE NOT NULL,
    descripcion TEXT NOT NULL,
    costo NUMERIC(10, 2) NOT NULL CONSTRAINT chk_costo_mantenimiento CHECK (costo >= 0),
    FOREIGN KEY (equipo_id) REFERENCES equipos(equipo_id) ON DELETE CASCADE
);