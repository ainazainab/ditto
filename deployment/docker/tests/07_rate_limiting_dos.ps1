# Test 7: Rate Limiting (DoS Attack Simulation)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Rate Limiting (DoS: 50 requests)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
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

Write-Host "Results: $success succeeded, $failed failed in $duration seconds" -ForegroundColor Yellow
if ($failed -gt 0) {
        Write-Host "[WARN] Possible rate limiting or DoS protection" -ForegroundColor Green
} else {
        Write-Host "[WARN] No rate limiting detected (all requests accepted)" -ForegroundColor Red
}

