param (
    [string]$SolutionPath = ".",
    [string]$ReportGeneratorPath = "$env:USERPROFILE\.nuget\packages\reportgenerator\5.4.11\tools\net8.0\ReportGenerator.dll"
)

# Normalize path
Set-Location $SolutionPath

# Find all test projects (*.csproj) where parent folder contains or ends with '.Test'
$testProjects = Get-ChildItem -Recurse -Filter "*.csproj" | Where-Object {
    $_.DirectoryName -match "\\[^\\]*\.Test(\\|$)" -or
    $_.DirectoryName -match "\.Test"
}

if (-not $testProjects -or $testProjects.Count -eq 0) {
    Write-Host "No test projects found in folders containing '.Test'." -ForegroundColor Red
    exit 1
}

foreach ($project in $testProjects) {
    Write-Host "`nRunning tests for: $($project.FullName)" -ForegroundColor Cyan
    dotnet test $project.FullName --collect:"XPlat Code Coverage"
}

# Optional wait
Start-Sleep -Seconds 3

# Locate all coverage.cobertura.xml files
$coverageFiles = Get-ChildItem -Recurse -Filter "coverage.cobertura.xml"

if (-not $coverageFiles -or $coverageFiles.Count -eq 0) {
    Write-Host "No coverage.cobertura.xml files found." -ForegroundColor Red
    exit 1
}

# Generate semicolon-separated list of coverage file paths
$reportList = ($coverageFiles | ForEach-Object { $_.FullName }) -join ";"

Write-Host "`nGenerating consolidated coverage report..." -ForegroundColor Cyan
dotnet exec $ReportGeneratorPath `
    -reports:"$reportList" `
    -targetdir:"CoverageReport" `
    -reporttypes:Html

# Open the final HTML report
$reportPath = Join-Path $SolutionPath "CoverageReport\index.html"
if (Test-Path $reportPath) {
    Write-Host "`nOpening report: $reportPath" -ForegroundColor Green
    Start-Process $reportPath
} else {
    Write-Host "Report not found." -ForegroundColor Red
}
