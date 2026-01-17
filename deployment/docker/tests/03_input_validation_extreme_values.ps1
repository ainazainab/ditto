# Test 3: Input Validation (Extreme Values) - VULNERABILITY TEST
# Tests if system accepts unrealistic temperature values (1000°C)
try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": 1000}' -ErrorAction Stop
    
    # If request succeeds (200/204), system accepted extreme value = VULNERABILITY
    if ($response.StatusCode -eq 204 -or $response.StatusCode -eq 200) {
        Write-Host "[X] VULNERABILITY" -ForegroundColor Red
    } else {
        Write-Host "[OK] SECURE" -ForegroundColor Green
    }
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    # 400 = validation rejected = SECURE
    if ($code -eq 400) {
        Write-Host "[OK] SECURE" -ForegroundColor Green
    } 
    # Any other error might indicate vulnerability or system issue
    elseif ($code -eq 404) {
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
    else {
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
