# Test 2: Unauthorized Write Access (Wrong Credentials)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Unauthorized Write (Wrong Creds)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("wrong:password"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 999}' -ErrorAction Stop
    Write-Host "[X] VULNERABILITY: Write succeeded with wrong creds! Status: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401) {
        Write-Host "[OK] SECURE: Blocked (401 Unauthorized)" -ForegroundColor Green
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

