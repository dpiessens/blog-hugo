
# These variables should be set via the Octopus web portal:
#
#   ConnectionString         - The .Net connection string for the DB
 

Write-Host "Connection String: <"$ConnectionString">"

# Get the exe name based on the directory
$contentPath  = (Join-Path $OctopusOriginalPackageDirectoryPath "content")
$fullPath = (Join-Path $contentPath "migrate.exe")
Write-Host "Migrate Path:" $fullPath

cd $contentPath
write-host "Working Dir: "$(get-location)

# Run the migration utility
& ".\migrate.exe" MyApp.Data.dll /startUpConfigurationFile=MyApp.Data.dll.config /connectionString=$ConnectionString /connectionProviderName="System.Data.SqlClient" /verbose | Write-Host