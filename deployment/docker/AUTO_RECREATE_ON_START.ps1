# Auto-Recreate Policy and Thing on Startup
# Run this after docker compose up to ensure live updates work

Write-Host "=== AUTO-RECREATING POLICY AND THING ===" -ForegroundColor Cyan

# Wait for services to be ready
Write-Host "`nWaiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

$devopsAuth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("devops:foobar"))
$regularAuth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

# Step 1: Create Policy
Write-Host "`n[1/2] Creating policy..." -ForegroundColor Yellow
$policyJson = '{"entries":{"ditto":{"subjects":{"nginx:ditto":{"type":"user"}},"resources":{"thing:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]},"policy:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]}}}}}'

try {
    $result = Invoke-RestMethod -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$devopsAuth} -Body $policyJson -ErrorAction Stop
    Write-Host "[OK] Policy created" -ForegroundColor Green
    $policyOk = $true
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 409) {
        Write-Host "[OK] Policy already exists" -ForegroundColor Green
        $policyOk = $true
    } else {
        Write-Host "[FAIL] Policy creation failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   You may need to create it via UI: http://localhost:8080" -ForegroundColor Yellow
        $policyOk = $false
    }
}

# Step 2: Create Thing
if ($policyOk) {
    Write-Host "`n[2/2] Creating thing..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    $thingJson = '{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}'
    
    try {
        $result = Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1?policyId=demo:sensor-policy" -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$regularAuth} -Body $thingJson -ErrorAction Stop
        Write-Host "[OK] Thing created" -ForegroundColor Green
        Write-Host "`n✅ Live updates should work now!" -ForegroundColor Green
        Write-Host "   Dashboard: http://localhost:5000" -ForegroundColor Cyan
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 409) {
            Write-Host "[OK] Thing already exists" -ForegroundColor Green
            Write-Host "`n✅ Live updates should work now!" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] Thing creation failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "   You may need to create it via UI: http://localhost:8080" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== DONE ===" -ForegroundColor Cyan

