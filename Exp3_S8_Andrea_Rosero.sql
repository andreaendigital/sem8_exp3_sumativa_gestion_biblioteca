-- Sumativa 3
-- Exp3_S8_Andrea_Rosero.sql


---------------------------------------
--  CASO 1 ESTRATEGIA DE SEGURIADD
---------------------------------------

---------------------------------------
--  PARTE 1: USUARIO ADMIN
---------------------------------------


-- CREACIÓN DE USUARIOS

-- Usuario Dueño de las tablas y para Caso 3
CREATE USER PRY2205_USER1 IDENTIFIED BY User1Password DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

-- Usuario Genérico para consultas y Caso 2
CREATE USER PRY2205_USER2 IDENTIFIED BY User2Password DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;


--CREACIÓN DE ROLES:

-- Rol para PRY2205_USER1 (Dueño de Objetos y Constructor de soluciones)
CREATE ROLE PRY2205_ROL_D;

-- Rol para PRY2205_USER2 (Consultor)
CREATE ROLE PRY2205_ROL_P;



-- PRIVILEGIOS DE SISTEMAS A ROLES  
-- PRY2205_ROL_D (Dueño/Constructor): Necesita privilegios para conectarse, 
-- crear tablas, secuencias, vistas e índices, y crear sinónimos.


GRANT CONNECT, RESOURCE, CREATE VIEW TO PRY2205_ROL_D;
GRANT CREATE SYNONYM TO PRY2205_ROL_D;
GRANT CREATE PUBLIC SYNONYM TO PRY2205_ROL_D;
GRANT CREATE SEQUENCE TO PRY2205_ROL_D;
GRANT CREATE INDEX TO PRY2205_ROL_D;


-- PRY2205_ROL_P (Consultor): Necesita privilegios para conectarse, 
-- crear objetos necesarios para el Caso 2 (tablas, secuencias, triggers) 
-- y poder consultar las tablas del dueño.


GRANT CONNECT, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE SYNONYM TO PRY2205_ROL_P;



-- ASIGNACIÓN DE ROLES  
GRANT PRY2205_ROL_D TO PRY2205_USER1;
GRANT PRY2205_ROL_P TO PRY2205_USER2;



-- SINONIMOS PUBLICOS (por el Dueño de las tablas): Los sinónimos públicos 
-- se eligen para objetos que serán utilizados por múltiples usuarios y donde 
-- se quiere que el nombre del objeto sea el mismo para todos sin prefijar el esquema. 
-- Para este caso, el usuario PRY2205_USER2 accederá a las tablas del dueño, 
-- por lo que crearemos sinónimos públicos para todas las tablas principales.


-- Privilegio necesario para crear sinónimos públicos:
GRANT CREATE PUBLIC SYNONYM TO PRY2205_USER1; 

-- Creación de Sinónimos Públicos (ejecutar por PRY2205_USER1 si se le otorgó el permiso, sino por ADMIN)
-- Asumiendo que PRY2205_USER1 es el dueño de las tablas:
CREATE PUBLIC SYNONYM ALUMNO FOR PRY2205_USER1.ALUMNO;
CREATE PUBLIC SYNONYM CARRERA FOR PRY2205_USER1.CARRERA;
CREATE PUBLIC SYNONYM EJEMPLAR FOR PRY2205_USER1.EJEMPLAR;
CREATE PUBLIC SYNONYM EMPLEADO FOR PRY2205_USER1.EMPLEADO;
CREATE PUBLIC SYNONYM LIBRO FOR PRY2205_USER1.LIBRO;
CREATE PUBLIC SYNONYM PRESTAMO FOR PRY2205_USER1.PRESTAMO;
CREATE PUBLIC SYNONYM REBAJA_MULTA FOR PRY2205_USER1.REBAJA_MULTA;
CREATE PUBLIC SYNONYM AUTOR FOR PRY2205_USER1.AUTOR;
CREATE PUBLIC SYNONYM EDITORIAL FOR PRY2205_USER1.EDITORIAL;
CREATE PUBLIC SYNONYM ESCUELA FOR PRY2205_USER1.ESCUELA;
CREATE PUBLIC SYNONYM VALOR_MULTA_PRESTAMO FOR PRY2205_USER1.VALOR_MULTA_PRESTAMO;
CREATE PUBLIC SYNONYM DETALLE_PRESTAMO_MENSUAL FOR PRY2205_USER1.DETALLE_PRESTAMO_MENSUAL;
CREATE PUBLIC SYNONYM ERROR_PROCESO_PRESTAMO FOR PRY2205_USER1.ERROR_PROCESO_PRESTAMO;


---------------------------------------
-- PARET 2:  USUARIO PRY2205_USER1 (Dueño)
---------------------------------------

-- Ejecutar el script de creación y población de tablas que se adjuntó en el caso

-- Privilegios sobre Objetos de PRY2205_USER1 a PRY2205_ROL_P: Para que PRY2205_USER2 
-- pueda acceder a las tablas a través de los sinónimos (si son públicos),
--  el dueño debe otorgar los permisos de consulta al rol.

-- Otorgar permiso SELECT sobre las tablas principales a PRY2205_ROL_P
GRANT SELECT ON ALUMNO TO PRY2205_ROL_P;
GRANT SELECT ON CARRERA TO PRY2205_ROL_P;
GRANT SELECT ON EDITORIAL TO PRY2205_ROL_P;
GRANT SELECT ON EJEMPLAR TO PRY2205_ROL_P;
GRANT SELECT ON EMPLEADO TO PRY2205_ROL_P;
GRANT SELECT ON ESCUELA TO PRY2205_ROL_P;
GRANT SELECT ON LIBRO TO PRY2205_ROL_P;
GRANT SELECT ON PRESTAMO TO PRY2205_ROL_P;
GRANT SELECT ON AUTOR TO PRY2205_ROL_P;
GRANT SELECT ON REBAJA_MULTA TO PRY2205_ROL_P;
GRANT SELECT ON VALOR_MULTA_PRESTAMO TO PRY2205_ROL_P;
GRANT SELECT ON DETALLE_PRESTAMO_MENSUAL TO PRY2205_ROL_P;
GRANT SELECT ON ERROR_PROCESO_PRESTAMO TO PRY2205_ROL_P;


---------------------------------------
--  CASO 2 CREACIÓN DE INFORME (CONTROL_STOCK_LIBROS)
---------------------------------------

-- requiere la creación de una secuencia, una tabla para el informe, 
-- y una consulta de inserción de datos. Este proceso debe ser manejado por PRY2205_USER2 
-- ya que está autorizado para construir y consultar el informe y las sentencias deben usar los sinónimos.

---------------------------------------
--  PARTE 1: Usuario PRY2205_USER2
---------------------------------------

-- Creación de Secuencia: 

CREATE SEQUENCE SEQ_CONTROL_STOCK START WITH 1 INCREMENT BY 1 NOCACHE;

-- Creación de la Tabla CONTROL_STOCK_LIBROS (CREATE TABLE AS SELECT): Se usará la lógica 
-- para el cálculo del año y la restricción por empleado. El año de proceso es dos años antes del año actual. 
-- Asumiendo que el año actual es 2025 (lo que hace que el año de proceso sea 2023, y los préstamos 
-- a considerar son de 2023), aunque el enunciado menciona 2021 si se ejecuta en 2023. 
-- Se ajustará la fórmula para que sea paramétrica.


-- Sentencia SQL para crear e insertar datos en la tabla CONTROL_STOCK_LIBROS
CREATE TABLE CONTROL_STOCK_LIBROS AS
SELECT
    SEQ_CONTROL_STOCK.NEXTVAL AS CORRELATIVO,
    TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -24), 'YYYYMM') AS FECHA_PROCESO,
    L.LIBROID AS ID_LIBRO,
    L.NOMBRE_LIBRO AS NOMBRE_LIBRO,
    TO_NUMBER(SUM(CASE WHEN E.EJEMPLARID IS NOT NULL THEN 1 ELSE 0 END)) AS EJEMPLARES_TOTAL,
    TO_NUMBER(SUM(CASE WHEN P.PRESTAMOID IS NOT NULL THEN 1 ELSE 0 END)) AS EJEMPLARES_PRESTAMO,
    TO_NUMBER(SUM(CASE WHEN E.EJEMPLARID IS NOT NULL AND P.PRESTAMOID IS NULL THEN 1 ELSE 0 END)) AS EJEMPLARES_DISPONIBLES,
    ROUND(
        (
            SUM(CASE WHEN P.PRESTAMOID IS NOT NULL THEN 1 ELSE 0 END) /
            SUM(CASE WHEN E.EJEMPLARID IS NOT NULL THEN 1 ELSE 0 END)
        ) * 100
    ) AS PORC_EN_PRESTAMO,
    CASE
        WHEN SUM(CASE WHEN E.EJEMPLARID IS NOT NULL AND P.PRESTAMOID IS NULL THEN 1 ELSE 0 END) > 2 THEN 'S'
        ELSE 'N'
    END AS INDICADOR_STOCK_CRITICO
FROM 
    PRY2205_USER1.LIBRO L
INNER JOIN 
    PRY2205_USER1.EJEMPLAR E 
    ON L.LIBROID = E.LIBROID
LEFT JOIN (
    -- Subconsulta para obtener los ejemplares en préstamo del año objetivo y empleados específicos
    SELECT 
        P.LIBROID, 
        P.EJEMPLARID, 
        P.PRESTAMOID, 
        P.FECHA_INICIO
    FROM 
        PRY2205_USER1.PRESTAMO P
    WHERE 
        EXTRACT(YEAR FROM P.FECHA_INICIO) = EXTRACT(YEAR FROM SYSDATE) - 2 -- Año de proceso (dos años antes)
        AND P.EMPLEADOID IN (190, 180, 150)
) P
ON E.LIBROID = P.LIBROID AND E.EJEMPLARID = P.EJEMPLARID
GROUP BY
    L.LIBROID,
    L.NOMBRE_LIBRO
ORDER BY
    L.LIBROID;


--> Restricción Oracle dice que no se puede usar SEQ_CONTROL_STOCK.NEXTVAL directamente dentro 
-- de la subconsulta SELECT de una sentencia CREATE TABLE AS SELECT (CTAS) porque se considera 
-- una operación no determinística o que afecta a una tabla que aún no existe.


-- Solución: Replantear la consulta separando la creación de la tabla, un trigger y luego la inserción de datos

-- Primero ejecuto:

CREATE TABLE CONTROL_STOCK_LIBROS (
    CORRELATIVO NUMBER(10) NOT NULL,
    FECHA_PROCESO VARCHAR2(6) NOT NULL,
    ID_LIBRO NUMBER(5) NOT NULL,
    NOMBRE_LIBRO VARCHAR2(70) NOT NULL,
    EJEMPLARES_TOTAL NUMBER(5) NOT NULL,
    EJEMPLARES_PRESTAMO NUMBER(5) NOT NULL,
    EJEMPLARES_DISPONIBLES NUMBER(5) NOT NULL,
    PORC_EN_PRESTAMO NUMBER(3),
    INDICADOR_STOCK_CRITICO VARCHAR2(1)
);

ALTER TABLE CONTROL_STOCK_LIBROS ADD CONSTRAINT PK_CONTROL_STOCK_LIBROS PRIMARY KEY (CORRELATIVO);


-- Luego ejecuto:

    -- Requerimiento: El usuario PRY2205_USER2 puede crear disparadores.
CREATE OR REPLACE TRIGGER TRG_CONTROL_STOCK_CORR
BEFORE INSERT ON CONTROL_STOCK_LIBROS
FOR EACH ROW
BEGIN
    -- Asigna el siguiente valor de la secuencia al campo CORRELATIVO
    -- Solo si el valor es nulo (o si no se proporciona en el INSERT).
    :NEW.CORRELATIVO := SEQ_CONTROL_STOCK.NEXTVAL;
END;


-- Finalmente ejecuto: 

INSERT INTO CONTROL_STOCK_LIBROS (
    FECHA_PROCESO,
    ID_LIBRO,
    NOMBRE_LIBRO,
    EJEMPLARES_TOTAL,
    EJEMPLARES_PRESTAMO,
    EJEMPLARES_DISPONIBLES,
    PORC_EN_PRESTAMO,
    INDICADOR_STOCK_CRITICO
)
SELECT
    TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -24), 'YYYYMM'),
    L.LIBROID,
    L.NOMBRE_LIBRO,
    TO_NUMBER(SUM(CASE WHEN E.EJEMPLARID IS NOT NULL THEN 1 ELSE 0 END)),
    TO_NUMBER(SUM(CASE WHEN P.PRESTAMOID IS NOT NULL THEN 1 ELSE 0 END)),
    TO_NUMBER(SUM(CASE WHEN E.EJEMPLARID IS NOT NULL AND P.PRESTAMOID IS NULL THEN 1 ELSE 0 END)),
    ROUND(
        (
            SUM(CASE WHEN P.PRESTAMOID IS NOT NULL THEN 1 ELSE 0 END) /
            SUM(CASE WHEN E.EJEMPLARID IS NOT NULL THEN 1 ELSE 0 END)
        ) * 100
    ),
    CASE
        WHEN SUM(CASE WHEN E.EJEMPLARID IS NOT NULL AND P.PRESTAMOID IS NULL THEN 1 ELSE 0 END) > 2 THEN 'S'
        ELSE 'N'
    END
FROM 
    LIBRO L --  Usando Sinónimo Público
INNER JOIN 
    EJEMPLAR E --  Usando Sinónimo Público
    ON L.LIBROID = E.LIBROID
LEFT JOIN (
    SELECT 
        P.LIBROID, 
        P.EJEMPLARID, 
        P.PRESTAMOID, 
        P.FECHA_INICIO
    FROM 
        PRESTAMO P --  Usando Sinónimo Público
    WHERE 
        EXTRACT(YEAR FROM P.FECHA_INICIO) = EXTRACT(YEAR FROM SYSDATE) - 2 
        AND P.EMPLEADOID IN (190, 180, 150)
) P
ON E.LIBROID = P.LIBROID AND E.EJEMPLARID = P.EJEMPLARID
GROUP BY
    L.LIBROID,
    L.NOMBRE_LIBRO
ORDER BY
    L.LIBROID;





---------------------------------------
--  CASO 3 OPTIMIAZACIÓN DE SENTENCIAS SQL
---------------------------------------

---------------------------------------
--  PARTE 1: CREACIÓN DE VISTAS (VW_DETALLE_MULTAS)
--  PRY2205_USER1
---------------------------------------

-- Cálculo de días de atraso y multa y cálculo de rebaja de multa


-- Usuario PRY2205_USER1
CREATE OR REPLACE VIEW VW_DETALLE_MULTAS AS
SELECT
    P.PRESTAMOID AS ID_PRESTAMO,
    A.NOMBRE || ' ' || A.APATERNO || ' ' || A.AMATERNO AS ALUMNO_COMPLETO,
    C.DESCRIPCION AS CARRERA_NOMBRE,
    L.LIBROID AS COD_LIBRO,
    TO_CHAR(L.PRECIO, 'FM999G999') AS PRECIO_LIBRO,
    TO_CHAR(P.FECHA_TERMINO, 'DD/MM/YYYY') AS FECHA_DEV_COMPROMETIDA,
    TO_CHAR(P.FECHA_ENTREGA, 'DD/MM/YYYY') AS FECHA_DEV_REAL,
    TRUNC(P.FECHA_ENTREGA - P.FECHA_TERMINO) AS DIAS_ATRASO,
    ROUND(L.PRECIO * 0.03 * TRUNC(P.FECHA_ENTREGA - P.FECHA_TERMINO)) AS VALOR_MULTA_BRUTA,
    NVL(RM.PORC_REBAJA_MULTA, 0) AS PORC_REBAJA,
    ROUND(
        (L.PRECIO * 0.03 * TRUNC(P.FECHA_ENTREGA - P.FECHA_TERMINO)) * (NVL(RM.PORC_REBAJA_MULTA, 0) / 100)
    ) AS VALOR_REBAJA,
    ROUND(
        (L.PRECIO * 0.03 * TRUNC(P.FECHA_ENTREGA - P.FECHA_TERMINO)) *
        (1 - (NVL(RM.PORC_REBAJA_MULTA, 0) / 100))
    ) AS VALOR_MULTA_FINAL
FROM
PRESTAMO P --  Usando Sinónimo Público
INNER JOIN 
    ALUMNO A --  Usando Sinónimo Público
    ON P.ALUMNOID = A.ALUMNOID
INNER JOIN 
    CARRERA C --  Usando Sinónimo Público
    ON A.CARRERAID = C.CARRERAID
INNER JOIN 
    LIBRO L --  Usando Sinónimo Público
    ON P.LIBROID = L.LIBROID
LEFT JOIN 
    REBAJA_MULTA RM --  Usando Sinónimo Público
    ON C.CARRERAID = RM.CARRERAID
WHERE
    P.FECHA_ENTREGA > P.FECHA_TERMINO  -- Libros entregados con atraso
    AND EXTRACT(YEAR FROM P.FECHA_TERMINO) = EXTRACT(YEAR FROM SYSDATE) - 2 -- Préstamos terminados hace 2 años
ORDER BY
    P.FECHA_ENTREGA DESC;



---------------------------------------
--  PARTE 2: Creación de índices
--  PRY2205_USER1
---------------------------------------

-- Mejora de la Cláusula WHERE y ORDER BY en PRESTAMO: Se creará un índice 
-- en (FECHA_ENTREGA, FECHA_TERMINO) en la tabla PRESTAMO ya que son las columnas 
-- más selectivas en la cláusula WHERE y una de ellas en ORDER BY.

-- Usuario PRY2205_USER1
CREATE INDEX IDX_PREST_FECHA_ENTR_TERM ON PRY2205_USER1.PRESTAMO (FECHA_ENTREGA, FECHA_TERMINO);


--Mejora de JOIN en ALUMNO: La tabla ALUMNO se une a la tabla CARRERA por CARRERAID. 
-- ALUMNOID es clave primaria y tiene un índice implícito, pero el JOIN con CARRERA 
-- es por CARRERAID que es clave foránea. Existe un índice implícito en la FK ALUMNO_CARRERA_FK 
-- si fue creado automáticamente por Oracle, pero si no, un índice en la columna CARRERAID 
-- de ALUMNO puede ayudar a este JOIN.

-- Usuario PRY2205_USER1
CREATE INDEX IDX_ALUMNO_CARRERAID ON PRY2205_USER1.ALUMNO (CARRERAID);




----------------------------------------------------------------------------------------


