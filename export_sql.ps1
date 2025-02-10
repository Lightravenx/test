# Параметры подключения
$server = "localhost"           # Замените на ваш сервер (например, "127.0.0.1\SQLEXPRESS")
$database = "DR_BDE_Krasnogorsk"      # Замените на вашу базу данных
$outputPath = "C:\git_repos\mssql_project\scripts"

# Загружаем модуль SQL Server (если не установлен — выдаст ошибку)
Import-Module SqlServer -ErrorAction Stop

# Проверяем наличие папки для скриптов
if (!(Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# Подключаем SQL Server Management Objects (SMO)
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
$serverInstance = New-Object Microsoft.SqlServer.Management.Smo.Server $server
$db = $serverInstance.Databases[$database]

Write-Host "Экспорт хранимых процедур..."

# Экспорт хранимых процедур
foreach ($sp in $db.StoredProcedures) {
    if ($sp.IsSystemObject -eq $false) {
        $script = $sp.Script()
        $script | Out-File "$outputPath\$($sp.Name).sql"
    }
}

Write-Host "Экспорт функций..."

# Экспорт пользовательских функций
foreach ($fn in $db.UserDefinedFunctions) {
    if ($fn.IsSystemObject -eq $false) {
        $script = $fn.Script()
        $script | Out-File "$outputPath\$($fn.Name).sql"
    }
}

Write-Host "Экспорт триггеров..."

# Экспорт триггеров (если нужны)
foreach ($table in $db.Tables) {
    foreach ($trg in $table.Triggers) {
        if ($trg.IsSystemObject -eq $false) {
            $script = $trg.Script()
            $script | Out-File "$outputPath\$($trg.Name).sql"
        }
    }
}

Write-Host "Экспорт завершён. Скрипты сохранены в: $outputPath"
cd C:\git_repos\mssql_project
git add .
git commit -m "Автообновление SQL-объектов $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main