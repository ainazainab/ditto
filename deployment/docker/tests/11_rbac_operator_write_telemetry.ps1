# Test 11: RBAC Operator Write Telemetry (Should Work)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: RBAC Operator Write Telemetry" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NOTE: Requires operator user in nginx.htpasswd" -ForegroundColor Yellow
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("operator:operator123"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 30}' -ErrorAction Stop
    if ($response.StatusCode -eq 204 -or $response.StatusCode -eq 200) {
        Write-Host "[OK] Operator can write telemetry: $($response.StatusCode)" -ForegroundColor Green
    }
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401) {
        Write-Host "[X] Operator user not found. Add to nginx.htpasswd first" -ForegroundColor Red
    } elseif ($code -eq 403) {
        Write-Host "[X] Operator cannot write (policy issue)" -ForegroundColor Red
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

