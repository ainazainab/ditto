# Test 1: Unauthorized Write Access
# This script tests if the system blocks unauthorized write attempts

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST 1: Unauthorized Write Access" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1.1: No Authentication
Write-Host "[1.1] Testing write WITHOUT authentication..." -ForegroundColor Yellow
Write-Host "Command: curl -X PUT ... (no auth)" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT `
        -Headers @{"Content-Type"="application/json"} `
        -Body '{"value": 999}' `
        -ErrorAction Stop
    
    Write-Host "✗✗✗ VULNERABILITY FOUND! ✗✗✗" -ForegroundColor Red
    Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Red
    Write-Host "  Response: $($response.Content)" -ForegroundColor Red
    Write-Host "  SECURITY ISSUE: Write succeeded without authentication!" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "✓ Status Code: $statusCode" -ForegroundColor Green
    if ($statusCode -eq 401) {
        Write-Host "✓ SECURE: System correctly blocks unauthorized writes" -ForegroundColor Green
    } elseif ($statusCode -eq 403) {
        Write-Host "✓ SECURE: System correctly blocks unauthorized writes (403 Forbidden)" -ForegroundColor Green
    } else {
        Write-Host "? Unexpected status code: $statusCode" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 1.2: Wrong Credentials
Write-Host "[1.2] Testing write with WRONG credentials..." -ForegroundColor Yellow
Write-Host "Command: curl -X PUT ... -u wrong:password" -ForegroundColor Gray
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("wrong:password"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT `
        -Headers @{
            "Content-Type"="application/json"
            "Authorization"="Basic $cred"
        } `
        -Body '{"value": 999}' `
        -ErrorAction Stop
    
    Write-Host "✗✗✗ VULNERABILITY FOUND! ✗✗✗" -ForegroundColor Red
    Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Red
    Write-Host "  Response: $($response.Content)" -ForegroundColor Red
    Write-Host "  SECURITY ISSUE: Write succeeded with wrong credentials!" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "✓ Status Code: $statusCode" -ForegroundColor Green
    if ($statusCode -eq 401) {
        Write-Host "✓ SECURE: System correctly rejects wrong credentials" -ForegroundColor Green
    } elseif ($statusCode -eq 403) {
        Write-Host "✓ SECURE: System correctly rejects wrong credentials (403 Forbidden)" -ForegroundColor Green
    } else {
        Write-Host "? Unexpected status code: $statusCode" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 1.3: Valid Credentials (Baseline - should work)
Write-Host "[1.3] Testing write with VALID credentials (baseline test)..." -ForegroundColor Yellow
Write-Host "Command: curl -X PUT ... -u ditto:ditto" -ForegroundColor Gray
Write-Host ""

try {
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT `
        -Headers @{
            "Content-Type"="application/json"
            "Authorization"="Basic $cred"
        } `
        -Body '{"value": 25}' `
        -ErrorAction Stop
    
    Write-Host "✓ Status Code: $($response.StatusCode)" -ForegroundColor Green
    if ($response.StatusCode -eq 204 -or $response.StatusCode -eq 200) {
        Write-Host "✓ EXPECTED: Write succeeded with valid credentials" -ForegroundColor Green
        Write-Host "  This confirms the system is working correctly" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ ERROR: Valid write failed!" -ForegroundColor Red
    Write-Host "  Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Check if Ditto is running and thing exists" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST 1 COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Document the results above" -ForegroundColor Gray
Write-Host "  2. Run Test 2: .\test2_input_validation.ps1" -ForegroundColor Gray
Write-Host "  3. Or see STEP_BY_STEP_TESTING.md for manual testing" -ForegroundColor Gray
Write-Host ""

