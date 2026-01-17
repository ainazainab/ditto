# Simple Thing Creation - Try All Methods
Write-Host "Creating thing using all available methods..." -ForegroundColor Cyan

$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"

# Method 1: Create without policyId (auto-creates policy)
Write-Host "`nMethod 1: Creating without policyId..." -ForegroundColor Yellow
$thingJson1 = '{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}'

try {
    $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $thingJson1 -ErrorAction Stop
    Write-Host "[OK] Thing created! Policy: $($result.policyId)" -ForegroundColor Green
    exit 0
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    Write-Host "[FAIL] Method 1 failed: $status" -ForegroundColor Red
}

# Method 2: Create with policyId in query parameter
Write-Host "`nMethod 2: Creating with policyId in URL..." -ForegroundColor Yellow
$thingJson2 = '{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}'

try {
    $result = Invoke-RestMethod -Uri "$thingUrl?policyId=demo:sensor-policy" -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $thingJson2 -ErrorAction Stop
    Write-Host "[OK] Thing created!" -ForegroundColor Green
    exit 0
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    Write-Host "[FAIL] Method 2 failed: $status" -ForegroundColor Red
}

# Method 3: Via gateway directly
Write-Host "`nMethod 3: Via gateway (port 8081)..." -ForegroundColor Yellow
$gatewayUrl = "http://localhost:8081/api/2/things/demo:sensor-1"

try {
    $result = Invoke-RestMethod -Uri $gatewayUrl -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"=$auth} -Body $thingJson1 -ErrorAction Stop
    Write-Host "[OK] Thing created via gateway!" -ForegroundColor Green
    exit 0
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    Write-Host "[FAIL] Method 3 failed: $status" -ForegroundColor Red
}

Write-Host "`n[FAIL] All API methods failed" -ForegroundColor Red
Write-Host "`nYou MUST create thing using UI:" -ForegroundColor Yellow
Write-Host "1. Open http://localhost:8080" -ForegroundColor Cyan
Write-Host "2. Login: ditto/ditto" -ForegroundColor Cyan
Write-Host "3. Create thing: demo:sensor-1" -ForegroundColor Cyan
Write-Host "4. Policy ID: demo:sensor-policy (use dropdown)" -ForegroundColor Cyan
Write-Host "5. Edit JSON: Paste JSON (NO policyId in JSON!)" -ForegroundColor Cyan

