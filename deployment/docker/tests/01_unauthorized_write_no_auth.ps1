# Test 1: Unauthorized Write Access (No Authentication)
# Purpose: Verify that write operations require authentication
# Expected: System should reject requests without credentials (401 Unauthorized)
# Vulnerability: If write succeeds without auth, system is vulnerable to unauthorized modifications

Write-Host "Test 1: Unauthorized Write Access (No Authentication)" -ForegroundColor Cyan
Write-Host "Testing: Attempting to modify temperature without providing credentials" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"} -Body '{"value": 999}' -ErrorAction Stop
    
    Write-Host "Result: Request succeeded without authentication" -ForegroundColor Red
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Red
    Write-Host "[X] VULNERABILITY: System accepts unauthorized writes" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401) {
        Write-Host "Result: Request rejected - authentication required" -ForegroundColor Green
        Write-Host "Status Code: 401 Unauthorized" -ForegroundColor Green
        Write-Host "[OK] SECURE: System properly enforces authentication" -ForegroundColor Green
    } else {
        Write-Host "Result: Unexpected response" -ForegroundColor Yellow
        Write-Host "Status Code: $code" -ForegroundColor Yellow
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
