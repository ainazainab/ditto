# Pre-test setup script - ensures thing exists for demo
# Run this before running tests to ensure the thing exists

Write-Host "=== Pre-Test Setup for Demo ===" -ForegroundColor Cyan
Write-Host ""

$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"

# Check if thing exists
Write-Host "Checking if thing exists..." -ForegroundColor Yellow
try {
    $checkResponse = Invoke-WebRequest -Uri $thingUrl -Headers @{"Authorization"="Basic $cred"} -ErrorAction Stop
    Write-Host "[OK] Thing already exists - ready for tests" -ForegroundColor Green
    exit 0
} catch {
    $checkCode = $_.Exception.Response.StatusCode.value__
    if ($checkCode -eq 404) {
        Write-Host "[INFO] Thing does not exist" -ForegroundColor Yellow
    } else {
        Write-Host "[WARN] Cannot check thing: $checkCode" -ForegroundColor Yellow
    }
}

# Try to create thing
Write-Host "Attempting to create thing..." -ForegroundColor Yellow
$thingJson = @{
    definition = "demo:sensor:1.0.0"
    attributes = @{
        name = "Temperature Sensor"
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

try {
    $createResponse = Invoke-WebRequest -Uri $thingUrl -Method PUT `
        -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body $thingJson -ErrorAction Stop
    Write-Host "[OK] Thing created successfully!" -ForegroundColor Green
    Write-Host "Ready for tests" -ForegroundColor Green
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    Write-Host "[ERROR] Failed to create thing: $status" -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUTION:" -ForegroundColor Yellow
    Write-Host "1. Ensure dashboard and sensor services are running:" -ForegroundColor White
    Write-Host "   docker compose ps dashboard sensor" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Check their logs:" -ForegroundColor White
    Write-Host "   docker compose logs dashboard --tail 20" -ForegroundColor Gray
    Write-Host "   docker compose logs sensor --tail 20" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. The dashboard/sensor should auto-create the thing." -ForegroundColor White
    Write-Host "   If they're failing, restart them:" -ForegroundColor White
    Write-Host "   docker compose restart dashboard sensor" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Wait 30 seconds and check again:" -ForegroundColor White
    Write-Host "   powershell -ExecutionPolicy Bypass -File setup_for_demo.ps1" -ForegroundColor Gray
    exit 1
}
