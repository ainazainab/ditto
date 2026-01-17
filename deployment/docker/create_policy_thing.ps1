# Create Policy and Thing - Working Solution
# This recreates the policy and thing that were working before

Write-Host "Creating Policy and Thing..." -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Step 1: Create Policy using DevOps credentials via Gateway
Write-Host "`nStep 1: Creating policy via DevOps API..." -ForegroundColor Yellow

$policyUrl = "http://localhost:8081/api/2/policies/demo:sensor-policy"
$policyJson = '{"entries":{"ditto":{"subjects":{"nginx:ditto":{"type":"user"}},"resources":{"thing:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]},"policy:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]}}}}}'

# Try with DevOps credentials
$devopsAuth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("devops:foobar"))

try {
    $result = Invoke-RestMethod -Uri $policyUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$devopsAuth} -Body $policyJson -ErrorAction Stop
    Write-Host "[OK] Policy created successfully!" -ForegroundColor Green
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    if ($status -eq 409) {
        Write-Host "[OK] Policy already exists" -ForegroundColor Yellow
    } else {
        Write-Host "[FAIL] Could not create policy via API (Status: $status)" -ForegroundColor Red
        Write-Host "`nPlease create policy manually:" -ForegroundColor Yellow
        Write-Host "1. Open http://localhost:8080" -ForegroundColor Cyan
        Write-Host "2. Click 'Authorize' -> DevOps: devops/foobar" -ForegroundColor Cyan
        Write-Host "3. Create policy: demo:sensor-policy" -ForegroundColor Cyan
        Write-Host "4. Use JSON from GET_ADMIN_ACCESS.md (lines 27-48)" -ForegroundColor Cyan
        Write-Host "`nWaiting 60 seconds for you to create policy..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
    }
}

# Step 2: Create Thing using regular credentials
Write-Host "`nStep 2: Creating thing..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"
$thingJson = '{"thingId":"demo:sensor-1","policyId":"demo:sensor-policy","definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}}'

$dittoAuth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

try {
    $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$dittoAuth} -Body $thingJson -ErrorAction Stop
    Write-Host "[OK] Thing created successfully!" -ForegroundColor Green
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    if ($status -eq 409) {
        Write-Host "[OK] Thing already exists" -ForegroundColor Yellow
    } elseif ($status -eq 403) {
        Write-Host "[FAIL] Access forbidden - policy might not exist yet" -ForegroundColor Red
        Write-Host "Please create thing manually in UI:" -ForegroundColor Yellow
        Write-Host "1. Open http://localhost:8080" -ForegroundColor Cyan
        Write-Host "2. Login: ditto/ditto" -ForegroundColor Cyan
        Write-Host "3. Create thing: demo:sensor-1" -ForegroundColor Cyan
        Write-Host "4. Policy: demo:sensor-policy" -ForegroundColor Cyan
        Write-Host "5. Use JSON from GET_ADMIN_ACCESS.md (lines 60-76)" -ForegroundColor Cyan
    } else {
        Write-Host "[FAIL] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 3: Verify
Write-Host "`nStep 3: Verifying..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    $thing = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$dittoAuth}
    Write-Host "[OK] Thing verified: $($thing.thingId)" -ForegroundColor Green
    Write-Host "[OK] Policy: $($thing.policyId)" -ForegroundColor Green
    if ($thing.features.temp.properties.value) {
        Write-Host "[OK] Temperature: $($thing.features.temp.properties.value)°C" -ForegroundColor Green
    }
} catch {
    Write-Host "[WARN] Could not verify thing" -ForegroundColor Yellow
}

# Step 4: Check sensor
Write-Host "`nStep 4: Checking sensor..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

$sensorLogs = docker compose logs sensor --tail 5 2>&1
if ($sensorLogs -match "sent successfully") {
    Write-Host "[OK] Sensor is sending data!" -ForegroundColor Green
} else {
    Write-Host "[INFO] Sensor may need a moment. Check: docker compose logs -f sensor" -ForegroundColor Yellow
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Done! Check dashboard: http://localhost:5000" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan

