SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Andrey Fedorin
-- Create date: 
-- Update date: 2024-09-23
-- Description:	
-- =============================================
Create PROCEDURE [dbo].[sp_Get_CPM_gas_counter_PerMonth_old]
	@Equip_Address VARCHAR (100)
	,@DateBegin DATE
	,@DateEnd DATE -- Не используется.
	,@UseManualInputValue BIT = 0	
	,@Corr INT = 1 --Делитель для значений, используется для преобразования значения из PLC в реальное значение процесса
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ItemID INT = (SELECT        Id
								   FROM            dbo.tItem
								   WHERE        (Address = @Equip_Address))
	DECLARE @ResultManualValue INT
	SELECT @ResultManualValue = ISNULL(dbo.fn_Get_ManualInputValueInAMonth(@Equip_Address+'_Manual', CONVERT(DATE,@DateBegin, 104)), 0)
	
	SELECT 
	--MonthResult.DATE, 
	--MonthResult.BeginValue, 
	--MonthResult.EndValue, 
	MonthResult.PeriodValue/@Corr + IIF(@UseManualInputValue = 1, @ResultManualValue, 0) 
	FROM 
	(
    SELECT        MIN(tiv.TimeLoc) AS DATE, MIN(NumValue) AS BeginValue, MAX(NumValue) AS EndValue, MAX(NumValue) - MIN(NumValue) AS PeriodValue
	FROM            dbo.tItemValue AS tiv
	WHERE        ItemId = @ItemID
				AND (NumValue > 0)
				AND tiv.TimeLoc BETWEEN @DateBegin AND DATEADD(mm, 1, @DateBegin)
	) MonthResult		
END

