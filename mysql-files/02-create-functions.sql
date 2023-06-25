SET NAMES 'utf8';

START TRANSACTION;

    DELIMITER //

    -- Devuelve el nivel de seguridad de un empleado, o 0 si hay un error.
    CREATE FUNCTION GetNivelSeguridadEmpleado(iLegajo INT) RETURNS INT
    DETERMINISTIC
    BEGIN
        DECLARE iNivel INT;
        
        SELECT S.Nivel
        FROM Empleado E
        JOIN Seguridad S
            ON E.Id_seg = S.Id_seg
        WHERE E.Legajo = iLegajo
        INTO iNivel;
        
        IF (iNivel IS NULL) THEN
            SET iNivel = 0;
        END IF;
    RETURN iNivel;
    END //

    -- Devuelve el nivel de seguridad de un área, o 0 si hay un error.
    CREATE FUNCTION GetNivelSeguridadArea(iNro_area INT) RETURNS INT
    DETERMINISTIC
    BEGIN
        DECLARE iNivel INT;
        
        SELECT S.Nivel
        FROM Area A
        JOIN Seguridad S
            ON A.Id_seg = S.Id_seg
        WHERE A.Nro_area = iNro_area
        INTO iNivel;
        
        IF (iNivel IS NULL) THEN
            SET iNivel = 0;
        END IF;
    RETURN iNivel;
    END //

    -- Comprueba si un empleado puede acceder a un área determinada
    CREATE FUNCTION PuedeAcceder(iLegajo INT, iNro_area INT) RETURNS BOOLEAN
    DETERMINISTIC
    BEGIN
        DECLARE nivel_emp INT;
        DECLARE nivel_area INT;
        DECLARE result BOOLEAN;
        
        SET result = FALSE;
        
        SET nivel_emp = GetNivelSeguridadEmpleado(iLegajo);
        SET nivel_area = GetNivelSeguridadArea(iNro_area);
        
        IF (nivel_emp <> 0 AND nivel_area <> 0 AND nivel_emp >= nivel_area) THEN
            SET result = TRUE;
        END IF;
    RETURN result;
    END //

    -- Comprueba si la contraseña suministrada es correcta
    CREATE FUNCTION PasswordMatches(iLegajo INT, iPwd CHAR(10)) RETURNS BOOLEAN
    DETERMINISTIC
    BEGIN
        DECLARE result BOOLEAN;
        
        SET result = EXISTS(
            SELECT *
            FROM Empleado
            WHERE Legajo = iLegajo
                AND Pwd = iPwd);
                
        RETURN result;
    END //

    DELIMITER ;

COMMIT;