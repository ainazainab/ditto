# Quick Fix for Live Updates - Recreate Everything
Write-Host "=== FIXING LIVE UPDATES NOW ===" -ForegroundColor Cyan

Write-Host "`nThe problem: MongoDB data was lost (no persistent storage)" -ForegroundColor Yellow
Write-Host "Solution: Recreate policy and thing" -ForegroundColor Yellow

Write-Host "`n=== OPTION 1: Quick UI Method (2 minutes) ===" -ForegroundColor Green
Write-Host "`n1. Open: http://localhost:8080" -ForegroundColor White
Write-Host "2. Click 'Authorize' → DevOps: devops/foobar → Authorize" -ForegroundColor White
Write-Host "3. Create Policy: demo:sensor-policy" -ForegroundColor White
Write-Host "   JSON:" -ForegroundColor Gray
Write-Host '{"entries":{"ditto":{"subjects":{"nginx:ditto":{"type":"user"}},"resources":{"thing:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]},"policy:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]}}}}}' -ForegroundColor Cyan
Write-Host "4. Click 'Authorize' → Main: ditto/ditto → Authorize" -ForegroundColor White
Write-Host "5. Create Thing: demo:sensor-1" -ForegroundColor White
Write-Host "   Policy ID: demo:sensor-policy (use dropdown!)" -ForegroundColor White
Write-Host "   JSON (NO policyId!):" -ForegroundColor Gray
Write-Host '{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}' -ForegroundColor Cyan

Write-Host "`nPress Enter after creating both..." -ForegroundColor Yellow
Read-Host

Write-Host "`n=== VERIFYING ===" -ForegroundColor Cyan
Start-Sleep -Seconds 2

$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

try {
    $thing = Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth} -ErrorAction Stop
    Write-Host "[OK] Thing exists!" -ForegroundColor Green
    Write-Host "   Policy: $($thing.policyId)" -ForegroundColor Cyan
    Write-Host "   Temp: $($thing.features.temp.properties.value)°C" -ForegroundColor Cyan
    
    Write-Host "`nChecking sensor..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    $logs = docker compose logs sensor --tail 5 2>&1
    if ($logs -match "sent successfully") {
        Write-Host "[OK] Sensor sending!" -ForegroundColor Green
        Write-Host "`n✅✅✅ LIVE UPDATES ARE WORKING! ✅✅✅" -ForegroundColor Green
        Write-Host "   Dashboard: http://localhost:5000" -ForegroundColor Cyan
    } else {
        Write-Host "[INFO] Sensor may need a moment" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[FAIL] Thing still missing - please create it via UI" -ForegroundColor Red
    Write-Host "   See: STEP_BY_STEP_CREATE.md" -ForegroundColor Yellow
}

Write-Host "`n=== PERMANENT FIX APPLIED ===" -ForegroundColor Green
Write-Host "`nI've added MongoDB persistent volume to docker-compose.yml" -ForegroundColor Cyan
Write-Host "This will prevent data loss on restart!" -ForegroundColor Cyan
Write-Host "`nTo apply: docker compose down && docker compose up -d" -ForegroundColor Yellow

