SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TRIGGER [dbo].[trg_Combined_Update]
ON [dbo].[GKL_F11]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1️⃣ Очистка значений
    UPDATE GKL_F11
    SET 
        Wet_Defect_name = CASE 
                            WHEN Wet_Defect_name = 'null' OR Wet_Defect_name LIKE '%df%' THEN NULL 
                            ELSE Wet_Defect_name
                          END,
        Wet_Defect_cause = CASE 
                            WHEN Wet_Defect_cause = 'null' OR Wet_Defect_cause LIKE '%cause%' THEN NULL 
                            ELSE Wet_Defect_cause 
                          END,
        Wet_Description = CASE 
                            WHEN Wet_Description = 'null' OR Wet_Description LIKE '%descrip%' THEN NULL 
                            ELSE Wet_Description 
                          END
    WHERE id IN (SELECT id FROM Inserted);

    -- 2️⃣ Обновление `Unique_Group_ID`
    ;WITH Grouped AS (
        SELECT 
            id, 
            order_code,
            ROW_NUMBER() OVER (PARTITION BY order_code ORDER BY id) AS row_num
        FROM GKL_F11
    )
    UPDATE GKL_F11
    SET Unique_Group_ID = CONCAT(g.order_code, '.', CEILING(g.row_num / 5.0))
    FROM GKL_F11 t
    INNER JOIN Grouped g ON t.id = g.id;

    -- 3️⃣ Пересчет `Row_Number_In_Group`
    ;WITH NumberedRows AS (
        SELECT 
            id, 
            ROW_NUMBER() OVER (PARTITION BY Unique_Group_ID ORDER BY id) AS row_num
        FROM GKL_F11
    )
    UPDATE GKL_F11
    SET Row_Number_In_Group = n.row_num
    FROM GKL_F11 t
    INNER JOIN NumberedRows n ON t.id = n.id;
END;

ALTER TABLE [dbo].[GKL_F11] ENABLE TRIGGER [trg_Combined_Update]
