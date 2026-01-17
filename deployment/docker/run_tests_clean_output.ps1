# Clean Test Runner - Shows only test name and result
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
            # Capture only the last line of output (the result)
            $output = & $file.FullName 2>&1 | Out-String
            $lastLine = ($output -split "`n" | Where-Object {$_ -match "\[OK\]|\[X\]|\[WARN\]|\[?\]"} | Select-Object -Last 1).Trim()
            
            if ($lastLine -match "\[OK\].*SECURE") {
                Write-Host " -> [OK] SECURE" -ForegroundColor Green
                $results += @{Test=$test.Num; Result="SECURE"}
            } elseif ($lastLine -match "\[X\].*VULNERABILITY") {
                Write-Host " -> [X] VULNERABILITY" -ForegroundColor Red
                $results += @{Test=$test.Num; Result="VULNERABILITY"}
            } elseif ($lastLine -match "\[WARN\]") {
                Write-Host " -> [WARN]" -ForegroundColor Yellow
                $results += @{Test=$test.Num; Result="WARN"}
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
Write-Host "SECURE: $secure" -ForegroundColor Green
Write-Host "VULNERABILITIES: $vuln" -ForegroundColor Red
Write-Host "WARNINGS: $warn" -ForegroundColor Yellow
Write-Host ""
