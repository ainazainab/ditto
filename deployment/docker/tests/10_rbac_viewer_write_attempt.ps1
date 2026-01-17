# Test 10: RBAC Viewer Write Attempt
# Purpose: Verify that unauthorized users cannot modify system resources
# Expected: System should reject write attempts from unauthorized users (401/403)
# Vulnerability: If unauthorized users can write, access control is compromised

Write-Host "Test 10: RBAC Viewer Write Attempt" -ForegroundColor Cyan
Write-Host "Testing: Attempting to modify thing data with unauthorized credentials" -ForegroundColor Gray
Write-Host "Expected: System should reject unauthorized write attempts" -ForegroundColor Gray
Write-Host ""


try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("unauthorized:user"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 999}' -ErrorAction Stop
    
    Write-Host "Result: Unauthorized user can modify thing data" -ForegroundColor Red
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Red
    Write-Host "[X] VULNERABILITY: System allows unauthorized write access" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401 -or $code -eq 403) {
        Write-Host "Result: Request rejected - unauthorized write blocked" -ForegroundColor Green
        Write-Host "Status Code: $code" -ForegroundColor Green
        Write-Host "[OK] SECURE: System properly enforces write access control" -ForegroundColor Green
    } else {
        Write-Host "Result: Unexpected response" -ForegroundColor Yellow
        Write-Host "Status Code: $code" -ForegroundColor Yellow
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
