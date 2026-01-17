# Test 8: Replay Attack - VULNERABILITY TEST
# Tests if system has replay attack protection
# VULNERABILITY: If system accepts identical requests without nonce/timestamp validation
$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

try {
    # First request with specific value
    $response1 = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 25.5}' -ErrorAction Stop
    
    Start-Sleep -Seconds 1
    
    # Replay the EXACT same request (replay attack simulation)
    $response2 = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 25.5}' -ErrorAction Stop
    
    # If both succeed, system accepts replay without protection = VULNERABILITY
    # No nonce, timestamp, or request ID validation = vulnerable to replay attacks
    Write-Host "[X] VULNERABILITY" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    # If replay is rejected (400/403), system has replay protection = SECURE
    if ($code -eq 400 -or $code -eq 403) {
        Write-Host "[OK] SECURE" -ForegroundColor Green
    } else {
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
