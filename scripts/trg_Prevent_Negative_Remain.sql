SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
  CREATE TRIGGER [dbo].[trg_Prevent_Negative_Remain]
ON [dbo].[GKL_Sort]
AFTER INSERT, update
AS
BEGIN
    SET NOCOUNT ON;

    -- Проверяем, не стал ли remain отрицательным после вставки
    IF EXISTS (
        SELECT 1
        FROM [dbo].[GKL_Sort_View] v
        JOIN inserted i ON v.mat_code = i.mat_code
        WHERE v.remain < 0
    )
    BEGIN
	    ROLLBACK TRANSACTION;
    END

	    -- 1️⃣ Очистка значений
    UPDATE GKL_Sort
    SET 
        def_name = CASE 
                            WHEN def_name = 'null' OR def_name LIKE '%df%' THEN NULL 
                            ELSE def_name
                          END,
        def_cause = CASE 
                            WHEN def_cause = 'null' OR def_cause LIKE '%cause%' THEN NULL 
                            ELSE def_cause 
                          END,
        def_descrip = CASE 
                            WHEN def_descrip = 'null' OR def_descrip LIKE '%descrip%' THEN NULL 
                            ELSE def_descrip 
                          END
    WHERE id IN (SELECT id FROM Inserted);
END;

ALTER TABLE [dbo].[GKL_Sort] ENABLE TRIGGER [trg_Prevent_Negative_Remain]
