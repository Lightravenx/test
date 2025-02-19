SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Andrey Fedorin
-- Create date: 28-09-2024
-- Update date: 23-09-2024
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_Get_CPM_total_feed_raw_gypsum_PerDay] 
	@Equip_Address VARCHAR (100)
	,@Date DATE
	,@UseManualInputValue BIT = 0
	,@Corr INT = 10 --Делитель для значений, используется для преобразования значения из PLC в реальное значение процесса
AS
BEGIN
	--'CPM1_total_feed_raw_gypsum'
	--'CPM2_total_feed_raw_gypsum'
	--'CPM3_total_feed_raw_gypsum'
	--'PER1_consumption_sand'
	
	
	SET NOCOUNT ON;
	
	DECLARE @ItemID INT = (SELECT        ID
								FROM            dbo.tItem
								WHERE        (Address = @Equip_Address))
	DECLARE @ResultManualValue INT
	SELECT @ResultManualValue = dbo.fn_Get_ManualInputValueInADay(@Equip_Address+'_Manual', CONVERT(DATE,@Date, 104))
								
	SELECT        
		--ISNULL(CAST(MIN(tiv.TimeLoc) AS DATE), CONVERT(DATE, @Date, 104))  AS DATE, 
		--MIN(NumValue) AS BeginValue, 
		--MAX(NumValue) AS EndValue, 
		(ISNULL(MAX(NumValue),0) - ISNULL(MIN(NumValue),0))/@Corr + IIF(@UseManualInputValue = 1, @ResultManualValue, 0) AS DayValue
	FROM            dbo.tItemValue AS tiv
	WHERE        (ItemId = @ItemID) AND (NumValue > 0)
				--AND tiv.TimeLoc BETWEEN CONVERT(DATE, @Date, 105) AND DATEADD(dd, 1, CONVERT(DATE, @Date, 105))
				AND tiv.TimeLoc BETWEEN @Date AND DATEADD(dd, 1, @Date)
END

