# Quick script to ensure thing exists - run this once
Write-Host "Ensuring thing exists..." -ForegroundColor Cyan

$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"
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

$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

# Check if exists
try {
    $existing = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth} -ErrorAction Stop
    Write-Host "[OK] Thing already exists: $($existing.thingId)" -ForegroundColor Green
    exit 0
} catch {
    Write-Host "Thing doesn't exist, creating..." -ForegroundColor Yellow
}

# Create it
try {
    $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{
        "Content-Type" = "application/json"
        "Authorization" = $auth
    } -Body $thingJson -ErrorAction Stop
    
    Write-Host "[OK] Thing created!" -ForegroundColor Green
    Write-Host "Thing ID: $($result.thingId)" -ForegroundColor Cyan
    Write-Host "Policy ID: $($result.policyId)" -ForegroundColor Cyan
} catch {
    Write-Host "[FAIL] Could not create: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease create via UI:" -ForegroundColor Yellow
    Write-Host "1. Open http://localhost:8080/ui" -ForegroundColor Cyan
    Write-Host "2. Login: ditto / ditto" -ForegroundColor Cyan
    Write-Host "3. Create thing: demo:sensor-1 (leave policy empty)" -ForegroundColor Cyan
}
