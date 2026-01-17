# Test 17: Port Exposure Scan
# Purpose: Verify that sensitive services are not exposed to external network
# Expected: Only necessary ports (8080 nginx, 5000 dashboard) should be exposed
# Vulnerability: Exposing database ports (27017 MongoDB) allows direct database access

Write-Host "Test 17: Port Exposure Scan" -ForegroundColor Cyan
Write-Host "Testing: Scanning for exposed ports on localhost" -ForegroundColor Gray
Write-Host "Expected: Only application ports (8080, 5000) should be accessible externally" -ForegroundColor Gray
Write-Host "Vulnerability: Database port exposure allows direct database access bypassing application security" -ForegroundColor Gray
Write-Host ""

$vulnerable = $false
$exposedPorts = @()
$ports = @(
    @{Port=8080; Service="Nginx"; Expected=$true},
    @{Port=5000; Service="Dashboard"; Expected=$true},
    @{Port=27017; Service="MongoDB"; Expected=$false},
    @{Port=8081; Service="Gateway"; Expected=$false}
)

foreach ($portInfo in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $portInfo.Port -WarningAction SilentlyContinue -InformationLevel Quiet
        if ($connection) {
            $exposedPorts += $portInfo
            if (-not $portInfo.Expected) {
                $vulnerable = $true
                Write-Host "Port $($portInfo.Port) ($($portInfo.Service)): EXPOSED" -ForegroundColor Red
            } else {
                Write-Host "Port $($portInfo.Port) ($($portInfo.Service)): EXPOSED (expected)" -ForegroundColor Gray
            }
        } else {
            Write-Host "Port $($portInfo.Port) ($($portInfo.Service)): CLOSED" -ForegroundColor Green
        }
    } catch {
        Write-Host "Port $($portInfo.Port) ($($portInfo.Service)): CLOSED" -ForegroundColor Green
    }
}

Write-Host ""
if ($vulnerable) {
    Write-Host "Result: Sensitive services are exposed to external network" -ForegroundColor Red
    $vulnerableServices = $exposedPorts | Where-Object {-not $_.Expected}
    foreach ($svc in $vulnerableServices) {
        Write-Host "  - $($svc.Service) on port $($svc.Port) is accessible externally" -ForegroundColor Red
    }
    Write-Host "[X] VULNERABILITY: Database/internal services exposed - allows direct access bypassing security" -ForegroundColor Red
} else {
    Write-Host "Result: Only expected ports are exposed" -ForegroundColor Green
    Write-Host "[OK] SECURE: Sensitive services are not exposed externally" -ForegroundColor Green
}
