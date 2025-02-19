SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[trg_Combined_Update_F10]
ON [dbo].[GKL_F10]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1️⃣ Очистка значений
    UPDATE GKL_F10
    SET 
        Dry_Defect_name = CASE 
                            WHEN Dry_Defect_name = 'null' OR Dry_Defect_name LIKE '%df%' THEN NULL 
                            ELSE Dry_Defect_name
                          END,
        Dry_Defect_cause = CASE 
                            WHEN Dry_Defect_cause = 'null' OR Dry_Defect_cause LIKE '%cause%' THEN NULL 
                            ELSE Dry_Defect_cause 
                          END,
        Dry_Description = CASE 
                            WHEN Dry_Description = 'null' OR Dry_Description LIKE '%descrip%' THEN NULL 
                            ELSE Dry_Description 
                          END
    WHERE id IN (SELECT id FROM Inserted);

    -- 2️⃣ Обновление `Unique_Group_ID`
    ;WITH Grouped AS (
        SELECT 
            id, 
            order_code,
            ROW_NUMBER() OVER (PARTITION BY order_code ORDER BY id) AS row_num
        FROM GKL_F10
    )
    UPDATE GKL_F10
    SET Unique_Group_ID = CONCAT(g.order_code, '.', CEILING(g.row_num / 5.0))
    FROM GKL_F10 t
    INNER JOIN Grouped g ON t.id = g.id;

    -- 3️⃣ Пересчет `Row_Number_In_Group`
    ;WITH NumberedRows AS (
        SELECT 
            id, 
            ROW_NUMBER() OVER (PARTITION BY Unique_Group_ID ORDER BY id) AS row_num
        FROM GKL_F10
    )
    UPDATE GKL_F10
    SET Row_Number_In_Group = n.row_num
    FROM GKL_F10 t
    INNER JOIN NumberedRows n ON t.id = n.id;
END;

ALTER TABLE [dbo].[GKL_F10] ENABLE TRIGGER [trg_Combined_Update_F10]
