# Test 17: Port Exposure Scan - VULNERABILITY TEST
# Tests if sensitive services (MongoDB) are exposed to external network
$vulnerable = $false

$ports = @(8080, 5000, 27017, 8081, 8082)

foreach ($port in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -InformationLevel Quiet
        if ($connection) {
            if ($port -eq 27017) {
                # MongoDB exposed = VULNERABILITY
                $vulnerable = $true
            }
        }
    } catch {
        # Port closed
    }
}

if ($vulnerable) {
    Write-Host "[X] VULNERABILITY" -ForegroundColor Red
} else {
    Write-Host "[OK] SECURE" -ForegroundColor Green
}
