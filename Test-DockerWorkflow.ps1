# Test-DockerWorkflow.ps1
# Script to test the Docker workflow components locally

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Docker Workflow Components" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if workflow files exist
Write-Host "Test 1: Checking workflow files..." -ForegroundColor Yellow
$workflowFiles = @(
    ".github/workflows/saurabhmsbuild.yml",
    ".github/workflows/docker-publish.yml"
)

foreach ($file in $workflowFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing: $file" -ForegroundColor Red
    }
}
Write-Host ""

# Test 2: Check if Dockerfile exists
Write-Host "Test 2: Checking Dockerfile..." -ForegroundColor Yellow
if (Test-Path "Dockerfile") {
    Write-Host "  ✓ Dockerfile found" -ForegroundColor Green
    
    # Check if it references the correct DACPAC path
    $dockerContent = Get-Content "Dockerfile" -Raw
    if ($dockerContent -match "bin/Output/\*\.dacpac") {
        Write-Host "  ✓ Dockerfile references correct DACPAC path (bin/Output/*.dacpac)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Dockerfile may not reference correct DACPAC path" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✗ Dockerfile not found" -ForegroundColor Red
}
Write-Host ""

# Test 3: Check if entrypoint.sh exists
Write-Host "Test 3: Checking entrypoint.sh..." -ForegroundColor Yellow
if (Test-Path "entrypoint.sh") {
    Write-Host "  ✓ entrypoint.sh found" -ForegroundColor Green
} else {
    Write-Host "  ✗ entrypoint.sh not found" -ForegroundColor Red
}
Write-Host ""

# Test 4: Check if DACPAC exists (from local build)
Write-Host "Test 4: Checking for existing DACPAC..." -ForegroundColor Yellow
$dacpacPath = "bin/Output/AdventureWorks2019.dacpac"
if (Test-Path $dacpacPath) {
    Write-Host "  ✓ DACPAC found at: $dacpacPath" -ForegroundColor Green
    $dacpac = Get-Item $dacpacPath
    Write-Host "    Size: $($dacpac.Length / 1KB) KB" -ForegroundColor Gray
    Write-Host "    Modified: $($dacpac.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "  ⚠ DACPAC not found (will be built by workflow)" -ForegroundColor Yellow
}
Write-Host ""

# Test 5: Validate workflow syntax (basic check)
Write-Host "Test 5: Validating workflow syntax..." -ForegroundColor Yellow
try {
    $dockerWorkflow = Get-Content ".github/workflows/docker-publish.yml" -Raw
    if ($dockerWorkflow -match "uses: actions/download-artifact@v4") {
        Write-Host "  ✓ Artifact download step found" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Artifact download step missing" -ForegroundColor Red
    }
    
    if ($dockerWorkflow -match "name: dacpac-package") {
        Write-Host "  ✓ Correct artifact name referenced" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Artifact name mismatch" -ForegroundColor Red
    }
    
    if ($dockerWorkflow -match "needs: \[integration\]") {
        Write-Host "  ✓ Job dependency configured correctly" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Job dependency missing or incorrect" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Error reading workflow file: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: Check Git status
Write-Host "Test 6: Checking Git status..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "  ⚠ Uncommitted changes found:" -ForegroundColor Yellow
    git status --short
} else {
    Write-Host "  ✓ Working tree clean" -ForegroundColor Green
}

$branch = git branch --show-current
Write-Host "  Current branch: $branch" -ForegroundColor Gray
Write-Host ""

# Test 7: Check if Docker is running
Write-Host "Test 7: Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker version --format '{{.Server.Version}}' 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Docker is running (version: $dockerVersion)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Docker is not running" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Docker not available" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To test the workflow on GitHub:" -ForegroundColor White
Write-Host "  1. Commit any pending changes:" -ForegroundColor Gray
Write-Host "     git add ." -ForegroundColor Yellow
Write-Host "     git commit -m 'Update Docker workflow to consume DACPAC artifacts'" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. Push to GitHub:" -ForegroundColor Gray
Write-Host "     git push origin main" -ForegroundColor Yellow
Write-Host ""
Write-Host "  3. Monitor workflow execution:" -ForegroundColor Gray
Write-Host "     https://github.com/chandak4u/SSDTProj/actions" -ForegroundColor Yellow
Write-Host ""
Write-Host "Expected workflow execution order:" -ForegroundColor White
Write-Host "  1. MSBuild job (saurabhmsbuild.yml) - Builds DACPAC" -ForegroundColor Gray
Write-Host "  2. Docker build job - Downloads DACPAC and builds image" -ForegroundColor Gray
Write-Host "  3. Image push to ghcr.io/chandak4u/ssdtproj" -ForegroundColor Gray
Write-Host ""
