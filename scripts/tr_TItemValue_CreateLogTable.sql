SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:    Andrey Fedorin
-- Create date: 2024-08-20
-- Description:  
-- =============================================
CREATE TRIGGER [dbo].[tr_TItemValue_CreateLogTable] 
   ON  [dbo].[tItemValue] 
   AFTER INSERT
AS 
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;
  INSERT INTO tItemValue_Log
  (
    -- Id -- this column value is auto-generated
    TimeUtc,
    TimeLoc,
    NumValue,
    StrValue,
    Quality,
    ItemId,
    TIMESTAMP_,
    Oper
  )
  SELECT 
    TimeUtc,
    TimeLoc,
    NumValue,
    StrValue,
    Quality,
    ItemId,
    GETDATE(),
    'INSERT'
  FROM INSERTED
    -- Insert statements for trigger here

END

ALTER TABLE [dbo].[tItemValue] DISABLE TRIGGER [tr_TItemValue_CreateLogTable]
