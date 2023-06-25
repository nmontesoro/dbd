SET NAMES 'utf8';

START TRANSACTION;
    DELIMITER //

    -- Para poder manejar excepciones en el front
    CREATE PROCEDURE SP_RaiseError(IN msg VARCHAR(255))
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg;
    END //

    -- Comprueba que un trabajador sea de tipo no_profesional antes de agregarlo
    -- a la tabla Trabaja_en
    CREATE PROCEDURE SP_CheckTrabajaEnEsNoProfesional(IN iLegajo INT)
    BEGIN
        DECLARE es_no_profesional BOOLEAN;

        SET es_no_profesional = EXISTS(
            SELECT *
            FROM Empleado
            WHERE Legajo=iLegajo
                AND Tipo_empl='no_profesional');

        IF (es_no_profesional = FALSE) THEN
            CALL SP_RaiseError(
                'Sólo un no profesional puede trabajar en un área específica');
        END IF;
    END //

    -- Comprueba que un trabajador tenga el clearance necesario para el área 
    -- donde será asignado
    CREATE PROCEDURE SP_CheckNivelSeguridad(IN iLegajo INT, IN iNro_area INT)
    BEGIN
        IF (PuedeAcceder(iLegajo, iNro_area) = FALSE) THEN
            CALL SP_RaiseError(
                'Este empleado no posee el clearance de seguridad necesario');
        END IF;
    END //

    -- Comprueba que un trabajador sea de tipo contratado antes de agregarlo
    -- a la tabla Contrato
    CREATE PROCEDURE SP_CheckContratoEsContratado(IN iLegajo INT)
    BEGIN
        DECLARE es_contratado BOOLEAN;

        SET es_contratado = EXISTS(
            SELECT *
            FROM Empleado
            WHERE Legajo=iLegajo
                AND Tipo_prof='contratado');

        IF (es_contratado = FALSE) THEN
            CALL SP_RaiseError(
                'Sólo un contratado puede figurar en un contrato');
        END IF;
    END //

    -- Comprueba que un trabajador sea de tipo jerárquico antes de ponerlo como
    -- director de un área
    CREATE PROCEDURE SP_CheckDirectorEsJerarquico(IN Legajo_dir INT)
    BEGIN
        DECLARE es_jerarquico BOOLEAN;

        SET es_jerarquico = Legajo_dir IS NULL OR EXISTS(
            SELECT *
            FROM Empleado
            WHERE Legajo=Legajo_dir
                  AND Tipo_empl='jerarquico');

        IF (es_jerarquico = FALSE) THEN
            CALL SP_RaiseError('El director de un área debe ser jerárquico.');
        END IF;
    END //

    -- Comprueba que la fecha de una auditoría se encuentre dentro del período 
    -- de contrato
    CREATE PROCEDURE SP_CheckAuditoriaFechaValida(IN Fecha DATE, IN iId_contrato INT)
    BEGIN
        DECLARE es_valida BOOLEAN;

        SET es_valida = EXISTS(
            SELECT *
            FROM Contrato
            WHERE Id_contrato = iId_Contrato
                  AND Fecha >= F_ini
                  AND Fecha <= F_fin);

        IF (es_valida = FALSE) THEN
            CALL SP_RaiseError(
                'La fecha de la auditoría es inválida');
        END IF;
    END //
    
    -- Comprueba requisitos y crea el movimiento de E/S de empleados
    CREATE PROCEDURE SP_MovimientoPorHuella(IN iHuella CHAR(10), IN iNro_area INT, IN iEs_entrada BOOLEAN)
    BEGIN
        DECLARE iLegajo INT;
        DECLARE iAutorizado BOOLEAN;
        
        SELECT Legajo
        FROM Empleado
        WHERE Huella = iHuella
        INTO iLegajo;
        
        SET iAutorizado = PuedeAcceder(iLegajo, iNro_area);
        
        INSERT INTO Entradas_salidas(Legajo, Nro_area, Fecha, Es_entrada, Autorizado) VALUES
            (iLegajo, iNro_area, NOW(), iEs_entrada, iAutorizado);
        
        IF (iAutorizado = FALSE) THEN
            CALL SP_RaiseError('Movimiento no autorizado. El incidente fue registrado.');
        END IF;
    END //

    -- Comprueba requisitos y crea el movimiento de E/S de empleados
    CREATE PROCEDURE SP_MovimientoPorLegajo(IN iLegajo INT, IN iPwd CHAR(10), IN iNro_area INT, IN iEs_entrada BOOLEAN)
    BEGIN
        DECLARE password_matches BOOLEAN;
        DECLARE is_authorized BOOLEAN;
        
        SET password_matches = PasswordMatches(iLegajo, iPwd);
        SET is_authorized = password_matches AND PuedeAcceder(iLegajo, iNro_area);

        INSERT INTO Entradas_salidas(Legajo, Nro_area, Fecha, Es_entrada, Autorizado) VALUES
            (iLegajo, iNro_area, NOW(), iEs_entrada, is_authorized);
        
        IF (password_matches = FALSE) THEN
            CALL SP_RaiseError('Datos incorrectos. El incidente fue registrado.');
        ELSEIF (is_authorized = FALSE) THEN
            CALL SP_RaiseError('Movimiento no autorizado. El incidente fue registrado.');
        END IF;
    END //

    DELIMITER ;
COMMIT;
