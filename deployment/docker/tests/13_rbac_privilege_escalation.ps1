# Test 13: RBAC Privilege Escalation (Viewer to Admin)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: RBAC Privilege Escalation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NOTE: Requires viewer user in nginx.htpasswd" -ForegroundColor Yellow
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("viewer:viewer123"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"entries": {}}' -ErrorAction Stop
    Write-Host "[X][X][X] CRITICAL VULNERABILITY: Viewer can modify policy! Status: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 403) {
        Write-Host "[OK] SECURE: Privilege escalation blocked (403 Forbidden)" -ForegroundColor Green
    } elseif ($code -eq 401) {
        Write-Host "[X] Viewer user not found. Add to nginx.htpasswd first" -ForegroundColor Red
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

