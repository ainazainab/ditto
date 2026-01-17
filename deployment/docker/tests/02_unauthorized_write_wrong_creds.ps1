# Test 2: Unauthorized Write Access (Wrong Credentials)
# Purpose: Verify that invalid credentials are rejected
# Expected: System should reject requests with wrong credentials (401 Unauthorized)
# Vulnerability: If write succeeds with wrong creds, authentication is bypassed

Write-Host "Test 2: Unauthorized Write Access (Wrong Credentials)" -ForegroundColor Cyan
Write-Host "Testing: Attempting to modify temperature with invalid credentials" -ForegroundColor Gray
Write-Host ""


try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("wrong:password"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 999}' -ErrorAction Stop
    
    Write-Host "Result: Request succeeded with invalid credentials" -ForegroundColor Red
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Red
    Write-Host "[X] VULNERABILITY: System accepts writes with wrong credentials" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401) {
        Write-Host "Result: Request rejected - invalid credentials" -ForegroundColor Green
        Write-Host "Status Code: 401 Unauthorized" -ForegroundColor Green
        Write-Host "[OK] SECURE: System properly validates credentials" -ForegroundColor Green
    } else {
        Write-Host "Result: Unexpected response" -ForegroundColor Yellow
        Write-Host "Status Code: $code" -ForegroundColor Yellow
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
