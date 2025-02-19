SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Andrey Fedorin
-- Create date: 26-09-2024
-- Description:	Get sum of last values per day in a month
-- =============================================
CREATE FUNCTION [dbo].[fn_Get_ManualInputValueInAMonth] 
(
	-- Add the parameters for the function here
	@Address NVARCHAR(100),
	@Date DATE
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int

	SELECT @Result = SUM(LastValue) FROM (
	SELECT DISTINCT  CAST(Last_Op_TS_Local AS DATE) Date,
	LAST_VALUE(Num_Value) OVER 
		(
			PARTITION BY Tag_Name ORDER BY CAST(Last_Op_TS_Local AS DATE)
		) AS LastValue
	FROM Manual_Data_ManualInputList
	WHERE DATEPART(mm, @Date) = DATEPART(mm, Last_Op_TS_Local) AND DATEPART(yy, @Date) = DATEPART(yy, Last_Op_TS_Local)
		AND Tag_Name = @Address  
	) s


	RETURN @Result

END

