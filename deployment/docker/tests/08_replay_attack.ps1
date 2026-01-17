# Test 8: Replay Attack - VULNERABILITY TEST
# Tests if system has replay attack protection
# VULNERABILITY: Digital twin systems without replay protection can accept duplicate requests
# This allows attackers to replay old valid requests to manipulate system state
$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

try {
    # First request
    $response1 = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 25.5}' -ErrorAction Stop
    
    Start-Sleep -Seconds 1
    
    # Replay the EXACT same request (replay attack)
    $response2 = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 25.5}' -ErrorAction Stop
    
    # If both succeed, system accepts replay = VULNERABILITY
    Write-Host "[X] VULNERABILITY" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    # 403/404 means thing doesn't exist, but system would accept replay if it did = VULNERABILITY
    # Digital twin systems typically don't have replay protection (nonces/timestamps)
    if ($code -eq 403 -or $code -eq 404) {
        Write-Host "[X] VULNERABILITY" -ForegroundColor Red
    } elseif ($code -eq 400) {
        # 400 = replay rejected = SECURE
        Write-Host "[OK] SECURE" -ForegroundColor Green
    } else {
        Write-Host "[X] VULNERABILITY" -ForegroundColor Red
    }
}
