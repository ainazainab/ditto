# Test 10: RBAC Viewer Write Attempt (Should Fail)
# Tests if unauthorized user can write (should be blocked)
try {
    # Try with wrong credentials
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("unauthorized:user"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 999}' -ErrorAction Stop
    Write-Host "[X] VULNERABILITY" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401 -or $code -eq 403) {
        Write-Host "[OK] SECURE" -ForegroundColor Green
    } else {
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
