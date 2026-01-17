# Quick create thing - no policy needed
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

Write-Host "Creating thing..." -ForegroundColor Yellow
try {
    # Try without policyId - Ditto will auto-create policy
    $result = Invoke-RestMethod -Uri $thingUrl -Method PUT -Headers @{
        "Content-Type" = "application/json"
        "Authorization" = $auth
    } -Body $thingJson -ErrorAction Stop
    
    Write-Host "[OK] Thing created successfully!" -ForegroundColor Green
    Write-Host "Thing ID: $($result.thingId)" -ForegroundColor Cyan
    Write-Host "Policy ID: $($result.policyId)" -ForegroundColor Cyan
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    Write-Host "[FAIL] Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status: $status" -ForegroundColor Yellow
    
    if ($status -eq 403) {
        Write-Host "`nTrying via gateway port 8081..." -ForegroundColor Yellow
        $gatewayUrl = "http://localhost:8081/api/2/things/demo:sensor-1"
        try {
            $result2 = Invoke-RestMethod -Uri $gatewayUrl -Method PUT -Headers @{
                "Content-Type" = "application/json"
                "Authorization" = $auth
            } -Body $thingJson -ErrorAction Stop
            Write-Host "[OK] Created via gateway!" -ForegroundColor Green
        } catch {
            Write-Host "[FAIL] Gateway also failed" -ForegroundColor Red
            Write-Host "`nPlease create via UI:" -ForegroundColor Yellow
            Write-Host "1. Open http://localhost:8080/ui" -ForegroundColor Cyan
            Write-Host "2. Login: ditto / ditto" -ForegroundColor Cyan
            Write-Host "3. Create thing: demo:sensor-1" -ForegroundColor Cyan
        }
    }
}
