# Test 6: Input Validation (Malformed JSON)
# Purpose: Verify that system rejects malformed JSON input
# Expected: System should reject malformed JSON with 400 Bad Request
# Vulnerability: If system accepts malformed JSON, parsing vulnerabilities may exist

Write-Host "Test 6: Input Validation (Malformed JSON)" -ForegroundColor Cyan
Write-Host "Testing: Attempting to send malformed JSON payload" -ForegroundColor Gray
Write-Host "Expected: System should reject invalid JSON syntax" -ForegroundColor Gray
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": invalid}' -ErrorAction Stop
    
    Write-Host "Result: System accepted malformed JSON" -ForegroundColor Red
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Red
    Write-Host "[X] VULNERABILITY: System lacks JSON validation" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 400) {
        Write-Host "Result: Request rejected - malformed JSON" -ForegroundColor Green
        Write-Host "Status Code: 400 Bad Request" -ForegroundColor Green
        Write-Host "[OK] SECURE: System properly validates JSON syntax" -ForegroundColor Green
    } else {
        Write-Host "Result: Unexpected response" -ForegroundColor Yellow
        Write-Host "Status Code: $code" -ForegroundColor Yellow
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
