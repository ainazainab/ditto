# Test 8: Replay Attack (Resend Old Messages)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Replay Attack (Same Request Twice)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

Write-Host "Sending first request..." -ForegroundColor Yellow
try {
    $response1 = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 25}' -ErrorAction Stop
    Write-Host "First request: $($response1.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "First request failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Start-Sleep -Seconds 2

Write-Host "Replaying same request..." -ForegroundColor Yellow
try {
    $response2 = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 25}' -ErrorAction Stop
    Write-Host "Replay request: $($response2.StatusCode)" -ForegroundColor Green
    Write-Host "[WARN] VULNERABILITY: Replay accepted (no replay protection)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    Write-Host "Replay request: $code" -ForegroundColor Yellow
    if ($code -eq 400 -or $code -eq 403) {
        Write-Host "[OK] SECURE: Replay rejected" -ForegroundColor Green
    }
}

