# Complete Setup - Create Thing and Verify Everything
Write-Host "Setting up everything for live updates..." -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Step 1: Check policy
Write-Host "`n1. Checking policy..." -ForegroundColor Yellow
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
try {
    $policy = Invoke-RestMethod -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" -Headers @{Authorization=$auth}
    Write-Host "[OK] Policy exists" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Policy does not exist!" -ForegroundColor Red
    Write-Host "   Create it first using GET_ADMIN_ACCESS.md" -ForegroundColor Yellow
    Write-Host "   Then run this script again" -ForegroundColor Yellow
    exit 1
}

# Step 2: Try to create thing (without policyId in JSON - let UI handle it)
Write-Host "`n2. Creating thing..." -ForegroundColor Yellow
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"

# JSON WITHOUT policyId - Ditto will use the policy from the thing creation
$thingJson = '{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}'

try {
    # First try with policyId in URL/header approach
    $result = Invoke-RestMethod -Uri "$thingUrl?policyId=demo:sensor-policy" -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $thingJson -ErrorAction Stop
    Write-Host "[OK] Thing created!" -ForegroundColor Green
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    if ($status -eq 409) {
        Write-Host "[OK] Thing already exists" -ForegroundColor Green
    } elseif ($status -eq 403 -or $status -eq 400) {
        Write-Host "[FAIL] Cannot create via API (Status: $status)" -ForegroundColor Red
        Write-Host "`n   SOLUTION: Create thing in UI:" -ForegroundColor Yellow
        Write-Host "   1. Open http://localhost:8080" -ForegroundColor Cyan
        Write-Host "   2. Login: ditto/ditto" -ForegroundColor Cyan
        Write-Host "   3. Create thing: demo:sensor-1" -ForegroundColor Cyan
        Write-Host "   4. Policy ID field: Select 'demo:sensor-policy'" -ForegroundColor Cyan
        Write-Host "   5. Edit JSON: Paste JSON (NO policyId in JSON!)" -ForegroundColor Cyan
        Write-Host "   6. Save" -ForegroundColor Cyan
        Write-Host "`n   Waiting 60 seconds for you to create it..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
    } else {
        Write-Host "[FAIL] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 3: Verify thing exists
Write-Host "`n3. Verifying thing..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    $thing = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
    Write-Host "[OK] Thing verified: $($thing.thingId)" -ForegroundColor Green
    Write-Host "   Policy: $($thing.policyId)" -ForegroundColor Cyan
    if ($thing.features.temp.properties.value) {
        Write-Host "   Temperature: $($thing.features.temp.properties.value)°C" -ForegroundColor Cyan
    }
} catch {
    Write-Host "[FAIL] Thing still doesn't exist" -ForegroundColor Red
    Write-Host "   Please create it manually in UI" -ForegroundColor Yellow
    exit 1
}

# Step 4: Check sensor
Write-Host "`n4. Checking sensor..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$sensorLogs = docker compose logs sensor --tail 10 2>&1
if ($sensorLogs -match "sent successfully") {
    Write-Host "[OK] Sensor is sending data!" -ForegroundColor Green
} else {
    Write-Host "[WARN] Sensor not sending yet - may need a moment" -ForegroundColor Yellow
    Write-Host "   Check: docker compose logs -f sensor" -ForegroundColor Cyan
}

# Step 5: Test live updates
Write-Host "`n5. Testing live updates..." -ForegroundColor Yellow
Start-Sleep -Seconds 6
try {
    $thing1 = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
    $temp1 = $thing1.features.temp.properties.value
    Write-Host "   Temperature 1: $temp1°C" -ForegroundColor Cyan
    Start-Sleep -Seconds 6
    $thing2 = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
    $temp2 = $thing2.features.temp.properties.value
    Write-Host "   Temperature 2: $temp2°C" -ForegroundColor Cyan
    if ($temp1 -ne $temp2) {
        Write-Host "[OK] Live updates working! Temperature is changing!" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Temperature stable (sensor updates every 5 seconds)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARN] Could not test live updates" -ForegroundColor Yellow
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "`nDashboard: http://localhost:5000" -ForegroundColor Cyan
Write-Host "Ditto UI: http://localhost:8080" -ForegroundColor Cyan

