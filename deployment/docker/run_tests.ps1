# Professional Test Runner - Detailed Output for Demo
$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  Digital Twin Security Assessment - Vulnerability Testing" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
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
    @{Num="11"; Name="Missing HTTPS/TLS Enforcement"},
    @{Num="12"; Name="RBAC Privilege Escalation"},
    @{Num="13"; Name="WebSocket Auth"},
    @{Num="14"; Name="Container Network Isolation"},
    @{Num="15"; Name="Port Exposure Scan"}
)

$results = @()

foreach ($test in $tests) {
    $testFile = "tests\$($test.Num)_*.ps1"
    $file = Get-ChildItem $testFile -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($file) {
        Write-Host "-----------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host ""
        
        try {
            # Run test and capture output (including Write-Host via information stream)
            $output = & $file.FullName 6>&1 2>&1 | Out-String -Width 4096
            
            # Display the full test output
            Write-Host $output
            
            # Extract result and show colored status
            if ($output -match '\[OK\].*SECURE|SECURE.*\[OK\]') {
                $result = "SECURE"
                $results += @{Test=$test.Num; Result="SECURE"}
                Write-Host "Test $($test.Num) Result: [OK] SECURE" -ForegroundColor Green
            } elseif ($output -match '\[X\].*VULNERABILITY|VULNERABILITY.*\[X\]') {
                $result = "VULNERABILITY"
                $results += @{Test=$test.Num; Result="VULNERABILITY"}
                Write-Host "Test $($test.Num) Result: [X] VULNERABILITY" -ForegroundColor Red
            } elseif ($output -match '\[WARN\]') {
                $result = "WARN"
                $results += @{Test=$test.Num; Result="WARN"}
                Write-Host "Test $($test.Num) Result: [WARN]" -ForegroundColor Yellow
            } elseif ($output -match 'manual.*test|Requires.*browser|NOTE.*manual|\[SKIP\]') {
                $result = "SKIP"
                $results += @{Test=$test.Num; Result="SKIP"}
                Write-Host "Test $($test.Num) Result: [SKIP]" -ForegroundColor Gray
            } else {
                $result = "UNKNOWN"
                $results += @{Test=$test.Num; Result="UNKNOWN"}
                Write-Host "Test $($test.Num) Result: [?] UNKNOWN" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[ERROR] Test execution failed: $_" -ForegroundColor Red
            $results += @{Test=$test.Num; Result="ERROR"}
            Write-Host "Test $($test.Num) Result: [ERROR]" -ForegroundColor Red
        }
        
        Write-Host ""
        # Wait 2 seconds between tests
        Start-Sleep -Seconds 2
    }
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

$secure = ($results | Where-Object {$_.Result -eq "SECURE"}).Count
$vuln = ($results | Where-Object {$_.Result -eq "VULNERABILITY"}).Count
$warn = ($results | Where-Object {$_.Result -eq "WARN"}).Count
$skip = ($results | Where-Object {$_.Result -eq "SKIP"}).Count
$unknown = ($results | Where-Object {$_.Result -eq "UNKNOWN"}).Count

Write-Host "Total Tests: $($results.Count)" -ForegroundColor White
Write-Host ""
Write-Host "[OK] SECURE: $secure" -ForegroundColor Green
Write-Host "[X] VULNERABILITIES: $vuln" -ForegroundColor Red
if ($warn -gt 0) { Write-Host "[WARN] WARNINGS: $warn" -ForegroundColor Yellow }
if ($skip -gt 0) { Write-Host "[SKIP] SKIPPED: $skip" -ForegroundColor Gray }
if ($unknown -gt 0) { Write-Host "[?] UNKNOWN: $unknown" -ForegroundColor Yellow }
Write-Host ""
