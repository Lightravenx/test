SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:		Andrey Fedorin
-- Create date: 
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[tItemValue_afteInsert]
ON [dbo].[tItemValue] 
   AFTER INSERT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--IF (SELECT COUNT(1) FROM #dddd) > 1 
	--RETURN
	SELECT * INTO #dddd FROM INSERTED 
	----Testing
	/*
	SELECT
	'2024-08-21 08:23:00.000' AS TimeUtc,
	'2024-08-21 11:23:00.000' AS TimeLoc,
	1 AS 	 NumValue,
	NULL AS StrValue,
	0	AS 	 Quality,
	51	AS	 ItemId
	INTO #dddd
	
	INSERT INTO #dddd
	SELECT
	'2024-08-21 08:23:00.000' AS TimeUtc,
	'2024-08-21 11:23:00.000' AS TimeLoc,
	1 AS 	 NumValue,
	NULL AS StrValue,
	0	AS 	 Quality,
	52	AS	 ItemId
	
	SELECT * FROM #dddd
	*/
	--DROP TABLE #dddd
	----

	DECLARE 
		@CPM1_operation_burner_ID INT = (SELECT ID FROM tItem AS ti WHERE ti.Address = 'CPM1_operation_burner')
		,@CPM1_operation_feed_raw_material_ID INT = (SELECT ID FROM tItem AS ti WHERE ti.Address = 'CPM1_operation_feed_raw_material')
		
		,@CPM2_operation_burner_ID INT = (SELECT ID FROM tItem AS ti WHERE ti.Address = 'CPM2_operation_burner')
		,@CPM2_operation_feed_raw_material_ID INT = (SELECT ID FROM tItem AS ti WHERE ti.Address = 'CPM2_operation_feed_raw_material')
		
		,@CPM3_operation_burner_ID INT = (SELECT ID FROM tItem AS ti WHERE ti.Address = 'CPM3_operation_burner')
		,@CPM3_operation_feed_raw_material_ID INT = (SELECT ID FROM tItem AS ti WHERE ti.Address = 'CPM3_operation_feed_raw_material')
		
		,@PER1_operation_burner_ID INT = (SELECT ID FROM tItem AS ti WHERE ti.Address = 'PER1_burner')
		,@PER1_operation_feed_raw_material_ID INT = (SELECT ID FROM tItem AS ti WHERE ti.Address = 'PER1_belt_scales')
		
		
		,@Equp_ID INT
		
		,@PLCTag_1 INT
		,@PLCTag_2 INT  




	
	IF EXISTS (SELECT d.ItemID FROM #dddd AS d WHERE d.itemid IN  (@CPM1_operation_burner_ID, @CPM1_operation_feed_raw_material_ID) )
	BEGIN
		SET @Equp_ID = 1
		SET @PLCTag_1 = @CPM1_operation_burner_ID
		SET @PLCTag_2 = @CPM1_operation_feed_raw_material_ID
	END 
		
	IF EXISTS (SELECT d.ItemID FROM #dddd AS d WHERE d.itemid IN  (@CPM2_operation_burner_ID, @CPM2_operation_feed_raw_material_ID) ) 
	BEGIN
		SET @Equp_ID = 2
		SET @PLCTag_1 = @CPM2_operation_burner_ID
		SET @PLCTag_2 = @CPM2_operation_feed_raw_material_ID
	END 
	
	IF EXISTS (SELECT d.ItemID FROM #dddd AS d WHERE d.itemid IN  (@CPM3_operation_burner_ID, @CPM3_operation_feed_raw_material_ID) ) 
	BEGIN
		SET @Equp_ID = 3
		SET @PLCTag_1 = @CPM3_operation_burner_ID
		SET @PLCTag_2 = @CPM3_operation_feed_raw_material_ID
	END 
	
	IF EXISTS (SELECT d.ItemID FROM #dddd AS d WHERE d.itemid IN  (@PER1_operation_burner_ID, @PER1_operation_feed_raw_material_ID) ) 
	BEGIN
		SET @Equp_ID = 4
		SET @PLCTag_1 = @PER1_operation_burner_ID
		SET @PLCTag_2 = @PER1_operation_feed_raw_material_ID
	END 

	IF (
	       SELECT count(id) FROM (
		   SELECT DISTINCT tiv.id
	       FROM   #dddd s
	              JOIN tItemValue tiv
	                   ON  s.TimeLoc = tiv.TimeLoc
	                   AND tiv.ItemId IN (@PLCTag_1, @PLCTag_2) ) ss
	) > 1 
	AND NOT EXISTS (SELECT TOP 1 1 FROM DT_CPM_PER_Status cpm
			JOIN #dddd d ON cpm.TimeLoc = d.TimeLoc AND d.itemID IN (@PLCTag_1, @PLCTag_2)
		    WHERE cpm.EquipID = @Equp_ID)
	BEGIN

	    INSERT INTO dbo.DT_CPM_PER_Status
	      (
	        EquipID,
	        TimeUtc,
	        TimeLoc,
	        STATUS
	      )

	    SELECT DISTINCT @Equp_ID  AS EquipID,
	           tiv.TimeUtc,
	           tiv.TimeLoc,
	           IIF(
	               SUM(tiv.NumValue) = 2,
	               'Run',
	               IIF(SUM(tiv.NumValue) = 1, 'Run/Stop', 'Waiting')
	           )     exitValue
	    FROM   tItemValue tiv
	    WHERE EXISTS (SELECT 1 FROM #dddd d
	                WHERE  d.TimeLoc = tiv.TimeLoc
	                AND d.ItemId IN (@PLCTag_1, @PLCTag_2))
				and tiv.TimeLoc = tiv.TimeLoc and tiv.ItemId in (@PLCTag_1, @PLCTag_2)


	    GROUP BY
	           tiv.TimeLoc,
	           tiv.TimeUtc
	END
END

ALTER TABLE [dbo].[tItemValue] ENABLE TRIGGER [tItemValue_afteInsert]
