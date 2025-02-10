SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:		Andrey Fedorin
-- Create date: 03-09-2024
-- Description:	Получить данные по статусу оборудования на указанный день
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_EquipStatusAmount_PerDay] 
	@Equip_ID INT	-- 1 - CPM1
					-- 2 - CPM2
					-- 3 - CPM3
					-- 4 - PER1
	,@DateBegin DATETIME
	,@status nvarchar (255)
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT        CONVERT(DATE, CAST(DATEPART(yy, TimeLoc) AS VARCHAR(4)) + '-' + CAST(DATEPART(mm, TimeLoc) AS VARCHAR(2)) + '-' + CAST(DATEPART(dd, TimeLoc) AS VARCHAR(2))) AS DATE, EquipID, Status AS EquipStatus, 
	--						 COUNT(Status) AS StatusCount
	SELECT COUNT(Status) AS StatusCount
	FROM            dbo.DT_CPM_PER_Status AS dcps
	WHERE
		dcps.EquipID = @Equip_ID
		AND Status like @status
		AND CAST(TimeLoc AS DATE) = @DateBegin
	GROUP BY EquipID, DATEPART(yy, TimeLoc), DATEPART(mm, TimeLoc), DATEPART(dd, TimeLoc), STATUS
	

END

