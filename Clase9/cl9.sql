use bd2;

-- =====================================================================================
-- TRIGERS
-- =====================================================================================
CREATE TRIGGER proyecto1.Triger1
ON proyecto1.Course
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Operacion VARCHAR(20);
    DECLARE @Resultado VARCHAR(20);
    DECLARE @Descripcion VARCHAR(100);

    -- Determinar el tipo de operaci�n
   IF EXISTS (SELECT * FROM inserted)
        SET @Operacion = 'INSERT';
    ELSE IF EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'DELETE';
    ELSE
        SET @Operacion = 'UPDATE';
    -- L�gica para manejar las operaciones en las tablas
    SET @Descripcion = 'Operacion ' + @Operacion + ' Exitosa';

    -- Insertar el registro en la tabla HistoryLog
    INSERT INTO proyecto1.HistoryLog ([Date], Description)
    VALUES (GETDATE(), @Descripcion);
END;

CREATE TRIGGER proyecto1.Triger2
ON proyecto1.Usuarios
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Operacion VARCHAR(20);
    DECLARE @Resultado VARCHAR(20);
    DECLARE @Descripcion VARCHAR(100);

    -- Determinar el tipo de operaci�n
   IF EXISTS (SELECT * FROM inserted)
        SET @Operacion = 'INSERT';
    ELSE IF EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'DELETE';
    ELSE
        SET @Operacion = 'UPDATE';
    -- L�gica para manejar las operaciones en las tablas
    -- Tu l�gica aqu�...
    SET @Descripcion = 'Operacion ' + @Operacion + ' Exitosa';

    -- Insertar el registro en la tabla HistoryLog
    INSERT INTO proyecto1.HistoryLog ([Date], Description)
    VALUES (GETDATE(), @Descripcion);
END;

-- PROCEDIMIENTO 1
CREATE PROCEDURE proyecto1.PR1
    @Firstname VARCHAR(max),
    @Lastname VARCHAR(max), 
    @Email VARCHAR(max), 
    @DateOfBirth datetime2(7), 
    @Password VARCHAR(max), 
    @Credits INT
AS
BEGIN
    DECLARE @UserId uniqueidentifier;
    DECLARE @RolId uniqueidentifier;
    DECLARE @ErrorMessage NVARCHAR(250);
    DECLARE @ErrorSeverity INT; 

    -- Validaciones de cada campo
    -- Firtsname vacio 
    IF (@Firstname IS NULL OR @Firstname = '')
    BEGIN 
        SET @ErrorMessage = 'Error, El nombre no puede ir vacio';
        SET @ErrorSeverity = 16;
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
        RETURN;
    END

    -- apellido vacio
    IF (@Lastname IS NULL OR @Lastname = '')
    BEGIN 
        SET @ErrorMessage = 'Error, El apellido no puede ir vacio';
        SET @ErrorSeverity = 16;
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
        RETURN;
    END

    -- correo vacio
    IF (@Email IS NULL OR @Email = '')
    BEGIN 
        SET @ErrorMessage = 'Error, El campo correo no puede ir vacio';
        SET @ErrorSeverity = 16;
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
        RETURN;
    END

    -- fecha vacia 
    IF (@DateOfBirth IS NULL)
    BEGIN
        SET @ErrorMessage = 'Error, La fecha de nacimiento no puede ir vacia';
        SET @ErrorSeverity = 16;
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
        RETURN;
    END

    -- contase�a vacia 
    IF (@Password IS NULL OR @Password = '')
    BEGIN
        SET @ErrorMessage = 'Error, El password no puede estar vacio';
        SET @ErrorSeverity = 16;
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
        RETURN;
    END

    -- creditos con valor negativo 
    IF (@Credits < 0)
    BEGIN
        SET @ErrorMessage = 'Error, No puede ingresar una cantidad de creditos negativa';
        SET @ErrorSeverity = 16;
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
        RETURN;
    END

    BEGIN TRY
    	-- Inicio de transacci�n
        BEGIN TRANSACTION;
       
    	-- Validaci�n de datos utilizando el procedimiento PR6
        DECLARE @IsValid BIT;
        EXEC proyecto1.PR6 'Usuarios', @Firstname, @Lastname, NULL, NULL, @IsValid OUTPUT;
        IF(@IsValid = 0)
        BEGIN
            SET @ErrorMessage = 'Los campos son incorrectos, solo deben contener letras';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage,@ErrorSeverity,1);
            RETURN;
        END     

        -- Validar si el que el email no est� asociado con ninguna otra cuenta dentro del sistema
        IF EXISTS (SELECT * FROM proyecto1.Usuarios WHERE Email = @Email)
        BEGIN
            SET @ErrorMessage = 'Ya hay un usuario asociado con el correo indicado';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END

        -- Creaci�n de rol estudiante
        SET @RolId = (SELECT Id FROM proyecto1.Roles WHERE RoleName = 'Student');
        IF @RolId IS NULL
        BEGIN
            SET @ErrorMessage = 'El rol del estudiante no existe';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END
        
        -- Insert tabla Usuarios
        SET @UserId = NEWID();
        INSERT INTO proyecto1.Usuarios(Id, Firstname, Lastname, Email, DateOfBirth, Password, LastChanges, EmailConfirmed)
        VALUES (@UserId, @Firstname, @Lastname, @Email, @DateOfBirth, @Password, GETDATE(), 1);

        -- Insert tabla UsuarioRole
        INSERT INTO proyecto1.UsuarioRole (RoleId, UserId, IsLatestVersion)
        VALUES (@RolId, @UserId, 1);

        -- Insert tabla ProfileStudent
        INSERT INTO proyecto1.ProfileStudent (UserId, Credits)
        VALUES (@UserId, @Credits);

        -- Insert tabla TFA
        INSERT INTO proyecto1.TFA (UserId, Status, LastUpdate)
        VALUES (@UserId, 1, GETDATE());

        -- Insert tabla Notification
        INSERT INTO proyecto1.Notification (UserId, Message, Date)
        VALUES (@UserId, 'Se ha registrado satisfactoriamente', GETDATE());
		PRINT 'El estudiante ha sido registrado satisfactoriamente';
       
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
          -- Error - cancelar transacci�n 
        ROLLBACK;
        SELECT @ErrorMessage = ERROR_MESSAGE();
		-- Registro del error en la tabla HistoryLog
        INSERT INTO proyecto1.HistoryLog (Date, Description)
        VALUES (GETDATE(), 'Error Regristro - ' + @ErrorMessage);
       	PRINT 'Registro instatisfactorio'
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;

-- PROCEDIMIENTO 5 

CREATE PROCEDURE proyecto1.PR5 (@CodCourse int, @Name nvarchar(max), @CreditsRequired int)
AS BEGIN
	Declare @Description nvarchar(max);
	Declare @IsValid BIT;
	EXEC proyecto1.PR6 'Course',NULL,NULL, @Name, @CreditsRequired, @IsValid OUTPUT ;
	IF @IsValid = 0
		BEGIN
			-- MARCAR ERROR
			SET @Description = 'Inserci�n de Curso Fallida Nombre o Creditos Incorrectos';
			INSERT INTO proyecto1.HistoryLog ([Date], Description)
    		VALUES (GETDATE(), @Description);
			SELECT @Description AS 'Error';
			ROLLBACK TRANSACTION;
			RETURN;
		END
    IF @CreditsRequired < 0
		BEGIN
			-- MARCAR ERROR
			SET @Description = 'Inserci�n de Curso Fallida Creditos no pueden ser negativos';
			INSERT INTO proyecto1.HistoryLog ([Date], Description)
    		VALUES (GETDATE(), @Description);
			SELECT @Description AS 'Error';
			ROLLBACK TRANSACTION;
			RETURN;
		END --FUNCIONA COMO UN RETURN O BREAK
    IF @CodCourse < 0
		BEGIN
			-- MARCAR ERROR
			SET @Description = 'Inserci�n de Curso Fallida Codigo de Curso no puede ser negativo';
			INSERT INTO proyecto1.HistoryLog ([Date], Description)
    		VALUES (GETDATE(), @Description);
			SELECT @Description AS 'Error';
			ROLLBACK TRANSACTION;
			RETURN;
		END --FUNCIONA COMO UN RETURN O BREAK
	
	
	BEGIN TRY 
		BEGIN TRANSACTION;
		INSERT INTO proyecto1.Course(CodCourse, Name, CreditsRequired) VALUES
		(@CodCourse, @Name, @CreditsRequired);
		SELECT 'Inserci�n de Curso exitosa' AS Mensaje;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		SET @Description = 'Inserci�n de Curso Fallida'+ ERROR_MESSAGE();
		SELECT @Description AS 'Error';
		ROLLBACK TRANSACTION;
	END CATCH;
END;

-- PROCEDIMIENTO 6
CREATE PROCEDURE proyecto1.PR6
    @EntityName NVARCHAR(50),
    @FirstName NVARCHAR(MAX) = NULL,
    @LastName NVARCHAR(MAX) = NULL,
    @Name NVARCHAR(MAX) = NULL,
    @CreditsRequired INT = NULL,
    @IsValid BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validaciones de Usuario
    IF @EntityName = 'Usuarios'
    BEGIN
        IF ISNULL(@FirstName, '') NOT LIKE '%[^a-zA-Z ]%' AND ISNULL(@LastName, '') NOT LIKE '%[^a-zA-Z ]%'
            SET @IsValid = 1;
        ELSE
            SET @IsValid = 0;
    END
    -- Validacion de Curso
    ELSE IF @EntityName = 'Course'
    BEGIN
        IF ISNULL(@Name, '') NOT LIKE '%[^a-zA-Z ]%' AND ISNUMERIC(@CreditsRequired) = 1
            SET @IsValid = 1;
        ELSE
            SET @IsValid = 0;
    END
    ELSE
    BEGIN
        -- No valida
        SET @IsValid = 0;
    END;
END;

select * from proyecto1.Course;
select * from proyecto1.HistoryLog;

-- Insertar Cursos Nuevos
EXEC proyecto1.PR5 @CodCourse = 281, @Name = 'Sistemas Operativos', @CreditsRequired = 40;
-- Insertar Estudiantes 
EXEC proyecto1.PR1 
    @Firstname = 'Juan',
    @Lastname = 'Perez',
    @Email = 'juan.perez@example.com',
    @DateOfBirth = '1990-01-15',
    @Password = 'password123',
    @Credits = 20;

EXEC proyecto1.PR1 
    @Firstname = 'Juan',
    @Lastname = 'Perez',
    @Email = 'juan.perez@example.com',
    @DateOfBirth = '1990-01-15',
    @Password = 'password123',
    @Credits = 20;

SELECT * FROM proyecto1.HistoryLog;

-- =======================
-- Listar Procedimientos
-- =======================
SELECT 
    name AS ProcedureName,
    type_desc AS ProcedureType
FROM sys.procedures;

-- drop procedure proyecto1.PR5;

-- ====================
-- show Funciones
-- ====================
SELECT 
    name AS FunctionName,
    type_desc AS FunctionType
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF');

-- ====================
-- Show Triggers
-- ====================

SELECT * FROM sys.triggers