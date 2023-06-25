SET NAMES 'utf8';

START TRANSACTION;
    DELIMITER //

    CREATE TRIGGER trg_Area_CheckJerarquico_Insert
        BEFORE INSERT ON Area
        FOR EACH ROW
        BEGIN
            CALL SP_CheckDirectorEsJerarquico(NEW.Legajo_dir);
        END //
    
    CREATE TRIGGER trg_Area_CheckJerarquico_Update
        BEFORE UPDATE ON Area
        FOR EACH ROW
        BEGIN
            CALL SP_CheckDirectorEsJerarquico(NEW.Legajo_dir);
        END //

    CREATE TRIGGER trg_Trabaja_en_CheckNoProfesional_Insert
        BEFORE INSERT ON Trabaja_en 
        FOR EACH ROW
        BEGIN
            CALL SP_CheckTrabajaEnEsNoProfesional(NEW.Legajo);
            CALL SP_CheckNivelSeguridad(NEW.Legajo, NEW.Nro_area);
        END //

    CREATE TRIGGER trg_Trabaja_en_CheckNoProfesional_Update
        BEFORE UPDATE ON Trabaja_en 
        FOR EACH ROW
        BEGIN
            CALL SP_CheckTrabajaEnEsNoProfesional(NEW.Legajo);
            CALL SP_CheckNivelSeguridad(NEW.Legajo, NEW.Nro_area);
        END //

    CREATE TRIGGER trg_Contrato_CheckContratado_Insert
        BEFORE INSERT ON Contrato 
        FOR EACH ROW
        BEGIN
            CALL SP_CheckContratoEsContratado(NEW.Legajo);
            CALL SP_CheckNivelSeguridad(NEW.Legajo, NEW.Nro_area);
        END //

    CREATE TRIGGER trg_Contrato_CheckContratado_Update
        BEFORE UPDATE ON Contrato 
        FOR EACH ROW
        BEGIN
            CALL SP_CheckContratoEsContratado(NEW.Legajo);
            CALL SP_CheckNivelSeguridad(NEW.Legajo, NEW.Nro_area);
        END //

    CREATE TRIGGER trg_Auditoria_CheckFechaValida_Insert
        BEFORE INSERT ON Auditoria
        FOR EACH ROW
        BEGIN
            CALL SP_CheckAuditoriaFechaValida(NEW.Fecha, NEW.Id_contrato);
        END //

    CREATE TRIGGER trg_Auditoria_CheckFechaValida_Update
        BEFORE UPDATE ON Auditoria
        FOR EACH ROW
        BEGIN
            CALL SP_CheckAuditoriaFechaValida(NEW.Fecha, NEW.Id_contrato);
        END //

    DELIMITER ;
COMMIT;
