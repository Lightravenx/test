SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Andrey Fedorin
-- Create date: 26-09-2024
-- Description:	Get manual input value in a day
-- =============================================
CREATE FUNCTION [dbo].[fn_Get_ManualInputValueInADay] 
(
	@Address NVARCHAR(100),
	@Date DATE
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int

	SELECT TOP 1 @RESULT = mdmil.Num_Value 
	FROM Manual_Data_ManualInputList AS mdmil
	WHERE mdmil.Tag_Name = @Address
		AND CAST(mdmil.Last_Op_TS_Local AS DATE) = @Date
	ORDER BY mdmil.Last_Op_TS_Local DESC 

	-- Return the result of the function
	RETURN ISNULL(@RESULT, 0)

END

