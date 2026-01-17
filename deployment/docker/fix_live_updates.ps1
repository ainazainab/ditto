# Fix Live Updates - Create Policy and Thing Automatically
Write-Host "=== FIXING LIVE UPDATES ===" -ForegroundColor Cyan
Write-Host "Creating policy and thing programmatically..." -ForegroundColor Yellow

# Policy JSON
$policyJson = '{"entries":{"ditto":{"subjects":{"nginx:ditto":{"type":"user"}},"resources":{"thing:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]},"policy:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]}}}}}'

# Thing JSON (NO policyId!)
$thingJson = '{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}'

# Credentials
$devopsAuth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("devops:foobar"))
$regularAuth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

$policyCreated = $false
$thingCreated = $false

# ============================================
# METHOD 1: Create Policy via /devops endpoint
# ============================================
Write-Host "`n[1/6] Trying /devops endpoint for policy..." -ForegroundColor Yellow
$devopsUrl = "http://localhost:8080/devops/policies/demo:sensor-policy"
try {
    $result = Invoke-RestMethod -Uri $devopsUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$devopsAuth} -Body $policyJson -ErrorAction Stop
    Write-Host "[OK] Policy created via /devops!" -ForegroundColor Green
    $policyCreated = $true
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    if ($status -eq 409) {
        Write-Host "[OK] Policy already exists" -ForegroundColor Green
        $policyCreated = $true
    } else {
        Write-Host "[SKIP] /devops failed: $status" -ForegroundColor Gray
    }
}

# ============================================
# METHOD 2: Create Policy via Gateway (port 8081)
# ============================================
if (-not $policyCreated) {
    Write-Host "`n[2/6] Trying gateway (8081) for policy..." -ForegroundColor Yellow
    $gatewayPolicyUrl = "http://localhost:8081/api/2/policies/demo:sensor-policy"
    try {
        $result = Invoke-RestMethod -Uri $gatewayPolicyUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$devopsAuth} -Body $policyJson -ErrorAction Stop
        Write-Host "[OK] Policy created via gateway!" -ForegroundColor Green
        $policyCreated = $true
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        if ($status -eq 409) {
            Write-Host "[OK] Policy already exists" -ForegroundColor Green
            $policyCreated = $true
        } else {
            Write-Host "[SKIP] Gateway failed: $status" -ForegroundColor Gray
        }
    }
}

# ============================================
# METHOD 3: Create Policy via Nginx /api (with devops user)
# ============================================
if (-not $policyCreated) {
    Write-Host "`n[3/6] Trying /api with devops credentials..." -ForegroundColor Yellow
    $apiPolicyUrl = "http://localhost:8080/api/2/policies/demo:sensor-policy"
    try {
        $result = Invoke-RestMethod -Uri $apiPolicyUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$devopsAuth} -Body $policyJson -ErrorAction Stop
        Write-Host "[OK] Policy created via /api!" -ForegroundColor Green
        $policyCreated = $true
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        if ($status -eq 409) {
            Write-Host "[OK] Policy already exists" -ForegroundColor Green
            $policyCreated = $true
        } else {
            Write-Host "[SKIP] /api failed: $status" -ForegroundColor Gray
        }
    }
}

# Wait a moment for policy to be available
if ($policyCreated) {
    Write-Host "`nWaiting 2 seconds for policy to propagate..." -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

# ============================================
# METHOD 4: Create Thing via /api (regular auth)
# ============================================
Write-Host "`n[4/6] Creating thing via /api..." -ForegroundColor Yellow
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"
try {
    $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$regularAuth} -Body $thingJson -ErrorAction Stop
    Write-Host "[OK] Thing created!" -ForegroundColor Green
    $thingCreated = $true
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    if ($status -eq 409) {
        Write-Host "[OK] Thing already exists" -ForegroundColor Green
        $thingCreated = $true
    } else {
        Write-Host "[SKIP] /api failed: $status" -ForegroundColor Gray
    }
}

# ============================================
# METHOD 5: Create Thing via Gateway
# ============================================
if (-not $thingCreated) {
    Write-Host "`n[5/6] Creating thing via gateway..." -ForegroundColor Yellow
    $gatewayThingUrl = "http://localhost:8081/api/2/things/demo:sensor-1"
    try {
        $result = Invoke-RestMethod -Uri $gatewayThingUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$regularAuth} -Body $thingJson -ErrorAction Stop
        Write-Host "[OK] Thing created via gateway!" -ForegroundColor Green
        $thingCreated = $true
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        if ($status -eq 409) {
            Write-Host "[OK] Thing already exists" -ForegroundColor Green
            $thingCreated = $true
        } else {
            Write-Host "[SKIP] Gateway failed: $status" -ForegroundColor Gray
        }
    }
}

# ============================================
# METHOD 6: Create Thing with policyId in URL
# ============================================
if (-not $thingCreated) {
    Write-Host "`n[6/6] Creating thing with policyId in URL..." -ForegroundColor Yellow
    $thingUrlWithPolicy = "http://localhost:8080/api/2/things/demo:sensor-1?policyId=demo:sensor-policy"
    try {
        $result = Invoke-RestMethod -Uri $thingUrlWithPolicy -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$regularAuth} -Body $thingJson -ErrorAction Stop
        Write-Host "[OK] Thing created with policyId!" -ForegroundColor Green
        $thingCreated = $true
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        if ($status -eq 409) {
            Write-Host "[OK] Thing already exists" -ForegroundColor Green
            $thingCreated = $true
        } else {
            Write-Host "[SKIP] URL policyId failed: $status" -ForegroundColor Gray
        }
    }
}

# ============================================
# VERIFICATION
# ============================================
Write-Host "`n=== VERIFICATION ===" -ForegroundColor Cyan
Start-Sleep -Seconds 2

# Check Policy
Write-Host "`nChecking policy..." -ForegroundColor Yellow
try {
    $policy = Invoke-RestMethod -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" -Headers @{Authorization=$regularAuth} -ErrorAction Stop
    Write-Host "[OK] Policy exists and is accessible" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Policy check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Check Thing
Write-Host "`nChecking thing..." -ForegroundColor Yellow
try {
    $thing = Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$regularAuth} -ErrorAction Stop
    Write-Host "[OK] Thing exists!" -ForegroundColor Green
    Write-Host "   Thing ID: $($thing.thingId)" -ForegroundColor Cyan
    Write-Host "   Policy ID: $($thing.policyId)" -ForegroundColor Cyan
    if ($thing.features.temp.properties.value) {
        Write-Host "   Temperature: $($thing.features.temp.properties.value)°C" -ForegroundColor Cyan
    }
} catch {
    Write-Host "[FAIL] Thing check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Check Sensor
Write-Host "`nChecking sensor..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
$sensorLogs = docker compose logs sensor --tail 5 2>&1
if ($sensorLogs -match "sent successfully") {
    Write-Host "[OK] Sensor is sending data!" -ForegroundColor Green
} elseif ($sensorLogs -match "403|forbidden|insufficient") {
    Write-Host "[WARN] Sensor has permission issues" -ForegroundColor Yellow
    Write-Host "   This should fix itself once thing is created" -ForegroundColor Gray
} else {
    Write-Host "[INFO] Sensor logs:" -ForegroundColor Gray
    $sensorLogs | Select-Object -Last 2
}

# Final Status
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
if ($policyCreated -and $thingCreated) {
    Write-Host "[SUCCESS] Policy and Thing created!" -ForegroundColor Green
    Write-Host "`n✅ Live updates should work now!" -ForegroundColor Green
    Write-Host "   Dashboard: http://localhost:5000" -ForegroundColor Cyan
    Write-Host "   Wait 5-10 seconds for sensor to start sending..." -ForegroundColor Yellow
} else {
    Write-Host "[PARTIAL] Some components may need manual creation" -ForegroundColor Yellow
    if (-not $policyCreated) {
        Write-Host "   ❌ Policy needs manual creation via UI" -ForegroundColor Red
    }
    if (-not $thingCreated) {
        Write-Host "   ❌ Thing needs manual creation via UI" -ForegroundColor Red
    }
    Write-Host "`n   See: STEP_BY_STEP_CREATE.md" -ForegroundColor Yellow
}

