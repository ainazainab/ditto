# Test 12: RBAC Operator Modify Thing (Should Fail)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: RBAC Operator Modify Thing (Should Fail)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NOTE: Requires operator user in nginx.htpasswd" -ForegroundColor Yellow
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("operator:operator123"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/attributes" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"location": "hacked"}' -ErrorAction Stop
    if ($response.StatusCode -eq 204 -or $response.StatusCode -eq 200) {
        Write-Host "[X] VULNERABILITY: Operator can modify thing config! Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 403) {
        Write-Host "[OK] SECURE: Operator cannot modify thing (403 Forbidden)" -ForegroundColor Green
    } elseif ($code -eq 401) {
        Write-Host "[X] Operator user not found. Add to nginx.htpasswd first" -ForegroundColor Red
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

