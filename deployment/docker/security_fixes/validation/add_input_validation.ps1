# Add Input Validation to Digital Twin
# This adds validation rules to prevent invalid data

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Adding Input Validation to Digital Twin" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$adminCred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

# Update thing with validation constraints
Write-Host "[1/3] Adding validation constraints to thing..." -ForegroundColor Yellow

# Add validation metadata to thing
$thingWithValidation = @{
    policyId = "demo:sensor-policy"
    attributes = @{
        validation = @{
            temp = @{
                min = 0
                max = 100
                unit = "celsius"
            }
        }
    }
    features = @{
        temp = @{
            properties = @{
                value = 25
                unit = "celsius"
                timestamp = (Get-Date -Format "o")
            }
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/demo:sensor-1" `
        -Method PUT `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Basic $adminCred"
        } `
        -Body $thingWithValidation `
        -ErrorAction Stop
    
    Write-Host "[OK] Validation constraints added: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[X] Failed to add validation: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Note: Ditto doesn't have built-in validation, so we need a proxy/validation layer
Write-Host "[2/3] Creating validation proxy service..." -ForegroundColor Yellow
Write-Host "  Note: Ditto doesn't validate data ranges by default" -ForegroundColor Gray
Write-Host "  We need to add a validation layer (see validation_proxy.py)" -ForegroundColor Gray
Write-Host ""

# Create validation proxy Python script
$validationProxy = @'
#!/usr/bin/env python3
"""
Validation Proxy for Digital Twin
Validates sensor data before sending to Ditto
"""

from flask import Flask, request, jsonify
import requests
from datetime import datetime
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

DITTO_API = "http://nginx:80"
DITTO_AUTH = ("ditto", "ditto")

def validate_temperature(value):
    """Validate temperature is in reasonable range"""
    if not isinstance(value, (int, float)):
        return False, "Temperature must be a number"
    if value < -50 or value > 150:
        return False, f"Temperature {value}°C out of range (-50 to 150°C)"
    return True, None

@app.route('/api/2/things/<thing_id>/features/<feature>/properties/<prop>', methods=['PUT'])
def validate_and_forward(thing_id, feature, prop):
    """Validate data before forwarding to Ditto"""
    try:
        data = request.get_json()
        
        # Validate temperature
        if prop == "value" and feature == "temp":
            value = data.get("value")
            valid, error = validate_temperature(value)
            if not valid:
                return jsonify({"error": error}), 400
        
        # Forward to Ditto
        response = requests.put(
            f"{DITTO_API}/api/2/things/{thing_id}/features/{feature}/properties/{prop}",
            json=data,
            auth=DITTO_AUTH
        )
        return response.content, response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)
'@

$validationProxy | Out-File -FilePath "validation_proxy.py" -Encoding UTF8
Write-Host "[OK] Validation proxy script created: validation_proxy.py" -ForegroundColor Green

Write-Host "[3/3] Validation setup complete" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Input Validation Added" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Deploy validation proxy (add to docker-compose.yml)" -ForegroundColor Gray
Write-Host "  2. Update sensor to use validation proxy" -ForegroundColor Gray
Write-Host "  3. Re-test input validation (tests 3-6)" -ForegroundColor Gray
Write-Host ""

