# PowerShell script to create Digital Twin in Ditto
# This script creates a policy and thing for our temperature sensor

Write-Host "Creating Digital Twin for Temperature Sensor..." -ForegroundColor Green

# Base URL for Ditto API
$baseUrl = "http://localhost:8080"

# Function to make API calls
function Invoke-DittoAPI {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Body = $null,
        [string]$ContentType = "application/json"
    )
    
    $headers = @{
        "Content-Type" = $ContentType
    }
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body $Body -Headers $headers
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers
        }
        return $response
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Step 1: Create Policy
Write-Host "Step 1: Creating policy..." -ForegroundColor Yellow
$policyData = @{
    "policyId" = "demo:sensor-policy"
    "entries" = @{
        "viewer" = @{
            "subjects" = @{
                "demo:viewer" = @{
                    "type" = "user"
                }
            }
            "resources" = @{
                "thing:/" = @{
                    "grant" = @("READ")
                    "revoke" = @()
                }
            }
        }
        "operator" = @{
            "subjects" = @{
                "demo:operator" = @{
                    "type" = "user"
                }
            }
            "resources" = @{
                "thing:/" = @{
                    "grant" = @("READ", "WRITE")
                    "revoke" = @()
                }
            }
        }
        "admin" = @{
            "subjects" = @{
                "demo:admin" = @{
                    "type" = "user"
                }
            }
            "resources" = @{
                "thing:/" = @{
                    "grant" = @("READ", "WRITE", "ADMINISTRATE")
                    "revoke" = @()
                }
            }
        }
    }
} | ConvertTo-Json -Depth 10

$policyUrl = "$baseUrl/api/2/policies/demo:sensor-policy"
Write-Host "Creating policy at: $policyUrl"
$policyResult = Invoke-DittoAPI -Method "PUT" -Url $policyUrl -Body $policyData

if ($policyResult) {
    Write-Host "Policy created successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to create policy. This might be due to authentication issues." -ForegroundColor Red
    Write-Host "Let's try to create the thing directly..." -ForegroundColor Yellow
}

# Step 2: Create Thing
Write-Host "Step 2: Creating thing..." -ForegroundColor Yellow
$thingData = @{
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
} | ConvertTo-Json -Depth 10

$thingUrl = "$baseUrl/api/2/things/demo:sensor-1"
Write-Host "Creating thing at: $thingUrl"
$thingResult = Invoke-DittoAPI -Method "PUT" -Url $thingUrl -Body $thingData

if ($thingResult) {
    Write-Host "Thing created successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to create thing. This might be due to authentication issues." -ForegroundColor Red
}

# Step 3: Verify creation
Write-Host "Step 3: Verifying creation..." -ForegroundColor Yellow
$verifyUrl = "$baseUrl/api/2/things/demo:sensor-1"
$verifyResult = Invoke-DittoAPI -Method "GET" -Url $verifyUrl

if ($verifyResult) {
    Write-Host "Thing verification successful!" -ForegroundColor Green
    Write-Host "Thing ID: $($verifyResult.thingId)"
    Write-Host "Policy ID: $($verifyResult.policyId)"
    Write-Host "Features: $($verifyResult.features.PSObject.Properties.Name -join ', ')"
} else {
    Write-Host "Failed to verify thing creation." -ForegroundColor Red
}

Write-Host "Digital Twin creation process completed!" -ForegroundColor Green
