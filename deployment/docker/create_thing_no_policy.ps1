# Alternative Method: Create Thing WITHOUT Policy ID
# Ditto will auto-create a policy with same name as thing ID
# This bypasses the need to create policy first

Write-Host "Creating Thing WITHOUT Policy ID (Auto-creates Policy)..." -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Create thing WITHOUT policyId - Ditto auto-creates policy
$thingBody = @{
    thingId = "demo:sensor-1"
    # NO policyId - let Ditto create it automatically
    definition = "demo:sensor:1.0.0"
    attributes = @{
        name = "Temperature Sensor"
        description = "Digital Twin for IoT security research"
    }
    features = @{
        temp = @{
            properties = @{
                value = 25.0
                unit = "celsius"
                timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                status = "active"
            }
        }
    }
} | ConvertTo-Json -Depth 10

$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"

Write-Host "`nCreating thing (Ditto will auto-create policy 'demo:sensor-1')..." -ForegroundColor Yellow

try {
    $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $thingBody -ErrorAction Stop
    Write-Host "[OK] Thing created successfully!" -ForegroundColor Green
    Write-Host "   Thing ID: $($result.thingId)" -ForegroundColor Cyan
    Write-Host "   Policy ID: $($result.policyId)" -ForegroundColor Cyan
    Write-Host "`n   Ditto automatically created policy: $($result.policyId)" -ForegroundColor Green
    Write-Host "   This policy grants permissions to nginx:ditto!" -ForegroundColor Green
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    $errorMsg = $_.Exception.Message
    
    Write-Host "[FAIL] Error: $errorMsg" -ForegroundColor Red
    Write-Host "   Status Code: $status" -ForegroundColor Red
    
    if ($status -eq 409) {
        Write-Host "`n   Thing already exists! Checking details..." -ForegroundColor Yellow
        try {
            $existing = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
            Write-Host "   Existing thing policy: $($existing.policyId)" -ForegroundColor Cyan
        } catch {
            Write-Host "   Could not check existing thing" -ForegroundColor Yellow
        }
    } elseif ($status -eq 403) {
        Write-Host "`n   [403] Access forbidden - trying via gateway..." -ForegroundColor Yellow
        $gatewayUrl = "http://localhost:8081/api/2/things/demo:sensor-1"
        try {
            $result = Invoke-RestMethod -Uri $gatewayUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $thingBody -ErrorAction Stop
            Write-Host "   [OK] Created via gateway!" -ForegroundColor Green
        } catch {
            Write-Host "   [FAIL] Gateway also failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "`n   SOLUTION: You need to create a default policy first" -ForegroundColor Yellow
            Write-Host "   Or use the UI method with DevOps authentication" -ForegroundColor Yellow
        }
    } elseif ($status -eq 400) {
        Write-Host "`n   [400] Bad Request - checking JSON format..." -ForegroundColor Yellow
        Write-Host "   Trying simpler JSON..." -ForegroundColor Yellow
        
        # Try simpler JSON
        $simpleThing = '{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}'
        try {
            $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $simpleThing -ErrorAction Stop
            Write-Host "   [OK] Created with simpler JSON!" -ForegroundColor Green
        } catch {
            Write-Host "   [FAIL] Still failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Verify
Write-Host "`nVerifying..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    $thing = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
    Write-Host "[OK] Thing verified: $($thing.thingId)" -ForegroundColor Green
    Write-Host "[OK] Policy: $($thing.policyId)" -ForegroundColor Green
    
    if ($thing.features.temp.properties.value) {
        Write-Host "[OK] Temperature: $($thing.features.temp.properties.value)°C" -ForegroundColor Green
    }
} catch {
    Write-Host "[WARN] Could not verify thing" -ForegroundColor Yellow
}

# Check sensor
Write-Host "`nChecking sensor..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

$sensorLogs = docker compose logs sensor --tail 5 2>&1
if ($sensorLogs -match "sent successfully") {
    Write-Host "[OK] Sensor is sending data!" -ForegroundColor Green
} else {
    Write-Host "[INFO] Sensor may need a moment" -ForegroundColor Yellow
    Write-Host "   Check: docker compose logs -f sensor" -ForegroundColor Cyan
}

Write-Host "`nDone!" -ForegroundColor Green

