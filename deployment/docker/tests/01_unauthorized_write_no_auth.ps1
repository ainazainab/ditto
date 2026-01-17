# Test 1: Unauthorized Write Access (No Authentication)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Unauthorized Write (No Auth)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"} -Body '{"value": 999}' -ErrorAction Stop
    Write-Host "[X] VULNERABILITY: Write succeeded without auth! Status: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401) {
        Write-Host "[OK] SECURE: Blocked (401 Unauthorized)" -ForegroundColor Green
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

