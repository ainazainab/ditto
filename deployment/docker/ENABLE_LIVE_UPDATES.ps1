# Enable Live Updates - Create Policy and Thing
# This script will guide you through creating the policy and thing via UI

Write-Host "=== ENABLING LIVE UPDATES ===" -ForegroundColor Cyan
Write-Host "`nThis will create the policy and thing needed for live updates." -ForegroundColor Yellow
Write-Host "`nSince API creation requires DevOps authentication which is complex," -ForegroundColor Yellow
Write-Host "we'll use the Ditto UI which is the most reliable method." -ForegroundColor Yellow

Write-Host "`n=== STEP 1: CREATE POLICY ===" -ForegroundColor Cyan
Write-Host "`n1. Open: http://localhost:8080" -ForegroundColor White
Write-Host "2. Click 'Authorize' button (top right)" -ForegroundColor White
Write-Host "3. In DevOps section:" -ForegroundColor White
Write-Host "   - Username: devops" -ForegroundColor Gray
Write-Host "   - Password: foobar" -ForegroundColor Gray
Write-Host "   - Click 'Authorize' button" -ForegroundColor White
Write-Host "4. Click 'Policies' in sidebar" -ForegroundColor White
Write-Host "5. Click 'Create Policy'" -ForegroundColor White
Write-Host "6. Policy ID: demo:sensor-policy" -ForegroundColor White
Write-Host "7. Click 'Edit JSON' tab" -ForegroundColor White
Write-Host "8. Delete all, paste this JSON:" -ForegroundColor White
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
"@ -ForegroundColor Green
Write-Host "9. Click 'Save'" -ForegroundColor White

Write-Host "`nPress Enter after creating the policy..." -ForegroundColor Yellow
Read-Host

Write-Host "`n=== STEP 2: CREATE THING ===" -ForegroundColor Cyan
Write-Host "`n1. Still in http://localhost:8080" -ForegroundColor White
Write-Host "2. Click 'Authorize' again" -ForegroundColor White
Write-Host "3. In Main authentication:" -ForegroundColor White
Write-Host "   - Username: ditto" -ForegroundColor Gray
Write-Host "   - Password: ditto" -ForegroundColor Gray
Write-Host "   - Click 'Authorize' button" -ForegroundColor White
Write-Host "4. Click 'Things' in sidebar" -ForegroundColor White
Write-Host "5. Click 'Create Thing'" -ForegroundColor White
Write-Host "6. Thing ID: demo:sensor-1" -ForegroundColor White
Write-Host "7. Policy ID: demo:sensor-policy (use DROPDOWN, not JSON!)" -ForegroundColor White
Write-Host "8. Click 'Edit JSON' tab" -ForegroundColor White
Write-Host "9. Delete all, paste this JSON (NO policyId!):" -ForegroundColor White
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
"@ -ForegroundColor Green
Write-Host "10. Click 'Save'" -ForegroundColor White

Write-Host "`nPress Enter after creating the thing..." -ForegroundColor Yellow
Read-Host

Write-Host "`n=== VERIFYING ===" -ForegroundColor Cyan
Start-Sleep -Seconds 2

$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

# Check policy
Write-Host "`nChecking policy..." -ForegroundColor Yellow
try {
    $policy = Invoke-RestMethod -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" -Headers @{Authorization=$auth} -ErrorAction Stop
    Write-Host "[OK] Policy exists" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Policy not found" -ForegroundColor Red
}

# Check thing
Write-Host "`nChecking thing..." -ForegroundColor Yellow
try {
    $thing = Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth} -ErrorAction Stop
    Write-Host "[OK] Thing exists!" -ForegroundColor Green
    Write-Host "   Policy ID: $($thing.policyId)" -ForegroundColor Cyan
    if ($thing.features.temp.properties.value) {
        Write-Host "   Temperature: $($thing.features.temp.properties.value)°C" -ForegroundColor Cyan
    }
} catch {
    Write-Host "[FAIL] Thing not found" -ForegroundColor Red
}

# Check sensor
Write-Host "`nChecking sensor..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
$logs = docker compose logs sensor --tail 5 2>&1
if ($logs -match "sent successfully") {
    Write-Host "[OK] Sensor is sending data!" -ForegroundColor Green
} else {
    Write-Host "[INFO] Sensor may need a moment to start" -ForegroundColor Yellow
}

Write-Host "`n=== DONE ===" -ForegroundColor Cyan
Write-Host "`n✅ Live updates should now work!" -ForegroundColor Green
Write-Host "   Dashboard: http://localhost:5000" -ForegroundColor Cyan
Write-Host "   Wait 5-10 seconds for sensor to start sending updates..." -ForegroundColor Yellow

