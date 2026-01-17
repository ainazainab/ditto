# Final Clean Test Runner - Suppresses all output except results
$ErrorActionPreference = "SilentlyContinue"

Write-Host "`n=== Security Tests ===" -ForegroundColor Cyan
Write-Host ""

$tests = @(
    @{Num="01"; Name="Unauthorized Write (No Auth)"},
    @{Num="02"; Name="Unauthorized Write (Wrong Creds)"},
    @{Num="03"; Name="Input Validation (Extreme Values)"},
    @{Num="04"; Name="Input Validation (Negative Values)"},
    @{Num="05"; Name="Input Validation (Wrong Type)"},
    @{Num="06"; Name="Input Validation (Malformed JSON)"},
    @{Num="07"; Name="Rate Limiting (DoS)"},
    @{Num="08"; Name="Replay Attack"},
    @{Num="09"; Name="RBAC Viewer Read"},
    @{Num="10"; Name="RBAC Viewer Write Attempt"},
    @{Num="11"; Name="RBAC Operator Write Telemetry"},
    @{Num="12"; Name="RBAC Operator Modify Thing"},
    @{Num="13"; Name="RBAC Privilege Escalation"},
    @{Num="14"; Name="WebSocket Auth"},
    @{Num="15"; Name="WebSocket Message Injection"},
    @{Num="16"; Name="Container Network Isolation"},
    @{Num="17"; Name="Port Exposure Scan"},
    @{Num="18"; Name="Digital Twin State Manipulation"},
    @{Num="19"; Name="Policy Bypass Attack"}
)

$results = @()

foreach ($test in $tests) {
    $testFile = "tests\$($test.Num)_*.ps1"
    $file = Get-ChildItem $testFile -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($file) {
        Write-Host "$($test.Num). $($test.Name)" -NoNewline -ForegroundColor White
        
        try {
            # Run test and capture ALL output (suppress console output)
            $output = & $file.FullName 2>&1 6>&1 | Out-String
            
            # Extract only the result line
            if ($output -match '\[OK\].*SECURE') {
                Write-Host " -> [OK] SECURE" -ForegroundColor Green
                $results += @{Test=$test.Num; Result="SECURE"}
            } elseif ($output -match '\[X\].*VULNERABILITY') {
                Write-Host " -> [X] VULNERABILITY" -ForegroundColor Red
                $results += @{Test=$test.Num; Result="VULNERABILITY"}
            } elseif ($output -match '\[WARN\]') {
                Write-Host " -> [WARN]" -ForegroundColor Yellow
                $results += @{Test=$test.Num; Result="WARN"}
            } elseif ($output -match 'Viewer user not found|Operator user not found|Requires.*user|manual.*test') {
                Write-Host " -> [SKIP]" -ForegroundColor Gray
                $results += @{Test=$test.Num; Result="SKIP"}
            } else {
                Write-Host " -> [?]" -ForegroundColor Gray
                $results += @{Test=$test.Num; Result="UNKNOWN"}
            }
        } catch {
            Write-Host " -> [ERROR]" -ForegroundColor Red
            $results += @{Test=$test.Num; Result="ERROR"}
        }
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$secure = ($results | Where-Object {$_.Result -eq "SECURE"}).Count
$vuln = ($results | Where-Object {$_.Result -eq "VULNERABILITY"}).Count
$warn = ($results | Where-Object {$_.Result -eq "WARN"}).Count
$skip = ($results | Where-Object {$_.Result -eq "SKIP"}).Count
Write-Host "SECURE: $secure" -ForegroundColor Green
Write-Host "VULNERABILITIES: $vuln" -ForegroundColor Red
Write-Host "WARNINGS: $warn" -ForegroundColor Yellow
if ($skip -gt 0) { Write-Host "SKIPPED: $skip" -ForegroundColor Gray }
Write-Host ""
