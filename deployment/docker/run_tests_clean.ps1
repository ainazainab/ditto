# Clean Test Runner - Shows only test name and result
Write-Host "`n=== Running Security Tests ===" -ForegroundColor Cyan
Write-Host ""

$testFiles = @(
    "01_unauthorized_write_no_auth.ps1",
    "02_unauthorized_write_wrong_creds.ps1",
    "03_input_validation_extreme_values.ps1",
    "04_input_validation_negative_values.ps1",
    "05_input_validation_wrong_type.ps1",
    "06_input_validation_malformed_json.ps1",
    "07_rate_limiting_dos.ps1",
    "08_replay_attack.ps1",
    "09_rbac_viewer_read.ps1",
    "10_rbac_viewer_write_attempt.ps1",
    "11_rbac_operator_write_telemetry.ps1",
    "12_rbac_operator_modify_thing.ps1",
    "13_rbac_privilege_escalation.ps1",
    "14_websocket_auth.ps1",
    "15_websocket_message_injection.ps1",
    "16_container_network_isolation.ps1",
    "17_port_exposure_scan.ps1",
    "18_digital_twin_state_manipulation.ps1",
    "19_policy_bypass_attack.ps1"
)

$results = @()

foreach ($test in $testFiles) {
    $testPath = "deployment/docker/tests/$test"
    if (Test-Path $testPath) {
        $testNum = $test.Substring(0, 2)
        $testName = $test.Substring(3, $test.Length - 8).Replace("_", " ")
        
        Write-Host "$testNum. $testName" -NoNewline -ForegroundColor White
        
        try {
            $output = & $testPath 2>&1 | Out-String
            
            if ($output -match "\[OK\]|SECURE") {
                Write-Host " -> [OK] SECURE" -ForegroundColor Green
                $results += [PSCustomObject]@{Test=$testNum; Name=$testName; Result="SECURE"}
            } elseif ($output -match "\[X\]|VULNERABILITY") {
                Write-Host " -> [X] VULNERABILITY" -ForegroundColor Red
                $results += [PSCustomObject]@{Test=$testNum; Name=$testName; Result="VULNERABILITY"}
            } elseif ($output -match "\[WARN\]") {
                Write-Host " -> [WARN]" -ForegroundColor Yellow
                $results += [PSCustomObject]@{Test=$testNum; Name=$testName; Result="WARN"}
            } else {
                Write-Host " -> [?] UNKNOWN" -ForegroundColor Gray
                $results += [PSCustomObject]@{Test=$testNum; Name=$testName; Result="UNKNOWN"}
            }
        } catch {
            Write-Host " -> [ERROR]" -ForegroundColor Red
            $results += [PSCustomObject]@{Test=$testNum; Name=$testName; Result="ERROR"}
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
