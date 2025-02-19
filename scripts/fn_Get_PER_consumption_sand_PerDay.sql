SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Andrey Fedorin
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION fn_Get_PER_consumption_sand_PerDay
(
	@Equip_Address VARCHAR (100)
	,@Date DATE 
)
RETURNS int
AS
BEGIN
	
	DECLARE @Result INT
	DECLARE @ItemID INT = (SELECT        Id
							FROM            dbo.tItem
							WHERE        (Address = @Equip_Address))
	DECLARE @MinValueDay INT = (SELECT TOP 1 DATEPART(minute,tiv.TimeLoc) FROM tItemValue AS tiv 
	                            WHERE   
									ItemId = @ItemID
									AND CAST(tiv.TimeLoc AS DATE) = CONVERT(DATE, @Date, 105)
	                            ORDER BY tiv.NumValue ASC
								)
	
	SELECT       @Result = MAX(NumValue)
	FROM            dbo.tItemValue AS tiv
	WHERE       ItemId = @ItemID
				AND tiv.TimeLoc BETWEEN DATEADD(minute, 
				@MinValueDay
				, CAST(CONVERT(DATE, @Date, 105) AS DATETIME)) AND DATEADD(dd, 1, CONVERT(DATE, @Date, 105))

	RETURN @Result

END

