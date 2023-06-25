SET NAMES 'utf8';

START TRANSACTION;
    -- CONSIGNA 2:
    -- Mediante una vista obtener los empleados que en el día de la fecha han
    -- realizado algún intento de ingreso fallido a un área sin contar con un
    -- ingreso exitoso posterior para la misma. Incluir el área donde intentó
    -- ingresar en las columnas que devuelve la vista.
    CREATE VIEW VST_AuditAccesos AS
    SELECT
        ES1.Legajo,
        ES1.Nro_area,
        ES1.UltimoAccesoFallido
    FROM (
        SELECT Legajo, Nro_area, MAX(Fecha) AS UltimoAccesoFallido
        FROM Entradas_salidas
        WHERE Es_entrada = TRUE
            AND Autorizado = FALSE
            AND DATE(Fecha) = CURDATE()
        GROUP BY Legajo, Nro_area
    ) ES1
    LEFT JOIN (
        SELECT Legajo, Nro_area, MAX(Fecha) AS UltimoAccesoExitoso
        FROM Entradas_salidas
        WHERE Es_entrada = TRUE
            AND Autorizado = TRUE
            AND DATE(Fecha) = CURDATE()
        GROUP BY Legajo, Nro_area
    ) ES2
        ON ES1.Legajo = ES2.Legajo
        AND ES1.Nro_area = ES2.Nro_area
    WHERE UltimoAccesoExitoso IS NULL
        OR (UltimoAccesoFallido > UltimoAccesoExitoso);

    -- CONSIGNA 3:
    -- Obtener los datos personales de los empleados que en los últimos 30 días
    -- cuentan con una cantidad de intentos fallidos mayor a 5 o con al menos un
    -- intento de ingreso en un área cuyo nivel de seguridad sea superior al que
    -- tienen asignado.

    -- Cantidad de intentos fallidos mayor a 5 es sencilla, sólo cuenta la
    -- cantidad de intentos fallidos para cada combinación (Legajo, Nro_area)
    -- en los últimos 30 días.
    CREATE VIEW VST_IntentosFallidosAcceso30dias AS
        SELECT
            Legajo,
            Nro_area,
            COUNT(*) AS Intentos
        FROM Entradas_salidas
        WHERE Es_entrada = TRUE
            AND Autorizado = FALSE
            AND DATE(Fecha) BETWEEN (CURRENT_DATE - INTERVAL 30 DAY)
                            AND (CURRENT_DATE)
        GROUP BY Legajo, Nro_area
        HAVING Intentos > 5;
    
    -- Al menos un intento de ingreso en un área con seguridad superior a la
    -- asignada al empleado.
    -- Esto es más complicado, sobre todo por cómo decidimos modelar Seguridad.
    -- Para cada empleado tengo que traer el nivel de seguridad asociado, y 
    -- hacer lo mismo para cada área.
    -- Después sólo cuento la cantidad de intentos en los cuales el nivel del 
    -- empleado es inferior al nivel del área.
    CREATE VIEW VST_IntentosAccesoNivelesSuperiores30dias AS
        SELECT
            ES.Legajo, ES.Nro_area, COUNT(*) AS Intentos
        FROM (
            SELECT
                E.Legajo,
                A.Nro_area,
                S.Nivel AS Nivel_empleado,
                S2.Nivel AS Nivel_area
            FROM Entradas_salidas ES
            JOIN Empleado E ON ES.Legajo = E.Legajo
            JOIN Area A ON ES.Nro_area = A.Nro_area
            JOIN Seguridad S ON E.Id_seg = S.Id_seg
            JOIN Seguridad S2 ON A.Id_seg = S2.Id_seg
            WHERE ES.Es_entrada = TRUE
                AND DATE(ES.Fecha) BETWEEN (CURRENT_DATE - INTERVAL 30 DAY)
                                   AND (CURRENT_DATE)
            HAVING Nivel_empleado < Nivel_area) ES
        GROUP BY ES.Legajo, ES.Nro_area;

    -- Con esta vista junto las dos anteriores. Tengo que hacer este UNION
    -- porque MySQL no soporta FULL OUTER JOIN. Más adelante se pueden conseguir
    -- los datos personales de cada empleado haciendo una junta entre esta vista
    -- y Empleado.
    CREATE VIEW VST_AccesosInfructuosos30dias AS
        SELECT
            Legajo,
            Nro_area
        FROM VST_IntentosAccesoNivelesSuperiores30dias
        UNION
        SELECT
            Legajo,
            Nro_area
        FROM VST_IntentosFallidosAcceso30dias;
COMMIT;