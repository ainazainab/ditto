# Test 10: RBAC Viewer Write Attempt (Should Fail)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: RBAC Viewer Write (Should Fail)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NOTE: Requires viewer user in nginx.htpasswd" -ForegroundColor Yellow
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("viewer:viewer123"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 999}' -ErrorAction Stop
    Write-Host "[X] VULNERABILITY: Viewer can write! Status: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 403) {
        Write-Host "[OK] SECURE: Viewer write blocked (403 Forbidden)" -ForegroundColor Green
    } elseif ($code -eq 401) {
        Write-Host "[X] Viewer user not found. Add to nginx.htpasswd first" -ForegroundColor Red
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

