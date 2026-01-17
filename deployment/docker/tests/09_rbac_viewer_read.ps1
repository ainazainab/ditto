# Test 9: RBAC Viewer Read Access
# Purpose: Verify that unauthorized users cannot access system resources
# Expected: System should reject requests from unauthorized users (401/403)
# Vulnerability: If unauthorized users can read, access control is insufficient

Write-Host "Test 9: RBAC Viewer Read Access" -ForegroundColor Cyan
Write-Host "Testing: Attempting to read thing data with unauthorized credentials" -ForegroundColor Gray
Write-Host "Expected: System should reject unauthorized read attempts" -ForegroundColor Gray
Write-Host ""


try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("unauthorized:user"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1" `
        -Headers @{"Authorization"="Basic $cred"} -ErrorAction Stop
    
    Write-Host "Result: Unauthorized user can read thing data" -ForegroundColor Red
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Red
    Write-Host "[X] VULNERABILITY: System allows unauthorized read access" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401 -or $code -eq 403) {
        Write-Host "Result: Request rejected - unauthorized access blocked" -ForegroundColor Green
        Write-Host "Status Code: $code" -ForegroundColor Green
        Write-Host "[OK] SECURE: System properly enforces access control" -ForegroundColor Green
    } else {
        Write-Host "Result: Unexpected response" -ForegroundColor Yellow
        Write-Host "Status Code: $code" -ForegroundColor Yellow
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
