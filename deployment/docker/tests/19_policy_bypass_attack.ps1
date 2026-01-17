# Test 19: Policy Bypass Attack
# Try to access Digital Twin without proper policy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Policy Bypass Attack" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

# Test 1: Try to access thing without policy
Write-Host "[1/3] Attempting to access thing without policy..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/demo:sensor-1" `
        -Headers @{"Authorization"="Basic $cred"} -ErrorAction Stop
    $thing = $response.Content | ConvertFrom-Json
    if (-not $thing.policyId) {
        Write-Host "[WARN] VULNERABILITY: Thing accessible without policy!" -ForegroundColor Red
    } else {
        Write-Host "[OK] Thing has policy: $($thing.policyId)" -ForegroundColor Green
    }
} catch {
    Write-Host "[?] Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test 2: Try to create thing with invalid policy
Write-Host "[2/3] Attempting to create thing with invalid policy..." -ForegroundColor Yellow
try {
    $newThing = @{
        thingId = "demo:test-thing-$(Get-Random)"
        policyId = "nonexistent:policy"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/$($newThing.thingId)" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body $newThing -ErrorAction Stop
    Write-Host "[WARN] VULNERABILITY: Thing created with invalid policy! Status: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 404 -or $code -eq 400) {
        Write-Host "[OK] SECURE: Invalid policy rejected" -ForegroundColor Green
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

# Test 3: Try to access thing with wrong subject in policy
Write-Host "[3/3] Testing policy subject validation..." -ForegroundColor Yellow
Write-Host "  (This requires RBAC setup to test properly)" -ForegroundColor Gray
Write-Host "  Policy should only allow authorized subjects" -ForegroundColor Gray

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Policy Bypass Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

