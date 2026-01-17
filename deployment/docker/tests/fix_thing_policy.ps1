# Fix thing policy issue - delete thing if it has bad policy reference
# This is needed when thing references a policy that no longer exists

$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$devopsCred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("devops:foobar"))
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"
$gatewayUrl = "http://localhost:8081/api/2/things/demo:sensor-1"

Write-Host "Fixing thing policy issue..." -ForegroundColor Cyan

# Try to delete thing using DevOps credentials via gateway
try {
    Write-Host "Attempting to delete thing via gateway (DevOps)..." -ForegroundColor Yellow
    $deleteResponse = Invoke-WebRequest -Uri $gatewayUrl -Method DELETE `
        -Headers @{"Authorization"="Basic $devopsCred"} -ErrorAction Stop
    Write-Host "Thing deleted successfully" -ForegroundColor Green
    Start-Sleep -Seconds 2
} catch {
    # Thing might not exist or already deleted
    Write-Host "Thing deletion: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Gray
}

# Now create the thing fresh
Write-Host "Creating thing with auto-policy..." -ForegroundColor Yellow
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
    Write-Host "Thing created successfully!" -ForegroundColor Green
    Write-Host "Thing ID: demo:sensor-1" -ForegroundColor Cyan
} catch {
    Write-Host "Failed to create thing: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
