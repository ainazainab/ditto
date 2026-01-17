# Test 16: Container Network Isolation
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Container Network Isolation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing from sensor container..." -ForegroundColor Yellow
Write-Host ""

$containerName = (docker ps --filter "name=sensor" --format "{{.Names}}" | Select-Object -First 1)

if ($containerName) {
    Write-Host "Found container: $containerName" -ForegroundColor Green
    Write-Host ""
    Write-Host "Testing access to other services:" -ForegroundColor Yellow
    
    Write-Host "1. Dashboard (should be accessible):" -ForegroundColor Gray
    $dashboardTest = docker exec $containerName python -c "import urllib.request; urllib.request.urlopen('http://dashboard:5000')" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Dashboard accessible" -ForegroundColor Green
    } else {
        Write-Host "   [X] Dashboard not accessible" -ForegroundColor Red
    }
    
    Write-Host "2. MongoDB (should be accessible):" -ForegroundColor Gray
    $mongoTest = docker exec $containerName python -c "import socket; s=socket.socket(); s.settimeout(2); s.connect(('mongodb', 27017)); s.close()" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] MongoDB accessible" -ForegroundColor Green
    } else {
        Write-Host "   [X] MongoDB not accessible" -ForegroundColor Red
    }
    
    Write-Host "3. Gateway direct (bypassing nginx):" -ForegroundColor Gray
    $gatewayTest = docker exec $containerName python -c "import urllib.request; urllib.request.urlopen('http://gateway:8080/health')" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Gateway accessible" -ForegroundColor Green
    } else {
        Write-Host "   [X] Gateway not accessible" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "[WARN] If all accessible: No network isolation (expected in Docker)" -ForegroundColor Yellow
} else {
    Write-Host "[X] Sensor container not found. Is docker-compose up?" -ForegroundColor Red
}

