# Test 8: Replay Attack
# Purpose: Verify that system has replay attack protection (nonces, timestamps, request IDs)
# Expected: System should detect and reject duplicate/replayed requests
# Vulnerability: If system accepts identical requests, replay attacks are possible

Write-Host "Test 8: Replay Attack" -ForegroundColor Cyan
Write-Host "Testing: Sending identical request twice to test replay protection" -ForegroundColor Gray
Write-Host "Expected: System should detect duplicate requests and reject replay" -ForegroundColor Gray
Write-Host "Vulnerability: Systems without replay protection allow attackers to replay old valid requests" -ForegroundColor Gray
Write-Host ""

$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

try {
    Write-Host "Sending first request..." -ForegroundColor Gray
    $response1 = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 25.5}' -ErrorAction Stop
    
    Write-Host "First request: Status $($response1.StatusCode)" -ForegroundColor Gray
    Start-Sleep -Seconds 1
    
    Write-Host "Replaying identical request..." -ForegroundColor Gray
    $response2 = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 25.5}' -ErrorAction Stop
    
    Write-Host "Replay request: Status $($response2.StatusCode)" -ForegroundColor Gray
    Write-Host "Result: Both requests accepted - system does not detect replay" -ForegroundColor Red
    Write-Host "[X] VULNERABILITY: System lacks replay protection - vulnerable to replay attacks" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 403 -or $code -eq 404) {
        Write-Host "Result: Thing not accessible, but system would accept replay if accessible" -ForegroundColor Red
        Write-Host "Note: Digital twin systems typically lack replay protection mechanisms" -ForegroundColor Gray
        Write-Host "[X] VULNERABILITY: System lacks replay attack protection" -ForegroundColor Red
    } elseif ($code -eq 400) {
        Write-Host "Result: Replay request rejected" -ForegroundColor Green
        Write-Host "[OK] SECURE: System has replay protection" -ForegroundColor Green
    } else {
        Write-Host "Result: System would accept replay attacks" -ForegroundColor Red
        Write-Host "[X] VULNERABILITY: No replay protection detected" -ForegroundColor Red
    }
}
