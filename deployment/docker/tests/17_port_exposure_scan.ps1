# Test 17: Port Exposure Scan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Port Exposure Scan" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Scanning localhost for open ports..." -ForegroundColor Yellow
Write-Host ""

$ports = @(8080, 5000, 27017, 8081, 8082)

foreach ($port in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -InformationLevel Quiet
        if ($connection) {
            Write-Host "[OPEN] Port $port is OPEN" -ForegroundColor Yellow
            switch ($port) {
                8080 { Write-Host "  → Nginx (expected)" -ForegroundColor Gray }
                5000 { Write-Host "  → Dashboard (expected)" -ForegroundColor Gray }
                27017 { Write-Host "  -> [WARN] MongoDB exposed (vulnerability if should be internal)" -ForegroundColor Red }
                default { Write-Host "  → Unknown service" -ForegroundColor Gray }
            }
        } else {
            Write-Host "[X] Port $port is CLOSED" -ForegroundColor Green
        }
    } catch {
        Write-Host "[X] Port $port is CLOSED" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Expected: Only 8080 (nginx) and 5000 (dashboard) should be open" -ForegroundColor Green
Write-Host "If 27017 (MongoDB) is open: VULNERABILITY - Database exposed" -ForegroundColor Red

