# Record Security Test Results
# This script runs all tests and records results in JSON format

param(
    [switch]$AllTests,
    [int[]]$TestNumbers
)

$ErrorActionPreference = "Continue"
# Suppress PowerShell security warnings for web requests
$PSDefaultParameterValues['Invoke-WebRequest:UseBasicParsing'] = $true

# Create results directory
$resultsDir = "security_results"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$resultsFile = "$resultsDir/test_results_$timestamp.json"
$results = @{
    timestamp = $timestamp
    tests = @()
    summary = @{
        total = 0
        passed = 0
        failed = 0
        vulnerabilities = 0
    }
}

# Function to run a test and capture output
function Run-Test {
    param($testFile, $testNumber, $testName)
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Running Test $testNumber : $testName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $testResult = @{
        number = $testNumber
        name = $testName
        file = $testFile
        timestamp = Get-Date -Format "o"
        status = "unknown"
        output = ""
        vulnerability_found = $false
        severity = "unknown"
    }
    
    try {
        $output = & ".\tests\$testFile" 2>&1 | Out-String
        
        $testResult.output = $output
        
        # Parse output for results
        if ($output -match "\[OK\]") {
            $testResult.status = "passed"
            $testResult.vulnerability_found = $false
            $results.summary.passed++
        } elseif ($output -match "\[X\]|\[WARN\].*VULNERABILITY") {
            $testResult.status = "failed"
            $testResult.vulnerability_found = $true
            $testResult.severity = if ($output -match "CRITICAL") { "critical" } 
                                   elseif ($output -match "VULNERABILITY") { "high" }
                                   else { "medium" }
            $results.summary.failed++
            $results.summary.vulnerabilities++
        } else {
            $testResult.status = "unknown"
            $results.summary.failed++
        }
        
        $results.summary.total++
        Write-Host "Result: $($testResult.status)" -ForegroundColor $(if ($testResult.vulnerability_found) { "Red" } else { "Green" })
        
    } catch {
        $testResult.status = "error"
        $testResult.output = $_.Exception.Message
        $results.summary.failed++
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    $results.tests += $testResult
    return $testResult
}

# Test definitions - All 19 tests
$testDefinitions = @(
    @{ num = 1; file = "01_unauthorized_write_no_auth.ps1"; name = "Unauthorized Write (No Auth)" }
    @{ num = 2; file = "02_unauthorized_write_wrong_creds.ps1"; name = "Unauthorized Write (Wrong Creds)" }
    @{ num = 3; file = "03_input_validation_extreme_values.ps1"; name = "Input Validation (Extreme Values)" }
    @{ num = 4; file = "04_input_validation_negative_values.ps1"; name = "Input Validation (Negative Values)" }
    @{ num = 5; file = "05_input_validation_wrong_type.ps1"; name = "Input Validation (Wrong Type)" }
    @{ num = 6; file = "06_input_validation_malformed_json.ps1"; name = "Input Validation (Malformed JSON)" }
    @{ num = 7; file = "07_rate_limiting_dos.ps1"; name = "Rate Limiting (DoS)" }
    @{ num = 8; file = "08_replay_attack.ps1"; name = "Replay Attack" }
    @{ num = 9; file = "09_rbac_viewer_read.ps1"; name = "RBAC Viewer Read Only" }
    @{ num = 10; file = "10_rbac_viewer_write_attempt.ps1"; name = "RBAC Viewer Write Attempt" }
    @{ num = 11; file = "11_rbac_operator_write_telemetry.ps1"; name = "RBAC Operator Write Telemetry" }
    @{ num = 12; file = "12_rbac_operator_modify_thing.ps1"; name = "RBAC Operator Modify Thing" }
    @{ num = 13; file = "13_rbac_privilege_escalation.ps1"; name = "RBAC Privilege Escalation" }
    @{ num = 14; file = "14_websocket_auth.ps1"; name = "WebSocket Authentication" }
    @{ num = 15; file = "15_websocket_message_injection.ps1"; name = "WebSocket Message Injection" }
    @{ num = 16; file = "16_container_network_isolation.ps1"; name = "Container Network Isolation" }
    @{ num = 17; file = "17_port_exposure_scan.ps1"; name = "Port Exposure Scan" }
    @{ num = 18; file = "18_digital_twin_state_manipulation.ps1"; name = "Digital Twin State Manipulation" }
    @{ num = 19; file = "19_policy_bypass_attack.ps1"; name = "Policy Bypass Attack" }
)

# Determine which tests to run
if ($AllTests) {
    $testsToRun = $testDefinitions
} elseif ($TestNumbers) {
    $testsToRun = $testDefinitions | Where-Object { $TestNumbers -contains $_.num }
} else {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\record_tests.ps1 -AllTests" -ForegroundColor Gray
    Write-Host "  .\record_tests.ps1 -TestNumbers 1,2,3" -ForegroundColor Gray
    exit
}

# Run tests
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Digital Twin Security Testing" -ForegroundColor Cyan
Write-Host "Recording Results to: $resultsFile" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($test in $testsToRun) {
    Run-Test -testFile $test.file -testNumber $test.num -testName $test.name
}

# Save results
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsFile -Encoding UTF8

# Generate summary report
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Tests: $($results.summary.total)" -ForegroundColor Yellow
Write-Host "Passed: $($results.summary.passed)" -ForegroundColor Green
Write-Host "Failed: $($results.summary.failed)" -ForegroundColor Red
Write-Host "Vulnerabilities Found: $($results.summary.vulnerabilities)" -ForegroundColor Red
Write-Host ""
Write-Host "Results saved to: $resultsFile" -ForegroundColor Green

# Generate human-readable report
$reportFile = "$resultsDir/test_report_$timestamp.md"
$report = @"
# Security Test Report
Generated: $timestamp

## Summary
- Total Tests: $($results.summary.total)
- Passed: $($results.summary.passed)
- Failed: $($results.summary.failed)
- Vulnerabilities Found: $($results.summary.vulnerabilities)

## Test Results

"@

foreach ($test in $results.tests) {
    $statusIcon = if ($test.vulnerability_found) { "[X]" } else { "[OK]" }
    $report += @"
### Test $($test.number): $($test.name)
- Status: $statusIcon $($test.status)
- Vulnerability: $(if ($test.vulnerability_found) { "YES - $($test.severity)" } else { "NO" })
- Timestamp: $($test.timestamp)

``````
$($test.output)
``````

"@
}

$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host "Report saved to: $reportFile" -ForegroundColor Green

