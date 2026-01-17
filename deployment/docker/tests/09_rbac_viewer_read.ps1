# Test 9: RBAC Viewer Read Only
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: RBAC Viewer Read (Should Work)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NOTE: Requires viewer user in nginx.htpasswd" -ForegroundColor Yellow
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("viewer:viewer123"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1" `
        -Headers @{"Authorization"="Basic $cred"} -ErrorAction Stop
    Write-Host "[OK] Viewer can read: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "  Response length: $($response.Content.Length) bytes" -ForegroundColor Gray
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401) {
        Write-Host "[X] Viewer user not found. Add to nginx.htpasswd first" -ForegroundColor Red
    } elseif ($code -eq 403) {
        Write-Host "[X] Viewer cannot read (policy issue)" -ForegroundColor Red
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

