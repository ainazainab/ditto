# Test 7: Rate Limiting (DoS Attack Simulation)
# Purpose: Verify that system has rate limiting to prevent DoS attacks
# Expected: System should limit request rate and reject excessive requests
# Vulnerability: If all requests succeed, system lacks DoS protection

Write-Host "Test 7: Rate Limiting (DoS Attack Simulation)" -ForegroundColor Cyan
Write-Host "Testing: Sending 50 rapid requests to test rate limiting" -ForegroundColor Gray
Write-Host "Expected: System should limit or throttle excessive requests" -ForegroundColor Gray
Write-Host ""

$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$success = 0
$failed = 0
$startTime = Get-Date

1..50 | ForEach-Object {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
            -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
            -Body "{\"value\": $_}" -TimeoutSec 5 -ErrorAction Stop
        $success++
    } catch {
        $failed++
    }
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host "Results: $success requests succeeded, $failed requests failed" -ForegroundColor Gray
Write-Host "Duration: $([math]::Round($duration, 2)) seconds" -ForegroundColor Gray
Write-Host ""

# If all requests succeed, no rate limiting = VULNERABILITY
if ($failed -eq 0 -and $success -eq 50) {
    Write-Host "Result: All 50 requests accepted - no rate limiting detected" -ForegroundColor Red
    Write-Host "[X] VULNERABILITY: System lacks rate limiting - vulnerable to DoS attacks" -ForegroundColor Red
} elseif ($failed -gt 0) {
    Write-Host "Result: Some requests rejected - rate limiting may be active" -ForegroundColor Green
    Write-Host "[OK] SECURE: System appears to have DoS protection" -ForegroundColor Green
} else {
    Write-Host "Result: Unexpected test outcome" -ForegroundColor Yellow
    Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
}
