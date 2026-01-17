# Test 16: Container Network Isolation - VULNERABILITY TEST
# Tests if containers can access each other (network isolation failure)
$containerName = (docker ps --filter "name=sensor" --format "{{.Names}}" | Select-Object -First 1)

if ($containerName) {
    $vulnerable = $false
    
    # Test if sensor can access MongoDB directly (should be isolated)
    $mongoTest = docker exec $containerName python -c "import socket; s=socket.socket(); s.settimeout(2); s.connect(('mongodb', 27017)); s.close()" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $vulnerable = $true
    }
    
    # Test if sensor can access gateway directly (bypassing nginx)
    $gatewayTest = docker exec $containerName python -c "import urllib.request; urllib.request.urlopen('http://gateway:8080/health')" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $vulnerable = $true
    }
    
    if ($vulnerable) {
        Write-Host "[X] VULNERABILITY" -ForegroundColor Red
    } else {
        Write-Host "[OK] SECURE" -ForegroundColor Green
    }
} else {
    Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
}
