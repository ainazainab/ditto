# Helper script to ensure thing exists before tests
# This is called by tests that need the thing to exist

$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"

# Check if thing exists
try {
    $checkResponse = Invoke-WebRequest -Uri $thingUrl -Headers @{"Authorization"="Basic $cred"} -ErrorAction Stop
    return $true
} catch {
    $checkCode = $_.Exception.Response.StatusCode.value__
    if ($checkCode -eq 404) {
        # Thing doesn't exist - try to create it
        Write-Host "Creating thing..." -ForegroundColor Yellow
        
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
        
        # Try via nginx first
        try {
            $createResponse = Invoke-WebRequest -Uri $thingUrl -Method PUT `
                -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
                -Body $thingJson -ErrorAction Stop
            Write-Host "Thing created via nginx" -ForegroundColor Green
            Start-Sleep -Seconds 2
            return $true
        } catch {
            # If nginx fails, try gateway directly (bypass nginx auth)
            Write-Host "Nginx creation failed, trying gateway directly..." -ForegroundColor Yellow
            $gatewayUrl = "http://localhost:8081/api/2/things/demo:sensor-1"
            try {
                $gatewayResponse = Invoke-WebRequest -Uri $gatewayUrl -Method PUT `
                    -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
                    -Body $thingJson -ErrorAction Stop
                Write-Host "Thing created via gateway" -ForegroundColor Green
                Start-Sleep -Seconds 2
                return $true
            } catch {
                Write-Host "Failed to create thing via gateway: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
                return $false
            }
        }
    } else {
        Write-Host "Cannot access thing: $checkCode" -ForegroundColor Red
        return $false
    }
}
