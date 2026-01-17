# Start Live Demo Server
# This serves the demo HTML file so it can make API calls

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Live Demo Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is available
$python = Get-Command python -ErrorAction SilentlyContinue

if ($python) {
    Write-Host "[OK] Python found, starting HTTP server..." -ForegroundColor Green
    Write-Host ""
    Write-Host "Demo will be available at:" -ForegroundColor Yellow
    Write-Host "  http://localhost:8082/live_demo.html" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
    Write-Host ""
    
    Set-Location $PSScriptRoot
    python -m http.server 8082
} else {
    Write-Host "[INFO] Python not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1: Open directly in browser:" -ForegroundColor Cyan
    Write-Host "  Double-click: live_demo.html" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 2: Install Python and run this script again" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 3: Use any web server (IIS, Apache, etc.)" -ForegroundColor Gray
    Write-Host ""
    
    # Try to open the file directly
    $demoFile = Join-Path $PSScriptRoot "live_demo.html"
    if (Test-Path $demoFile) {
        Write-Host "Opening demo file in browser..." -ForegroundColor Yellow
        Start-Process $demoFile
    }
}




