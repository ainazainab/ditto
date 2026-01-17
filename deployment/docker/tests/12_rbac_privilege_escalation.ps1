# Test 13: RBAC Privilege Escalation
# Purpose: Verify that unauthorized users cannot modify security policies
# Expected: System should reject policy modification attempts from unauthorized users (401/403)
# Vulnerability: If unauthorized users can modify policies, privilege escalation is possible

Write-Host "Test 13: RBAC Privilege Escalation" -ForegroundColor Cyan
Write-Host "Testing: Attempting to modify security policy with unauthorized credentials" -ForegroundColor Gray
Write-Host "Expected: System should reject unauthorized policy modifications" -ForegroundColor Gray
Write-Host "Vulnerability: Policy modification by unauthorized users enables privilege escalation" -ForegroundColor Gray
Write-Host ""


try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("unauthorized:user"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/policies/demo:sensor-1" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"entries": {}}' -ErrorAction Stop
    
    Write-Host "Result: Unauthorized user can modify security policy" -ForegroundColor Red
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Red
    Write-Host "[X] VULNERABILITY: System allows privilege escalation via policy modification" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401 -or $code -eq 403) {
        Write-Host "Result: Request rejected - unauthorized policy modification blocked" -ForegroundColor Green
        Write-Host "Status Code: $code" -ForegroundColor Green
        Write-Host "[OK] SECURE: System properly prevents privilege escalation" -ForegroundColor Green
    } else {
        Write-Host "Result: Unexpected response" -ForegroundColor Yellow
        Write-Host "Status Code: $code" -ForegroundColor Yellow
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
