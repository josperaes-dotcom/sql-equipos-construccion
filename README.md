# Sistema de Gestión para Alquiler de Equipos de Construcción

Repositorio de mi proyecto de bases de datos con base al dominio de alquiles de maquinas o equipos de construccion.

## Datos del Aprendiz
* **Nombre:** Jose Luis Guerreo
* **Programa:** Tecnológica en ADSO (Análisis y Desarrollo de Software)
* **Institución:** SENA
* **Motor:** PostgreSQL


## Dominio

El dominio se divide en cuatro procesos operativos reales que guardan una relación directa entre sí dentro de la base de datos:

1.  **Registro de Clientes:** Todo empieza con las personas o empresas que necesitan las máquinas. De ellos guardo sus datos básicos obligatorios, su documento de identidad único y su correo electrónico para poder contactarlos y facturarles.
2.  **Inventario de Equipos y Categorías:** Registro cada máquina, andamio o herramienta que tengo en bodega. Para que que no sea un desorden, se clasifica los equipos en categorías (como Maquinaria Pesada o Energía). Cada equipo tiene un precio fijo de cobro por cada día que pase en una obra y un estado actual (Disponible, Alquilado o Mantenimiento).
3.  **Control de Alquileres (Transacciones):** Cuando un cliente se lleva un equipo, abro un registro de alquiler. Aquí amarro al cliente con la máquina, y guardo la fecha en la que se la lleva y el día en que debe devolverla. El sistema calcula el costo total multiplicando los días de uso por la tarifa diaria del equipo. También controlo si el dinero está pendiente, pagado o si el plazo ya se venció.
4.  **Historial de Mantenimientos:** Las máquinas se desgastan o se dañan. Cuando un equipo entra al taller para una reparación o revisión preventiva, cambio su estado a 'Mantenimiento' y registro detalladamente qué se le hizo y cuánto dinero costó esa reparación. Esto me permite saber si una máquina está dando ganancias o solo pérdidas.

---

## Estructura del Repositorio
* `README.md`: Este archivo con la presentación general del proyecto y la explicación básica del negocio.
* `/0X-semana/entrega.sql`: Es cada entrega de consulta correspondiente al ejercicio propuesto por el profe en el repositorio. 
* `/mis-docs/01-codigo-estructura-db.sql`: Documento de toda la estructura de la bd, que me sirve como documentacion por si no entiendo algo.
* `/mis-docs/02-codigo-datos-bd.sql`: Documento con todos lso registros de cada tabla
"""
