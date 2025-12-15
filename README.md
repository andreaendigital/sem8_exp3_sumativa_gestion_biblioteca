# 📚 Proyecto de Gestión de Biblioteca: DBMS COLLEGE
## Actividad Sumativa - Optimización y Seguridad de Base de Datos

Este proyecto consiste en el rediseño y optimización de los procesos de gestión de la biblioteca del DBMS College. Se abordaron requerimientos de seguridad (roles, usuarios, sinónimos) y se implementaron soluciones parametrizadas en SQL para generar informes de control de stock y cálculo de multas, incluyendo la optimización del plan de ejecución mediante índices.

---

## 🏛️ Contexto del Negocio y Requisitos

La base de datos utiliza un modelo relacional para gestionar:
* Alumnos y sus Carreras y Escuelas
* Empleados de la biblioteca
* Libros y sus Ejemplares y Autores
* Préstamos de libros
* **Reglas de negocio** para multas y rebajas (**REBAJA\_MULTA**, **VALOR\_MULTA\_PRESTAMO**).

El objetivo principal es establecer un control de calidad en los préstamos y calcular correctamente las multas por devoluciones tardías.

---

## 🔒 Caso 1: Estrategia de Seguridad (Acceso y Permisos)

Este caso se centró en la organización de la base de datos a nivel de usuarios y roles. La meta era establecer quién puede hacer qué, siguiendo el principio de "menor privilegio".

Usuarios Definidos: Se crearon dos usuarios principales: PRY2205_USER1 (el dueño de todas las tablas y constructor de soluciones) y PRY2205_USER2 (el desarrollador de consultas para el informe del Caso 2).

Roles y Permisos: Se crearon roles (PRY2205_ROL_D y PRY2205_ROL_P) para agrupar y asignar permisos de forma eficiente.

Acceso Simple: Se implementó la creación de sinónimos públicos para todas las tablas (como LIBRO en lugar de PRY2205_USER1.LIBRO), permitiendo a otros usuarios acceder a los datos de forma simple sin conocer el nombre del dueño.

## 🔒 Caso 2: Creación de Informe de Stock (Control de Ejemplares)

El objetivo fue generar un informe mensual que ayudara al personal de la biblioteca a controlar el flujo de libros y el stock.

Filtro Temporal y Personal: El informe se enfocó únicamente en los préstamos realizados dos años antes del año actual y gestionados por tres empleados específicos (190, 180 y 150).

Cálculos Clave: Se calcularon los ejemplares totales, en préstamo y disponibles, y se determinó el porcentaje de ocupación y un indicador de stock crítico ('S' o 'N') para cada libro.

Mecanismo Automático: Para generar el identificador (CORRELATIVO) de forma automática, se utilizó una secuencia en conjunto con un disparador (TRIGGER). Esto se hizo para superar las restricciones de Oracle que impiden la inserción directa de secuencias en consultas masivas, asegurando que cada fila insertada tenga un ID único y no nulo.

## 🔒 Caso 3: Vista de Multas y Optimización de Rendimiento
Este caso se dividió en dos partes: la creación de un informe detallado de multas y la mejora del rendimiento de ese informe.

## 🔒 Caso 3.1 (Informe de Multas): Se creó una vista (VW_DETALLE_MULTAS) que calcula, para los préstamos entregados con atraso:

Los días de atraso en la devolución.

El valor de la multa bruta (3% del precio del libro por día).

La rebaja aplicada a los alumnos de carreras con convenio especial (Ing. Prevención de Riesgos, Gastronomía, etc.).

El valor final de la multa a pagar.

## 🔒 Caso 3.2 (Optimización): Para asegurar que la consulta de la vista (VW_DETALLE_MULTAS) se ejecutara rápidamente (pasando de un escaneo completo de tabla a un acceso directo), se creó un índice compuesto en la tabla PRESTAMO. Esto mejoró el plan de ejecución y el rendimiento general del informe.
