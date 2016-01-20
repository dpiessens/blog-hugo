
# These variables should be set via the Octopus web portal:
#
#   ConnectionString         - The .Net connection string for the DB
if (! $ConnectionString)
{
	Write-Host "Missing required variable ConnectionString" -ForegroundColor Yellow
	exit 1
}

# Internal Variables
$contentPath  = (Join-Path $OctopusOriginalPackageDirectoryPath "content")
$dbFileName = (Get-ChildItem $contentPath\*.dacpac -Name | Select-Object -First 1)
$dbFilePath = (Join-Path $contentPath $dbFileName)

$publishSettingsPath = (Join-Path $contentPath "DeploySettings.publish.xml")

$sqlPackageDir = "${Env:ProgramFiles(x86)}\Microsoft SQL Server\110\DAC\bin"
$sqlPackageExe = (Join-Path $sqlPackageDir "SqlPackage.exe")

# Write all variables to build
Write-Host "Db File Path:" $dbFilePath
Write-Host "Sql Exe File Path:" $sqlPackageExe

# Run the deployment tool
Set-Location $sqlPackageDir
& $sqlPackageExe /Action:Publish /SourceFile:"$dbFilePath" /TargetConnectionString:"$ConnectionString" /Profile:"$publishSettingsPath" | Write-Host