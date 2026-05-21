# Documentación Del dominio

En este documento explico paso a paso cómo diseñé la estructura de nuestra base de datos para el negocio de alquiler de maquinaria. Mi objetivo aquí es dejar claro por qué elegí cada tipo de dato, qué lógica tienen las restricciones (constraints) y cómo funciona la cardinalidad entre las tablas para que cualquiera que lea el código entienda el sistema de inmediato.

## 1. Explicación de la Cardinalidad (¿Cómo se conectan las tablas?)

Antes de mirar el código, necesito explicar cómo se relacionan las tablas en la vida real. La cardinalidad es simplemente definir cuántos registros de una tabla se pueden asociar con los de otra. En nuestro sistema uso principalmente la relación **Uno a Muchos (1:N)**.

### A. Categorías y Equipos (Relación 1:N)

- **En una dirección:** Una categoría (ej. 'Maquinaria Pesada') puede tener **muchos** equipos registrados (excavadoras, retroexcavadoras, volquetas).
- **En la dirección opuesta:** Un equipo específico (ej. Excavadora CAT-320) pertenece a **una sola** categoría.
- **La regla:** La llave foránea (`categoria_id`) la pongo en la tabla `equipos` (el lado de los "muchos").

### B. Clientes y Alquileres (Relación 1:N)

- **En una dirección:** Un cliente constante puede registrar **muchos** alquileres a lo largo del año.
- **En la dirección opuesta:** Un recibo de alquiler específico le pertenece a **un solo** cliente.
- **La regla:** La llave foránea (`cliente_id`) vive en la tabla `alquileres`.

### C. Equipos y Alquileres (Relación 1:N)

- **En una dirección:** Una máquina (ej. un taladro) se puede alquilar **muchas** veces en su vida útil (hoy se la lleva un cliente, la devuelve, y la otra semana se la lleva otro).
- **En la dirección opuesta:** En una fila específica de transacción de alquiler, se registra **un solo** equipo.
- **La regla:** La llave foránea (`equipo_id`) se ubica en la tabla `alquileres`.

### D. Equipos y Mantenimientos (Relación 1:N)

- **En una dirección:** Una máquina puede entrar al taller **muchas** veces por fallas o revisiones.
- **En la dirección opuesta:** Un registro de mantenimiento en el taller le corresponde a **una sola** máquina.
- **La regla:** La llave foránea (`equipo_id`) va en la tabla `mantenimientos`.

---

## 2. Explicación de las Tablas Paso a Paso (DDL)

A continuación, muestro el script completo y te explico el porqué de cada decisión técnica que tomé:

```sql
--Tabla de Categorías de Equipos
CREATE TABLE categorias_equipos (
    categoria_id SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);
```

### ¿Por qué la diseñé así?

- `categoria_id SERIAL PRIMARY KEY`: Uso `SERIAL` para que PostgreSQL cree los números de forma automática (`1, 2, 3...`). Es la llave primaria (PK) porque necesito un identificador único e irrepetible para cada categoría.
- `nombre_categoria VARCHAR(50) NOT NULL UNIQUE`: Uso `VARCHAR(50)` porque los nombres de las categorías son cortos (no pasan de 50 letras). Le pongo `NOT NULL` porque una categoría no puede existir sin nombre, y `UNIQUE` para evitar que alguien cree dos veces la categoría `'Herramientas'`.
- `descripcion TEXT`: Uso `TEXT` porque las descripciones pueden ser largas y detalladas, y no quiero limitar el espacio de escritura. Al no tener `NOT NULL`, este campo es opcional (`NULL`).

```sql
--Tabla de Clientes
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    documento VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT CURRENT_DATE
);
```

### ¿Por qué la diseñé así?

- `documento VARCHAR(20) UNIQUE NOT NULL`: Guardo la cédula o NIT como texto (`VARCHAR`) porque no voy a hacer operaciones matemáticas con este número. Es `UNIQUE` porque dos clientes no pueden tener el mismo documento y `NOT NULL` porque es el dato legal obligatorio para el contrato.
- `nombre y apellido VARCHAR(50) NOT NULL`: Espacio suficiente para los nombres reales. Obligatorios para saber a quién le estoy prestando la maquinaria.
- `correo VARCHAR(100) UNIQUE NOT NULL`: El correo electrónico es indispensable para enviar facturas. Debe ser único para evitar perfiles duplicados en el sistema.
- `telefono VARCHAR(20)`: Lo dejo opcional (puede ser `NULL`) por si el cliente no tiene o no quiere dar un número fijo, y uso `VARCHAR` para poder guardar prefijos o espacios.
- `fecha_registro DATE DEFAULT CURRENT_DATE`: Tipo `DATE` porque solo me interesa el día, mes y año. Uso `DEFAULT CURRENT_DATE` para que, si no le pongo la fecha manualmente, el sistema registre el día exacto de hoy de forma automática.

```sql
--Tabla de Equipos
CREATE TABLE equipos (
    equipo_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria_id INT NOT NULL,
    tarifa_diaria NUMERIC(10, 2) NOT NULL CONSTRAINT chk_tarifa_diaria CHECK (tarifa_diaria > 0),
    estado VARCHAR(20) DEFAULT 'Disponible' CONSTRAINT chk_estado CHECK (estado IN ('Disponible', 'Alquilado', 'Mantenimiento')),
    fecha_compra DATE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_equipos(categoria_id) ON DELETE RESTRICT
);
```

### ¿Por qué la diseñé así?

- `categoria_id INT NOT NULL`: Es un número entero que sirve para conectar esta tabla con la de categorías. Es obligatorio (`NOT NULL`) porque toda máquina debe estar clasificada.
- `tarifa_diaria NUMERIC(10, 2) NOT NULL`: Para precios utilizo siempre `NUMERIC`. El `(10, 2)` significa que el precio puede ser de hasta 10 dígitos en total, incluyendo 2 decimales para los centavos.
- `CONSTRAINT chk_tarifa_diaria CHECK (tarifa_diaria > 0)`: Esto es una restricción de control. Evita errores humanos impidiendo que se registre un equipo con precio de `$0` o con valores negativos.
- `CONSTRAINT chk_estado CHECK (...)`: Esta restricción limita lo que se puede escribir en la columna `estado`. El sistema solo aceptará las palabras exactas: `'Disponible'`, `'Alquilado'` o `'Mantenimiento'`. Si escribes otra cosa, rebota.
- `FOREIGN KEY (...) REFERENCES ... ON DELETE RESTRICT`: Es la regla de integridad de la relación. El `ON DELETE RESTRICT` significa que si intento borrar una categoría (por ejemplo, `'Herramientas'`) pero resulta que tengo equipos amarrados a ella, el sistema me frena y bloquea el borrado para no dejar datos huérfanos.

```sql
--Tabla de Alquileres
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
```

### ¿Por qué la diseñé así?

- `cliente_id y equipo_id INT NOT NULL`: Las dos llaves foráneas indispensables. Un alquiler no existe si no sé qué cliente se llevó la máquina y qué equipo específico sacó de la bodega.
- `CONSTRAINT chk_fechas_coherentes CHECK (fecha_fin >= fecha_inicio)`: Esta restricción asegura la lógica del tiempo en el negocio. No permite que la fecha de devolución sea menor o anterior al día en que empezó el alquiler.
- `FOREIGN KEY (...) ON DELETE RESTRICT`: Protege los contratos. Si un cliente tiene un historial de alquileres en esta tabla, el sistema no me dejará borrar al cliente de la base de datos a menos que borre primero sus transacciones. Así evito perder el rastro de las cuentas.

```sql
--Tabla de Mantenimientos
CREATE TABLE mantenimientos (
    mantenimiento_id SERIAL PRIMARY KEY,
    equipo_id INT NOT NULL,
    fecha_mantenimiento DATE NOT NULL,
    descripcion TEXT NOT NULL,
    costo NUMERIC(10, 2) NOT NULL CONSTRAINT chk_costo_mantenimiento CHECK (costo >= 0),
    FOREIGN KEY (equipo_id) REFERENCES equipos(equipo_id) ON DELETE CASCADE
);
```

### ¿Por qué la diseñé así?

- `descripcion TEXT NOT NULL`: Uso `TEXT` porque el mecánico necesita explicar con detalle qué se dañó y qué repuestos compró. Es obligatorio porque requiero saber en qué se gastó el dinero de la empresa.
- `CONSTRAINT chk_costo_mantenimiento CHECK (costo >= 0)`: El costo del arreglo debe ser cero (si entró por garantía) o un número positivo. No puede ser un gasto negativo.
- `FOREIGN KEY (equipo_id) REFERENCES equipos(equipo_id) ON DELETE CASCADE`: Aquí utilicé `ON DELETE CASCADE` por pura lógica de limpieza: si vendo o doy de baja un equipo viejo y decido borrarlo por completo de la tabla `equipos`, no me interesa conservar su historial de reparaciones viejas. El sistema borrará automáticamente todos sus mantenimientos en cadena.