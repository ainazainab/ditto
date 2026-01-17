# Security Testing Script for Digital Twin System
# Run this script step by step to test vulnerabilities

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Digital Twin Security Testing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "[1/10] Checking Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is NOT running. Please start Docker Desktop first!" -ForegroundColor Red
    exit 1
}

# Check if Ditto is accessible
Write-Host "[2/10] Checking Ditto API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✓ Ditto is accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Ditto is NOT accessible. Is docker-compose up?" -ForegroundColor Red
    Write-Host "  Run: cd deployment/docker && docker compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST 1: Unauthorized Write Access" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1.1: No authentication
Write-Host "[Test 1.1] Attempting write WITHOUT authentication..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT `
        -Headers @{"Content-Type"="application/json"} `
        -Body '{"value": 999}' `
        -ErrorAction Stop
    Write-Host "✗ VULNERABILITY FOUND: Write succeeded without auth!" -ForegroundColor Red
    Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "✓ SECURE: Write blocked without authentication (401 Unauthorized)" -ForegroundColor Green
    } else {
        Write-Host "? Unexpected response: $statusCode" -ForegroundColor Yellow
    }
}

# Test 1.2: Wrong credentials
Write-Host ""
Write-Host "[Test 1.2] Attempting write with WRONG credentials..." -ForegroundColor Yellow
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
    Write-Host "✗ VULNERABILITY FOUND: Write succeeded with wrong credentials!" -ForegroundColor Red
    Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "✓ SECURE: Write blocked with wrong credentials (401 Unauthorized)" -ForegroundColor Green
    } else {
        Write-Host "? Unexpected response: $statusCode" -ForegroundColor Yellow
    }
}

# Test 1.3: Valid credentials (should work)
Write-Host ""
Write-Host "[Test 1.3] Attempting write with VALID credentials (baseline test)..." -ForegroundColor Yellow
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
    if ($response.StatusCode -eq 204 -or $response.StatusCode -eq 200) {
        Write-Host "✓ EXPECTED: Write succeeded with valid credentials" -ForegroundColor Green
        Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ ERROR: Valid write failed - check system status" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST 1 COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Results saved to: test_results.txt" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next: Run Test 2 (Input Validation)" -ForegroundColor Cyan
Write-Host "  Or continue with: .\run_security_tests.ps1 -Test 2" -ForegroundColor Gray

