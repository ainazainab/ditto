# Apply All Security Fixes to Digital Twin
# This script applies all security hardening measures in order

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Digital Twin Security Hardening" -ForegroundColor Cyan
Write-Host "Applying All Security Fixes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$fixesApplied = @()

# Fix 1: RBAC Policies
Write-Host "[1/4] Applying RBAC Policies..." -ForegroundColor Yellow
try {
    & ".\security_fixes\rbac\apply_rbac_policies.ps1"
    $fixesApplied += @{
        name = "RBAC Policies"
        status = "applied"
        timestamp = Get-Date -Format "o"
    }
    Write-Host "[OK] RBAC policies applied" -ForegroundColor Green
} catch {
    Write-Host "[X] Failed to apply RBAC: $($_.Exception.Message)" -ForegroundColor Red
    $fixesApplied += @{
        name = "RBAC Policies"
        status = "failed"
        error = $_.Exception.Message
        timestamp = Get-Date -Format "o"
    }
}

Write-Host ""

# Fix 2: Input Validation
Write-Host "[2/4] Applying Input Validation..." -ForegroundColor Yellow
try {
    & ".\security_fixes\validation\add_input_validation.ps1"
    $fixesApplied += @{
        name = "Input Validation"
        status = "applied"
        timestamp = Get-Date -Format "o"
    }
    Write-Host "[OK] Input validation applied" -ForegroundColor Green
} catch {
    Write-Host "[X] Failed to apply validation: $($_.Exception.Message)" -ForegroundColor Red
    $fixesApplied += @{
        name = "Input Validation"
        status = "failed"
        error = $_.Exception.Message
        timestamp = Get-Date -Format "o"
    }
}

Write-Host ""

# Fix 3: Rate Limiting
Write-Host "[3/4] Applying Rate Limiting..." -ForegroundColor Yellow
try {
    & ".\security_fixes\rate_limiting\apply_rate_limiting.ps1"
    $fixesApplied += @{
        name = "Rate Limiting"
        status = "applied"
        timestamp = Get-Date -Format "o"
    }
    Write-Host "[OK] Rate limiting applied" -ForegroundColor Green
    Write-Host "  Note: Restart nginx to apply: docker compose restart nginx" -ForegroundColor Gray
} catch {
    Write-Host "[X] Failed to apply rate limiting: $($_.Exception.Message)" -ForegroundColor Red
    $fixesApplied += @{
        name = "Rate Limiting"
        status = "failed"
        error = $_.Exception.Message
        timestamp = Get-Date -Format "o"
    }
}

Write-Host ""

# Fix 4: Network Security (manual step)
Write-Host "[4/4] Network Security..." -ForegroundColor Yellow
Write-Host "  Network segmentation requires docker-compose.yml changes" -ForegroundColor Gray
Write-Host "  See SECURITY_HARDENING_PLAN.md for details" -ForegroundColor Gray
$fixesApplied += @{
    name = "Network Security"
    status = "manual"
    note = "Requires docker-compose.yml modification"
    timestamp = Get-Date -Format "o"
}

Write-Host ""

# Save fixes applied log
$fixesDir = "security_results"
if (-not (Test-Path $fixesDir)) {
    New-Item -ItemType Directory -Path $fixesDir | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$fixesFile = "$fixesDir/fixes_applied_$timestamp.json"
$fixesLog = @{
    timestamp = $timestamp
    fixes = $fixesApplied
} | ConvertTo-Json -Depth 10

$fixesLog | Out-File -FilePath $fixesFile -Encoding UTF8

# Generate human-readable log
$logFile = "$fixesDir/fixes_applied_$timestamp.md"
$log = @"
# Security Fixes Applied
Timestamp: $timestamp

## Fixes Applied

"@

foreach ($fix in $fixesApplied) {
    $statusIcon = switch ($fix.status) {
        "applied" { "[OK]" }
        "failed" { "[X]" }
        "manual" { "[MANUAL]" }
        default { "[?]" }
    }
    
    $log += @"
### $($fix.name)
- Status: $statusIcon $($fix.status)
- Timestamp: $($fix.timestamp)
$(if ($fix.error) { "- Error: $($fix.error)" })
$(if ($fix.note) { "- Note: $($fix.note)" })

"@
}

$log | Out-File -FilePath $logFile -Encoding UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Security Hardening Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fixes applied: $($fixesApplied.Count)" -ForegroundColor Yellow
Write-Host "Results saved to:" -ForegroundColor Yellow
Write-Host "  - $fixesFile" -ForegroundColor Gray
Write-Host "  - $logFile" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Restart nginx: docker compose restart nginx" -ForegroundColor Gray
Write-Host "  2. Re-run tests: .\record_tests.ps1 -AllTests" -ForegroundColor Gray
Write-Host "  3. Compare before/after results" -ForegroundColor Gray
Write-Host ""

