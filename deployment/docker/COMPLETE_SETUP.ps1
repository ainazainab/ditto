# Complete Setup - Everything from Scratch
Write-Host "Complete System Setup..." -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Step 1: Check services
Write-Host "`n1. Checking services..." -ForegroundColor Yellow
docker compose ps --format "table {{.Name}}\t{{.Status}}" | Select-Object -First 15

# Step 2: Check policy
Write-Host "`n2. Checking policy..." -ForegroundColor Yellow
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
try {
    $policy = Invoke-RestMethod -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" -Headers @{Authorization=$auth} -ErrorAction Stop
    Write-Host "[OK] Policy exists" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Policy does not exist" -ForegroundColor Red
    Write-Host "`n   CREATE POLICY FIRST:" -ForegroundColor Yellow
    Write-Host "   1. Open http://localhost:8080" -ForegroundColor Cyan
    Write-Host "   2. Click 'Authorize' -> DevOps: devops/foobar" -ForegroundColor Cyan
    Write-Host "   3. Create policy: demo:sensor-policy" -ForegroundColor Cyan
    Write-Host "   4. Use JSON from GET_ADMIN_ACCESS.md" -ForegroundColor Cyan
    Write-Host "`n   Press Enter after creating policy..." -ForegroundColor Yellow
    Read-Host
}

# Step 3: Create thing
Write-Host "`n3. Creating thing..." -ForegroundColor Yellow
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"
$thingJson = '{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}'

try {
    $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $thingJson -ErrorAction Stop
    Write-Host "[OK] Thing created!" -ForegroundColor Green
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    if ($status -eq 409) {
        Write-Host "[OK] Thing already exists" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Cannot create via API (Status: $status)" -ForegroundColor Red
        Write-Host "`n   CREATE THING IN UI:" -ForegroundColor Yellow
        Write-Host "   1. Open http://localhost:8080" -ForegroundColor Cyan
        Write-Host "   2. Login: ditto/ditto" -ForegroundColor Cyan
        Write-Host "   3. Create thing: demo:sensor-1" -ForegroundColor Cyan
        Write-Host "   4. Policy ID: demo:sensor-policy (use dropdown)" -ForegroundColor Cyan
        Write-Host "   5. Edit JSON: Paste JSON (NO policyId in JSON!)" -ForegroundColor Cyan
        Write-Host "`n   Press Enter after creating thing..." -ForegroundColor Yellow
        Read-Host
    }
}

# Step 4: Verify
Write-Host "`n4. Verifying..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
try {
    $thing = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
    Write-Host "[OK] Thing verified!" -ForegroundColor Green
    Write-Host "   Temperature: $($thing.features.temp.properties.value)°C" -ForegroundColor Cyan
} catch {
    Write-Host "[FAIL] Thing still doesn't exist" -ForegroundColor Red
    exit 1
}

# Step 5: Check sensor
Write-Host "`n5. Checking sensor..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$sensorLogs = docker compose logs sensor --tail 5 2>&1
if ($sensorLogs -match "sent successfully") {
    Write-Host "[OK] Sensor is sending!" -ForegroundColor Green
} else {
    Write-Host "[INFO] Sensor may need a moment" -ForegroundColor Yellow
}

# Step 6: Check dashboard
Write-Host "`n6. Checking dashboard..." -ForegroundColor Yellow
try {
    $dashboard = Invoke-WebRequest -Uri "http://localhost:5000" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Dashboard is running!" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Dashboard may still be starting" -ForegroundColor Yellow
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "`nDashboard: http://localhost:5000" -ForegroundColor Cyan
Write-Host "Ditto UI: http://localhost:8080" -ForegroundColor Cyan
Write-Host "`nOpen dashboard to see live updates!" -ForegroundColor Yellow

