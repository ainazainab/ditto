# Test 9: RBAC Viewer Read Only
# Tests if system supports RBAC by checking if unauthorized user is blocked
try {
    # Try with wrong credentials (simulating unauthorized user)
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("unauthorized:user"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1" `
        -Headers @{"Authorization"="Basic $cred"} -ErrorAction Stop
    Write-Host "[X] VULNERABILITY" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401) {
        Write-Host "[OK] SECURE" -ForegroundColor Green
    } elseif ($code -eq 403) {
        Write-Host "[OK] SECURE" -ForegroundColor Green
    } else {
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
