# Test 7: Rate Limiting (DoS Attack Simulation) - VULNERABILITY TEST
# Tests if system has rate limiting to prevent DoS attacks
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

# If all requests succeed, no rate limiting = VULNERABILITY
if ($failed -eq 0 -and $success -eq 50) {
    Write-Host "[X] VULNERABILITY" -ForegroundColor Red
} elseif ($failed -gt 0) {
    Write-Host "[OK] SECURE" -ForegroundColor Green
} else {
    Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
}
