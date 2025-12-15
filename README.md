# 📚 Proyecto de Gestión de Biblioteca: DBMS COLLEGE
## Actividad Sumativa - Optimización y Seguridad de Base de Datos

Este proyecto consiste en el rediseño y optimización de los procesos de gestión de la biblioteca del DBMS College. Se abordaron requerimientos de seguridad (roles, usuarios, sinónimos) y se implementaron soluciones parametrizadas en SQL para generar informes de control de stock y cálculo de multas, incluyendo la optimización del plan de ejecución mediante índices.

---

## 🏛️ Contexto del Negocio y Requisitos

La base de datos utiliza un modelo relacional para gestionar:
* [cite_start]**Alumnos** y sus **Carreras** y **Escuelas**[cite: 35, 113, 53].
* [cite_start]**Empleados** de la biblioteca[cite: 64].
* [cite_start]**Libros** y sus **Ejemplares** y **Autores**[cite: 89, 78, 138].
* [cite_start]**Préstamos** de libros[cite: 6].
* **Reglas de negocio** para multas y rebajas (**REBAJA\_MULTA**, **VALOR\_MULTA\_PRESTAMO**).

El objetivo principal es establecer un control de calidad en los préstamos y calcular correctamente las multas por devoluciones tardías.

---

## 🔒 Caso 1: Estrategia de Seguridad (Usuarios, Roles y Sinónimos)

Se implementó una estrategia de seguridad basada en el principio del menor privilegio.

### 1. Usuarios y Roles

| Objeto | Propósito | Privilegios de Sistema |
| :--- | :--- | :--- |
| **`PRY2205_USER1`** | Dueño (Owner) del esquema de tablas y responsable de construir y optimizar las soluciones del Caso 3. Asignado a `PRY2205_ROL_D`. | `CREATE TABLE`, `CREATE VIEW`, `CREATE INDEX`, `CREATE PUBLIC SYNONYM`, `UNLIMITED TABLESPACE`, `CREATE SESSION`. |
| **`PRY2205_USER2`** | Usuario desarrollador, responsable de generar el informe del Caso 2. Asignado a `PRY2205_ROL_P`. | `CREATE TABLE`, `CREATE SEQUENCE`, `CREATE TRIGGER`, `CREATE SYNONYM`, `CREATE SESSION`. |
| **`PRY2205_ROL_D`** | Rol de **Dueño/Desarrollo** (Asignado a USER1). | Ver tabla de privilegios de USER1. |
| **`PRY2205_ROL_P`** | Rol de **Consulta/Implementación** (Asignado a USER2). | `SELECT` sobre todas las tablas de USER1 + permisos de creación de objetos necesarios (Tabla/Trigger/Sequence). |

### 2. Sinónimos Públicos

Se crearon sinónimos públicos para todas las tablas del esquema (`ALUMNO`, `LIBRO`, `PRESTAMO`, etc.) para permitir que otros usuarios (como `PRY2205_USER2`) accedan a los objetos sin prefijar el nombre del dueño.

**Requisito Clave:** Todas las sentencias SQL de los casos 2 y 3 acceden a las tablas a través de estos sinónimos públicos.

---

## 📊 Caso 2: Creación de Informe de Stock (`CONTROL_STOCK_LIBROS`)

**Usuario Ejecutor:** `PRY2205_USER2`

Se implementó un proceso para almacenar el stock de ejemplares, considerando solo los préstamos gestionados por los empleados **190, 180 y 150**, y con una fecha de inicio hace **dos años** (`EXTRACT(YEAR FROM SYSDATE) - 2`).

### 1. Componentes Creados

* **Secuencia:** `SEQ_CONTROL_STOCK`
* **Tabla de Salida:** `CONTROL_STOCK_LIBROS`
* **Disparador:** `TRG_CONTROL_STOCK_CORR` (Asigna automáticamente `SEQ_CONTROL_STOCK.NEXTVAL` a la clave primaria `CORRELATIVO` para evitar errores `ORA-02287` y `ORA-01400`).

### 2. Lógica del Informe

El informe calcula:
* `EJEMPLARES_TOTAL` y `EJEMPLARES_PRESTAMO`.
* `EJEMPLARES_DISPONIBLES`: Calculado como `TOTAL - EN_PRESTAMO`.
* `PORC_EN_PRESTAMO`: Porcentaje redondeado de ejemplares en préstamo respecto al total.
* `INDICADOR_STOCK_CRITICO`: 'S' si hay más de 2 ejemplares disponibles, 'N' en caso contrario.

**Consulta de Validación:**
```sql
SELECT * FROM CONTROL_STOCK_LIBROS;
