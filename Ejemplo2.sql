-- Agregar la constraint
ALTER TABLE [BD2].[practica1].[Course]
WITH NOCHECK
ADD CONSTRAINT CK_Name_OnlyLetters
CHECK([Name] NOT LIKE '%[^a-zA-Z ]%');


-- Insertar un Curso
INSERT INTO [BD2].[practica1].[Course]([CodCourse], [Name], [CreditsRequired])
VALUES (102, 'Compiladores Tres', 3);

-- Crear Procedimineto para Eliminar los Numeros

CREATE PROCEDURE EliminarNumeros
(
	@TableName NVARCHAR(100),
	@ColumnName NVARCHAR(100)
)
AS
BEGIN
	DECLARE @REGEX NVARCHAR(10)
	DECLARE @NUMBER  NVARCHAR(10)
	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @EMPTY NVARCHAR(10)

	SET @REGEX = '''%[0-9]%'''
	SET @NUMBER = '''[0-9]'''
	SET @EMPTY = ''''''
	SET @SQL = N'
	DECLARE @Value NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
	SELECT '+@ColumnName+'
	FROM '+@TableName+'

	OPEN cur
	
	FETCH NEXT FROM cur INTO @Value

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF PATINDEX ('+@REGEX+', @Value) > 0
		BEGIN
			DECLARE @OutputString NVARCHAR(MAX) ='+@EMPTY+
			'DECLARE @Index INT = 1
			DECLARE @Length INT = LEN(@Value)
			WHILE @Index <= @Length
			BEGIN
				DECLARE @Char CHAR(1) = SUBSTRING (@Value, @Index, 1)
				IF @Char NOT LIKE '+@NUMBER+'
				BEGIN
					SET @OutputString = @OutputString + @Char
				END

				SET @Index = @Index + 1
			END
			PRINT @Value
			PRINT @OutputString

			UPDATE '+@TableName+'
			SET '+@ColumnName+' = @OutputString
			WHERE '+@ColumnName+' = @Value
		END
		FETCH NEXT FROM cur INTO @Value
	END
	
	CLOSE cur
	DEALLOCATE cur
	'
	EXEC sp_executesql @SQL
END

-- PR6
-- RECUERDEN QUE EL PR6 TAMBIEN ES UNA TRANSACCION
CREATE PROCEDURE PR6
AS
BEGIN
	DECLARE @ConstraintName NVARCHAR(128)
	DECLARE @CountViolations INT
	SET @ConstraintName = 'CK_Name_OnlyLetters'

	IF EXISTS (
		SELECT 1
		FROM sys.check_constraints
		WHERE name = @ConstraintName
	)
	BEGIN
		SELECT @CountViolations = COUNT(*)
        FROM [BD2].[practica1].[Course]
        WHERE [Name] LIKE '%[^a-zA-Z ]%';

		IF @CountViolations = 0
		BEGIN
			PRINT 'La constraint ' + @ConstraintName+ ' se cumple.'
		END
		ELSE
		BEGIN
			PRINT 'La constraint '+@ConstraintName+ 'No se cumple. Se encontraron '+CAST(@CountViolations AS NVARCHAR(10)) + 'violaciones.'
			EXEC EliminarNumeros '[BD2].[practica1].[Course]','[Name]'
		END
	END
	ELSE
	BEGIN
		PRINT 'La constraint ' + @ConstraintName + ' no existe en la base de datos.'
	END
END

EXEC PR6