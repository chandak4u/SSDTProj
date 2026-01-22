Write-Host "Deploying DACPAC..."
Write-Host "Environment Variables Validation"

# ...existing code...
# Validate required environment variables
$requiredEnvVars = @("TENANT_ID", "LCR_ENV", "LCR_GEO", "TENANT_CODE", "SECRET_DATA")
foreach ($var in $requiredEnvVars) {
    $value = [Environment]::GetEnvironmentVariable($var)
    if ([string]::IsNullOrEmpty($value)) {
        Write-Host "ERROR: $var environment variable is not set or is empty"
        exit 1
    }
    # Write-Host "$var is set: $value"
}
# ...existing code...
Write-Host "All required environment variables are validated successfully"

$cs = $env:SECRET_DATA
# Find the DACPAC file in the data directory
$dacpacFiles = Get-ChildItem "/home/app/*.dacpac"
if ($dacpacFiles.Count -eq 0) {
    Write-Host "No DACPAC files found in /home/app/"
    exit 1
}

$dacpacPath = $dacpacFiles[0].FullName
Write-Host "Using DACPAC file: $dacpacPath"

# Try different possible paths for sqlpackage
$sqlpackagePath = $null
if (Test-Path "/var/opt/sqlpackage/sqlpackage") {
    $sqlpackagePath = "/var/opt/sqlpackage/sqlpackage"
} else {
    Write-Host "SqlPackage not found!"
    exit 1
}

Write-Host "Using SqlPackage at: $sqlpackagePath"
# Deploy the DACPAC
& $sqlpackagePath /Action:Publish /SourceFile:$dacpacPath /TargetConnectionString:$cs

if($?) {
	Write-Host "DACPAC deployed successfully."
} else {
	Write-Host "DACPAC deployment failed."
	exit 1
}