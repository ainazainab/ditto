# Recreate Policy and Thing After System Restart
# This happens when MongoDB is recreated - all data is lost

Write-Host "Recreating Policy and Thing..." -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

Write-Host "`nIMPORTANT: After docker compose down, MongoDB data is lost!" -ForegroundColor Yellow
Write-Host "You need to recreate policy and thing." -ForegroundColor Yellow

Write-Host "`n=== STEP 1: CREATE POLICY ===" -ForegroundColor Cyan
Write-Host "`n1. Open: http://localhost:8080" -ForegroundColor Cyan
Write-Host "2. Click 'Authorize' button (top right)" -ForegroundColor Cyan
Write-Host "3. DevOps authentication section:" -ForegroundColor Cyan
Write-Host "   - Username: devops" -ForegroundColor Gray
Write-Host "   - Password: foobar" -ForegroundColor Gray
Write-Host "   - Click 'Authorize' button" -ForegroundColor Cyan
Write-Host "4. Go to Policies -> Create Policy" -ForegroundColor Cyan
Write-Host "5. Policy ID: demo:sensor-policy" -ForegroundColor Cyan
Write-Host "6. Click 'Edit JSON' tab" -ForegroundColor Cyan
Write-Host "7. Paste this JSON:" -ForegroundColor Cyan
Write-Host @"
{
  "entries": {
    "ditto": {
      "subjects": {
        "nginx:ditto": {
          "type": "user"
        }
      },
      "resources": {
        "thing:/": {
          "grant": ["READ", "WRITE", "ADMINISTRATE"],
          "revoke": []
        },
        "policy:/": {
          "grant": ["READ", "WRITE", "ADMINISTRATE"],
          "revoke": []
        }
      }
    }
  }
}
"@ -ForegroundColor Gray
Write-Host "8. Click 'Save'" -ForegroundColor Cyan

Write-Host "`nPress Enter after creating policy..." -ForegroundColor Yellow
Read-Host

Write-Host "`n=== STEP 2: CREATE THING ===" -ForegroundColor Cyan
Write-Host "`n1. Still in Ditto UI (http://localhost:8080)" -ForegroundColor Cyan
Write-Host "2. Make sure you're logged in as ditto/ditto" -ForegroundColor Cyan
Write-Host "   (Click Authorize -> Main auth: ditto/ditto)" -ForegroundColor Cyan
Write-Host "3. Go to Things -> Create Thing" -ForegroundColor Cyan
Write-Host "4. Thing ID: demo:sensor-1" -ForegroundColor Cyan
Write-Host "5. Policy ID: Select 'demo:sensor-policy' from DROPDOWN" -ForegroundColor Cyan
Write-Host "   (IMPORTANT: Use the dropdown field, NOT in JSON!)" -ForegroundColor Yellow
Write-Host "6. Click 'Edit JSON' tab" -ForegroundColor Cyan
Write-Host "7. Paste this JSON (NO policyId!):" -ForegroundColor Cyan
Write-Host @"
{
  "definition": "demo:sensor:1.0.0",
  "attributes": {
    "name": "Temperature Sensor"
  },
  "features": {
    "temp": {
      "properties": {
        "value": 25.0,
        "unit": "celsius",
        "timestamp": "2024-01-01T00:00:00Z",
        "status": "active"
      }
    }
  }
}
"@ -ForegroundColor Gray
Write-Host "8. Click 'Save'" -ForegroundColor Cyan

Write-Host "`nPress Enter after creating thing..." -ForegroundColor Yellow
Read-Host

# Verify
Write-Host "`n=== VERIFYING ===" -ForegroundColor Cyan
Start-Sleep -Seconds 3

$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

Write-Host "`nChecking policy..." -ForegroundColor Yellow
try {
    $policy = Invoke-RestMethod -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" -Headers @{Authorization=$auth}
    Write-Host "[OK] Policy exists!" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Policy not found - please create it" -ForegroundColor Red
}

Write-Host "`nChecking thing..." -ForegroundColor Yellow
try {
    $thing = Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth}
    Write-Host "[OK] Thing exists!" -ForegroundColor Green
    Write-Host "   Policy: $($thing.policyId)" -ForegroundColor Cyan
    if ($thing.features.temp.properties.value) {
        Write-Host "   Temperature: $($thing.features.temp.properties.value)°C" -ForegroundColor Cyan
    }
} catch {
    Write-Host "[FAIL] Thing not found - please create it" -ForegroundColor Red
}

Write-Host "`nChecking sensor..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$sensorLogs = docker compose logs sensor --tail 5 2>&1
if ($sensorLogs -match "sent successfully") {
    Write-Host "[OK] Sensor is sending data!" -ForegroundColor Green
} else {
    Write-Host "[INFO] Sensor may need a moment" -ForegroundColor Yellow
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "`nDashboard: http://localhost:5000" -ForegroundColor Cyan
Write-Host "Live updates should work now!" -ForegroundColor Green

