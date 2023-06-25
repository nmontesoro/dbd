SET NAMES 'utf8';

START TRANSACTION;
    CREATE TABLE Especialidad(
        Id_esp INT NOT NULL,
        Descripcion VARCHAR(255) NOT NULL,
        CONSTRAINT PK_Especialidad 
            PRIMARY KEY (Id_esp),
        CONSTRAINT UQ_Especialidad
            UNIQUE (Descripcion));

    -- CONSIGNA 5: Implementación de alguna restricción adicional que surja del
    -- diseño (ver CHK_Franja_valida). Si MySQL permitiera la utilización de 
    -- tipos de dato definidos por el usuario, se podría definir una clase
    -- Período que hiciera estas comprobaciones automáticamente y reutilizarla
    -- en, por ejemplo, Contrato.
    CREATE TABLE Franja_horaria(
        Id_franja INT NOT NULL,
        Hora_entrada TIME NOT NULL,
        Hora_salida TIME NOT NULL,
        CONSTRAINT PK_Franja_horaria 
            PRIMARY KEY (Id_franja),
        CONSTRAINT CHK_Franja_valida
            CHECK (Hora_salida > Hora_entrada),
        CONSTRAINT UQ_Franja
            UNIQUE (Hora_entrada, Hora_salida));

    CREATE TABLE Seguridad(
        Id_seg INT NOT NULL,
        Descripcion VARCHAR(255) NOT NULL,
        Nivel INT NOT NULL,
        CONSTRAINT PK_Seguridad 
            PRIMARY KEY (Id_seg),
        CONSTRAINT UQ_Seguridad
            UNIQUE (Descripcion));

    CREATE TABLE Tarea(
        Id_tarea INT NOT NULL,
        Descripcion VARCHAR(255) NOT NULL,
        CONSTRAINT PK_Tarea
            PRIMARY KEY (Id_tarea),
        CONSTRAINT UQ_TAREA
            UNIQUE (Descripcion));
    
    CREATE TABLE Empleado(
        Legajo INT NOT NULL,
        Nombre VARCHAR(255) NOT NULL,
        Apellido VARCHAR(255) NOT NULL,
        F_nac DATE NOT NULL,
        Nro_tel VARCHAR(25) NOT NULL,
        Huella CHAR(10) NOT NULL,
        Pwd CHAR(10) NOT NULL,
        Id_seg INT NOT NULL,
        Tipo_empl ENUM('profesional', 'no_profesional', 'jerarquico') NOT NULL,
        Tipo_prof ENUM('planta_permanente', 'contratado'),
        Id_esp INT,
        CONSTRAINT PK_Empleado
            PRIMARY KEY (Legajo),
        CONSTRAINT FK_Empleado_Seguridad
            FOREIGN KEY (Id_seg)
            REFERENCES Seguridad (Id_seg),
        CONSTRAINT FK_Profesional_Especialidad
            FOREIGN KEY (Id_esp)
            REFERENCES Especialidad (Id_esp),
        CONSTRAINT UQ_Huella
            UNIQUE (Huella),
        CONSTRAINT CHK_Profesional
            CHECK (
                (Tipo_empl='profesional'
                    AND Tipo_prof IS NOT NULL 
                    AND Id_esp IS NOT NULL)
                OR (Tipo_empl<>'profesional'
                    AND Tipo_prof IS NULL
                    AND Id_esp IS NULL)));

    CREATE TABLE Area(
        Nro_area INT NOT NULL,
        Nombre VARCHAR(255) NOT NULL,
        Id_seg INT NOT NULL,
        Legajo_dir INT,
        F_ini_dir DATE,
        CONSTRAINT PK_Area
            PRIMARY KEY (Nro_area),
        CONSTRAINT FK_Area_Seguridad
            FOREIGN KEY (Id_seg)
            REFERENCES Seguridad (Id_seg),
        CONSTRAINT FK_Area_Empleado
            FOREIGN KEY (Legajo_dir)
            REFERENCES Empleado (Legajo));

    CREATE TABLE Evento(
        Nro_evento INT NOT NULL,
        Descripcion VARCHAR(255) NOT NULL,
        Fecha DATETIME NOT NULL,
        Nro_area INT NOT NULL,
        CONSTRAINT PK_Evento
            PRIMARY KEY (Nro_evento, Nro_area),
        CONSTRAINT FK_Evento_Area
            FOREIGN KEY (Nro_area)
            REFERENCES Area (Nro_area));

    CREATE TABLE Entradas_salidas(
        Legajo INT NOT NULL,
        Nro_area INT NOT NULL,
        Fecha DATETIME NOT NULL,
        Es_entrada BOOLEAN NOT NULL,
        Autorizado BOOLEAN NOT NULL,
        CONSTRAINT PK_ES
            PRIMARY KEY (Legajo, Nro_area, Fecha),
        CONSTRAINT FK_ES_Empleado
            FOREIGN KEY (Legajo)
            REFERENCES Empleado (Legajo),
        CONSTRAINT FK_ES_Area
            FOREIGN KEY (Nro_area)
            REFERENCES Area (Nro_area));

    CREATE TABLE Trabaja_en(
        Legajo INT NOT NULL,
        Nro_area INT NOT NULL,
        CONSTRAINT PK_Trabaja_en
            PRIMARY KEY (Legajo, Nro_area),
        CONSTRAINT FK_Trabaja_en_Empleado
            FOREIGN KEY (Legajo)
            REFERENCES Empleado (Legajo),
        CONSTRAINT FK_Trabaja_en_Area
            FOREIGN KEY (Nro_area)
            REFERENCES Area (Nro_area));
    
    CREATE TABLE Durante(
        Legajo INT NOT NULL,
        Nro_area INT NOT NULL,
        Id_franja INT NOT NULL,
        CONSTRAINT PK_Durante
            PRIMARY KEY (Legajo, Nro_area, Id_franja),
        CONSTRAINT FK_Durante_Trabaja_en
            FOREIGN KEY (Legajo, Nro_area)
            REFERENCES Trabaja_en (Legajo, Nro_area),
        CONSTRAINT FK_Durante_Franja_horaria
            FOREIGN KEY (Id_franja)
            REFERENCES Franja_horaria (Id_franja));

    CREATE TABLE Contrato(
        Id_contrato INT NOT NULL,
        F_ini DATE NOT NULL,
        F_fin DATE NOT NULL,
        Id_tarea INT NOT NULL,
        Nro_area INT NOT NULL,
        Legajo INT NOT NULL,
        CONSTRAINT PK_Contrato
            PRIMARY KEY (Id_contrato),
        CONSTRAINT FK_Contrato_Tarea
            FOREIGN KEY (Id_tarea)
            REFERENCES Tarea (Id_tarea),
        CONSTRAINT FK_Contrato_Area
            FOREIGN KEY (Nro_area)
            REFERENCES Area (Nro_area),
        CONSTRAINT CHK_Contrato_Fechas
            CHECK (F_fin > F_ini));

    CREATE TABLE Auditoria(
        Nro_audit INT NOT NULL,
        Descripcion VARCHAR(255) NOT NULL,
        Fecha DATETIME NOT NULL,
        Aprobado BOOLEAN NOT NULL,
        Id_contrato INT NOT NULL,
        CONSTRAINT PK_Auditoria
            PRIMARY KEY (Nro_audit, Id_contrato),
        CONSTRAINT FK_Auditoria_Contrato
            FOREIGN KEY (Id_contrato)
            REFERENCES Contrato (Id_contrato));
COMMIT;
