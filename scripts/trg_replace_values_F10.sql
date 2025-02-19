SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   TRIGGER [dbo].[trg_replace_values_F10]
ON [dbo].[GKL_F10]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Обновляем только строки, где значения требуют изменений
    UPDATE [dbo].[GKL_F10]
    SET 
        Dry_Defect_name = CASE WHEN Dry_Defect_name = 'NULL' THEN NULL ELSE Dry_Defect_name END,
        Dry_Defect_cause = CASE WHEN Dry_Defect_cause = 'NULL' THEN NULL ELSE Dry_Defect_cause END,
        Dry_Description = CASE WHEN Dry_Description = 'NULL' THEN NULL ELSE Dry_Description END
    WHERE id IN (
        SELECT id 
        FROM inserted
    );
END;


ALTER TABLE [dbo].[GKL_F10] DISABLE TRIGGER [trg_replace_values_F10]
