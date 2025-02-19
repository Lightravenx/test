SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   TRIGGER [dbo].[trg_replace_values]
ON [dbo].[GKL_F11]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Обновляем только строки, где значения требуют изменений
    UPDATE [dbo].[GKL_F11]
    SET 
        Wet_Defect_name = CASE WHEN Wet_Defect_name = 'null' THEN NULL ELSE Wet_Defect_name END,
        Wet_Defect_cause = CASE WHEN Wet_Defect_cause = 'null' THEN NULL ELSE Wet_Defect_cause END,
        Wet_Description = CASE WHEN Wet_Description = 'null' THEN NULL ELSE Wet_Description END
    WHERE id IN (
        SELECT id 
        FROM inserted
    );
END;


ALTER TABLE [dbo].[GKL_F11] DISABLE TRIGGER [trg_replace_values]
