# Digital Twin Setup Script for Temperature Sensor
Write-Host "🌡️  Digital Twin Setup for Temperature Sensor" -ForegroundColor Green
Write-Host "=" * 60

# Check if Docker is running
Write-Host "Checking Docker status..." -ForegroundColor Yellow
docker ps | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker is running" -ForegroundColor Green
} else {
    Write-Host "✗ Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Check if Ditto is accessible
Write-Host "Checking Ditto connectivity..." -ForegroundColor Yellow
$healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET -ErrorAction SilentlyContinue
if ($healthResponse -and $healthResponse.status -eq "UP") {
    Write-Host "✓ Ditto is running and accessible" -ForegroundColor Green
} else {
    Write-Host "✗ Cannot connect to Ditto at localhost:8080" -ForegroundColor Red
    Write-Host "Please ensure Ditto is running with: docker compose up -d" -ForegroundColor Yellow
    exit 1
}

# Create the Digital Twin structure
Write-Host "Creating Digital Twin structure..." -ForegroundColor Yellow

$thingStructure = @{
    "thingId" = "demo:sensor-1"
    "policyId" = "demo:sensor-policy"
    "definition" = "demo:sensor:1.0.0"
    "attributes" = @{
        "name" = "Temperature Sensor"
        "description" = "A digital twin of a temperature sensor for IoT research"
        "location" = "Lab Environment"
        "manufacturer" = "Research Lab"
        "model" = "TempSensor-v1.0"
    }
    "features" = @{
        "temp" = @{
            "definition" = @("demo:temperature:1.0.0")
            "properties" = @{
                "value" = 25.0
                "unit" = "celsius"
                "timestamp" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
                "status" = "active"
            }
        }
    }
}

# Save the structure to a file
$thingStructure | ConvertTo-Json -Depth 10 | Out-File -FilePath "thing_structure.json" -Encoding UTF8
Write-Host "✓ Thing structure saved to thing_structure.json" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 Digital Twin setup completed!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check: thing_structure.json" -ForegroundColor Cyan
Write-Host "2. Run: python sensor_service.py" -ForegroundColor Cyan