---------------------------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
/*
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SNAPSHOT
SERIALIZABLE
VERSÃO      : SQL SERVER 2005,2008,2012
*/

---------------------------------------------------------------------------------------------------
/*
	AUTOR       : NILO FILHO
	DATA        : 11/02/2014
	PROPOSITO   : BUSCAR TODAS AS LÍNGUAS SUPORTADAS PELO SQL SERVER E O SEUS RESPECTIVOS CÓDIGOS
	VERSÃO      : SQL SERVER 2005,2008,2012
*/
SELECT lcid,msglangid, name,alias FROM sys.syslanguages ORDER BY alias;
GO
/*************************************************************************************************
								FIM
**************************************************************************************************/
---------------------------------------------------------------------------------------------------
/*
	AUTOR       : NILO FILHO
	DATA        : 11/02/2014
	PROPOSITO   : BUSCAR TODAS AS MENSAGENS POR LÍNGUA
	PARAMETROS  : INFORMAR O ALIAS DO PÁIS SELECIONADO
	INFORMAÇÕES : Inglês Britanico - lcid = 2057
				  Inglês Americano - lcid = 1033
				  Português Brasil - lcid = 1046
	VERSÃO      : SQL SERVER 2005,2008,2012
*/
DECLARE @ALIAS VARCHAR(100);
DECLARE @LGID INT;
SET @ALIAS = 'BRAZILIAN';
SET @LGID = (SELECT lcid from sys.syslanguages where alias like @ALIAS);
SELECT * FROM SYS.messages WHERE language_id = @LGID;
GO
/*************************************************************************************************
								FIM
**************************************************************************************************/
---------------------------------------------------------------------------------------------------
/*
	AUTOR       : NILO FILHO
	DATA        : 11/02/2014
	PROPOSITO   : BUSCAR TODAS AS MENSAGENS DO SQL SERVER POR LÍNGUA
	PARAMETROS  : INFORMAR O ALIAS DO PÁIS SELECIONADO
	INFORMAÇÕES : Inglês Britanico - lcid = 2057
				  Inglês Americano - lcid = 1033
				  Português Brasil - lcid = 1046
	VERSÃO      : SQL SERVER 2005,2008,2012
*/
DECLARE @ALIAS VARCHAR(100)
DECLARE @LGID INT
SET @ALIAS = 'BRAZILIAN'
SET @LGID = (SELECT lcid from sys.syslanguages where alias like @ALIAS)
SELECT * FROM SYS.sysmessages WHERE  msglangid = @LGID
GO
/*************************************************************************************************
								FIM
**************************************************************************************************/
---------------------------------------------------------------------------------------------------
/*
	AUTOR       : NILO FILHO
	DATA        : 11/02/2014
	PROPOSITO   : BUSCAR TODOS OS OBJETOS
	PARAMETROS  : NOME DO OBJETO A SER PESQUISADO.
	INFORMAÇÕES : SQL_SCALAR_FUNCTION					FN
				   DEFAULT_CONSTRAINT					D 
				   SQL_INLINE_TABLE_VALUED_FUNCTION	    IF
				   INTERNAL_TABLE						IT
				   CLR_STORED_PROCEDURE				    PC
				   PRIMARY_KEY_CONSTRAINT				PK
				   SQL_STORED_PROCEDURE				    P 
				   AGGREGATE_FUNCTION					AF
				   UNIQUE_CONSTRAINT					UQ
				   SYSTEM_TABLE						    S 
				   SQL_TRIGGER							TR
				   SQL_TABLE_VALUED_FUNCTION			TF
				   VIEW								    V 
				   CLR_SCALAR_FUNCTION					FS
				   FOREIGN_KEY_CONSTRAINT				F 
				   SERVICE_QUEUE						SQ
				   EXTENDED_STORED_PROCEDURE			X 
				   USER_TABLE							U 
	VERSÃO      : SQL SERVER 2005,2008,2012
*/
DECLARE @OBJ VARCHAR(200)
SET @OBJ = '%TB_SEGURANCA%'
SELECT * FROM SYS.all_objects WHERE name LIKE @OBJ
AND TYPE = 'U'
GO
/*************************************************************************************************
								FIM
**************************************************************************************************/
---------------------------------------------------------------------------------------------------

--EXEMPLO DE USO DE CURSOR
/*
ISO SINTAXE
*/

/*
DECLARE cursor1 [ INSENSITIVE ] [ SCROLL ] CURSOR
 FOR 
SELECT COLUNA1,COLUNA2,COLUNA3,COLUNAN FROM TABELA 
[ FOR { READ ONLY | UPDATE [ OF column_name [ ,...n ] ] } ] ;


/*
T-SQL SINTAXE
*/

DECLARE cursor1 CURSOR [ LOCAL | GLOBAL ] 
     [ FORWARD_ONLY | SCROLL ] 
     [ STATIC | KEYSET | DYNAMIC | FAST_FORWARD ] 
     [ READ_ONLY | SCROLL_LOCKS | OPTIMISTIC ] 
     [ TYPE_WARNING ] 
     FOR 
	 SELECT COLUNA1,COLUNA2,COLUNA3,COLUNAN FROM TABELA 
     [ FOR UPDATE [ OF column_name [ ,...n ] ] ] ;

OPEN cursor1

FETCH NEXT FROM cursor1
INTO  @VAR_COLUNA1, @VAR_COLUNA2, @VAR_COLUNA3, @VAR_COLUNAN

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT ''
		SELECT @VAR_COLUNA1, @VAR_COLUNA2, @VAR_COLUNA3, @VAR_COLUNAN
		FETCH NEXT FROM cursor1 INTO @VAR_COLUNA1, @VAR_COLUNA2, @VAR_COLUNA3, @VAR_COLUNAN
	END
CLOSE cursor1
DEALLOCATE cursor1
*/

---------------------------------------------------------------------------------------------------

use dbprotocolo_desenv
DECLARE @MAX INT, @MIN INT

SELECT @MAX = 127, @MIN = 1

WHILE @MIN = 1 BEGIN
BEGIN TRY
    SELECT @MAX = @MAX * 2 + 1
    PRINT @MAX
END TRY
BEGIN CATCH
    BEGIN TRY
        SET @MIN = -1 - @MAX
        PRINT @MIN
    END TRY
    BEGIN CATCH

        SET @MIN = 0
		PRINT @MIN
		
    END CATCH
END CATCH
END

SELECT @MIN , @MAX

/*************************************************************************************************
								FIM
**************************************************************************************************/
---------------------------------------------------------------------------------------------------
/*
	AUTOR       : VINICIUS DALMASO E FERNANDO PAZOTI
	DATA        : 27/02/2014
	PROPOSITO   : FAZER UM TRACE DE TODAS A MODIFICAÇÕES EM PROCEDURES
	PARAMETROS  : N/A
	VERSÃO      : SQL SERVER 2005,2008,2012
*/
CREATE TRIGGER nome_da_trigger ON DATABASE FOR DDL_PROCEDURE_EVENTS AS 

BEGIN 
	
	SET NOCOUNT ON DECLARE @Evento XML SET @Evento = EVENTDATA() 
	
	INSERT INTO nome_da_tabela(coluna1,coluna2,coluna3...colunaN) 
	
	SELECT  @Evento.value('(/EVENT_INSTANCE/EventType/text())[1]','varchar(50)') Tipo_Evento, /*TIPO DE MODIFICAÇÃO EFETUADA - ALTER,CREATE,DROP*/
			@Evento.value('(/EVENT_INSTANCE/PostTime/text())[1]','datetime') PostTime, /*DATA DA ALTERAÇÃO*/
			@Evento.value('(/EVENT_INSTANCE/ServerName/text())[1]','varchar(50)') ServerName,  /*NOME DO SERVIDOR QUE SOFREU A INTERVENÇÃO*/
			@Evento.value('(/EVENT_INSTANCE/LoginName/text())[1]','varchar(50)') LoginName, /*LOGIN UTILIZADO PARA A INTERVENÇÃO */
			HOST_NAME(),																	/* NOME DA MÁQUINA DE ORIGEM DA INTERVENÇÃO */ 
			@Evento.value('(/EVENT_INSTANCE/DatabaseName/text())[1]','varchar(50)') DatabaseName, /*NOME DA BASE DE DADOS*/
			@Evento.value('(/EVENT_INSTANCE/ObjectName/text())[1]','varchar(50)') ObjectName, /*NOME DO OBJETO QUE SOFREU INTERVENÇÃO */
			@Evento																			/*TRACE*/
END
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ENABLE TRIGGER [TRGTrace_Alteracao_Objeto] ON DATABASE
GO


GO
GO
/*************************************************************************************************
								FIM
**************************************************************************************************/


---------------------------------------------------------------------------------------------------
/*
	AUTOR       : NILO FILHO
	DATA        : DD/MM/AAAA
	PROPOSITO   : 
	PARAMETROS  : 
	INFORMAÇÕES : 
	VERSÃO      : SQL SERVER 2005,2008,2012
*/
/*************************************************************************************************
								FIM
**************************************************************************************************/
