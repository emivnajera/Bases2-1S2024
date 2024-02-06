CREATE PROCEDURE PR1
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @DateOfBirth DATE,
    @Password NVARCHAR(50)
AS
BEGIN
    -- Declarar variables para almacenar IDs y la fecha actual
    DECLARE @UserId UNIQUEIDENTIFIER, @RoleId UNIQUEIDENTIFIER, @Now DATETIME, @EmailConfirmed BIT;
	SET @UserId = NEWID();
    SET @Now = GETDATE();
	SET @EmailConfirmed = 0;

    -- Iniciar la transacción
    BEGIN TRANSACTION;

    -- Intentar realizar la inserción en la tabla Usuarios
    BEGIN TRY
        INSERT INTO [BD2].[practica1].[Usuarios]
        ([Id],[FirstName], [LastName], [Email], [DateOfBirth], [Password],[LastChanges], [EmailConfirmed])
        VALUES
        (@UserId,@FirstName, @LastName, @Email, @DateOfBirth, @Password, @Now, @EmailConfirmed);

        -- Intentar realizar la inserción en la tabla UsuarioRole
        INSERT INTO [BD2].[practica1].[UsuarioRole]
        ([RoleId], [UserId], [IsLatestVersion])
        VALUES
        ('F4E6D8FB-DF45-4C91-9794-38E043FD5ACD', @UserId, 1);

        -- Intentar realizar la inserción en la tabla Notification
        INSERT INTO [BD2].[practica1].[Notification]
        ([UserId], [Message], [Date])
        VALUES
        (@UserId, 'Usuario Registrado', @Now);

        -- Si todo se ejecuta correctamente, confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    -- Manejar cualquier error que pueda ocurrir durante las inserciones
    BEGIN CATCH
        -- Imprimir información sobre el error (puedes personalizar según tus necesidades)
        PRINT ERROR_MESSAGE();

        -- Revertir la transacción en caso de error
        ROLLBACK TRANSACTION;
    END CATCH;
END;


EXEC PR1 'John', 'Doe', 'john.doe@example.com', '1990-01-01', 'securepassword';


CREATE FUNCTION F3
(
    @UserId UNIQUEIDENTIFIER
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        [Id],
        [UserId],
        [Message],
        [Date]
    FROM
        [BD2].[practica1].[Notification]
    WHERE
        [UserId] = @UserId
);

DECLARE @UserIdConsulta UNIQUEIDENTIFIER;
SET @UserIdConsulta = 'EFEFAE87-0DA8-4CED-9177-C2401C5FA1E7';

SELECT *
FROM dbo.F3(@UserIdConsulta);