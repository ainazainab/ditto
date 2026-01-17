# Test 4: Input Validation (Negative Values) - VULNERABILITY TEST
# Tests if system accepts negative temperature values (-200°C)
try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": -200}' -ErrorAction Stop
    
    # If request succeeds, system accepted negative value = VULNERABILITY
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
    } else {
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
