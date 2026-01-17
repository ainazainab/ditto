# Test 5: Input Validation (Wrong Data Type)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Input Validation (Wrong Type: String)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": "hacked"}' -ErrorAction Stop
    if ($response.StatusCode -eq 204 -or $response.StatusCode -eq 200) {
        Write-Host "[X] VULNERABILITY: Accepted wrong type (string)! Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 400) {
        Write-Host "[OK] SECURE: Rejected (400 Bad Request)" -ForegroundColor Green
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

