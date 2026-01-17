# Restore Thing - Recreate if it was deleted
Write-Host "Restoring Thing..." -ForegroundColor Cyan

# Check if policy exists first
Write-Host "`n1. Checking policy..." -ForegroundColor Yellow
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

try {
    $policy = Invoke-RestMethod -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" -Headers @{Authorization=$auth}
    Write-Host "[OK] Policy exists: demo:sensor-policy" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Policy does not exist! Create it first using GET_ADMIN_ACCESS.md" -ForegroundColor Red
    exit 1
}

# Try to create thing
Write-Host "`n2. Creating thing..." -ForegroundColor Yellow

$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"
$thingJson = '{"thingId":"demo:sensor-1","policyId":"demo:sensor-policy","definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor","description":"Digital Twin for IoT security research"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}'

try {
    $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $thingJson -ErrorAction Stop
    Write-Host "[OK] Thing created successfully!" -ForegroundColor Green
    Write-Host "   Thing ID: $($result.thingId)" -ForegroundColor Cyan
    Write-Host "   Policy: $($result.policyId)" -ForegroundColor Cyan
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    
    if ($status -eq 409) {
        Write-Host "[OK] Thing already exists!" -ForegroundColor Green
    } elseif ($status -eq 403) {
        Write-Host "[FAIL] Access forbidden (403)" -ForegroundColor Red
        Write-Host "`n   This means policy exists but you don't have permission to create things" -ForegroundColor Yellow
        Write-Host "   SOLUTION: Use UI method:" -ForegroundColor Cyan
        Write-Host "   1. Open http://localhost:8080" -ForegroundColor Cyan
        Write-Host "   2. Login: ditto/ditto" -ForegroundColor Cyan
        Write-Host "   3. Create thing: demo:sensor-1" -ForegroundColor Cyan
        Write-Host "   4. Policy: demo:sensor-policy" -ForegroundColor Cyan
    } elseif ($status -eq 400) {
        Write-Host "[FAIL] Bad request (400) - JSON might be wrong" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    } else {
        Write-Host "[FAIL] Error: $($_.Exception.Message) (Status: $status)" -ForegroundColor Red
    }
}

# Verify
Write-Host "`n3. Verifying..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    $thing = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
    Write-Host "[OK] Thing verified!" -ForegroundColor Green
    Write-Host "   Temperature: $($thing.features.temp.properties.value)°C" -ForegroundColor Cyan
} catch {
    Write-Host "[WARN] Could not verify thing" -ForegroundColor Yellow
}

Write-Host "`nDone!" -ForegroundColor Green
