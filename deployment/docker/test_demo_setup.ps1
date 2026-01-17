# Quick Setup and Test for Live Demo
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing System for Live Demo" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

# Test 1: Check API is accessible
Write-Host "[1/4] Testing API accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/health" -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] API is accessible" -ForegroundColor Green
} catch {
    Write-Host "[X] API not accessible. Is Docker running?" -ForegroundColor Red
    exit 1
}

# Test 2: Create Policy
Write-Host "[2/4] Creating policy..." -ForegroundColor Yellow
$policy = '{"policyId":"demo:sensor-policy","entries":{"ditto":{"subjects":{"nginx:ditto":{"type":"user"}},"resources":{"thing:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]},"policy:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]}}}}}'
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/policies/demo:sensor-policy" -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} -Body $policy -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Policy created/updated" -ForegroundColor Green
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 204) {
        Write-Host "[OK] Policy already exists" -ForegroundColor Green
    } else {
        Write-Host "[?] Policy status: $code (might need to use gateway directly)" -ForegroundColor Yellow
    }
}

# Test 3: Create Thing
Write-Host "[3/4] Creating thing..." -ForegroundColor Yellow
$thing = '{"thingId":"demo:sensor-1","policyId":"demo:sensor-policy","definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}}'
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/demo:sensor-1" -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} -Body $thing -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Thing created/updated" -ForegroundColor Green
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 204) {
        Write-Host "[OK] Thing already exists" -ForegroundColor Green
    } else {
        Write-Host "[?] Thing status: $code" -ForegroundColor Yellow
    }
}

# Test 4: Verify Thing is accessible
Write-Host "[4/4] Verifying thing is accessible..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/demo:sensor-1" -Headers @{"Authorization"="Basic $cred"} -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Thing is accessible - Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "System is READY for Live Demo!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Open: demo\live_demo.html in your browser" -ForegroundColor Cyan
    Write-Host "2. Click attack buttons to see live results" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "[X] Thing not accessible: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "- Check if services are running: docker compose ps" -ForegroundColor Gray
    Write-Host "- Check nginx logs: docker compose logs nginx" -ForegroundColor Gray
    Write-Host "- Verify credentials in nginx.htpasswd" -ForegroundColor Gray
}




