# Apply RBAC Policies to Digital Twin
# This creates granular role-based access control

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Applying RBAC Policies to Digital Twin" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$adminCred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

# Step 1: Create users in nginx.htpasswd
Write-Host "[1/5] Creating RBAC users..." -ForegroundColor Yellow
Write-Host "  Run these commands to add users:" -ForegroundColor Gray
Write-Host "  docker run --rm httpd:2.4-alpine htpasswd -nb viewer viewer123" -ForegroundColor Gray
Write-Host "  docker run --rm httpd:2.4-alpine htpasswd -nb operator operator123" -ForegroundColor Gray
Write-Host "  docker run --rm httpd:2.4-alpine htpasswd -nb engineer engineer123" -ForegroundColor Gray
Write-Host "  docker run --rm httpd:2.4-alpine htpasswd -nb admin admin123" -ForegroundColor Gray
Write-Host "  Add output to nginx.htpasswd file" -ForegroundColor Gray
Write-Host ""

# Step 2: Create granular RBAC policy
Write-Host "[2/5] Creating granular RBAC policy..." -ForegroundColor Yellow

$rbacPolicy = @{
    policyId = "demo:sensor-policy"
    entries = @{
        viewer = @{
            subjects = @{
                "nginx:viewer" = @{ type = "user" }
            }
            resources = @{
                "thing:/" = @{
                    grant = @("READ")
                    revoke = @()
                }
            }
        }
        operator = @{
            subjects = @{
                "nginx:operator" = @{ type = "user" }
            }
            resources = @{
                "thing:/features/temp/properties" = @{
                    grant = @("READ", "WRITE")
                    revoke = @()
                }
            }
        }
        engineer = @{
            subjects = @{
                "nginx:engineer" = @{ type = "user" }
            }
            resources = @{
                "thing:/" = @{
                    grant = @("READ", "WRITE")
                    revoke = @()
                }
                "thing:/attributes" = @{
                    grant = @("READ", "WRITE")
                    revoke = @()
                }
            }
        }
        admin = @{
            subjects = @{
                "nginx:admin" = @{ type = "user" }
            }
            resources = @{
                "thing:/" = @{
                    grant = @("READ", "WRITE", "ADMINISTRATE")
                    revoke = @()
                }
                "policy:/" = @{
                    grant = @("READ", "WRITE", "ADMINISTRATE")
                    revoke = @()
                }
            }
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/policies/demo:sensor-policy" `
        -Method PUT `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Basic $adminCred"
        } `
        -Body $rbacPolicy `
        -ErrorAction Stop
    
    Write-Host "[OK] RBAC policy created/updated: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[X] Failed to create policy: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Update thing to use the policy
Write-Host "[3/5] Updating thing to use RBAC policy..." -ForegroundColor Yellow

$thingUpdate = @{
    policyId = "demo:sensor-policy"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/demo:sensor-1" `
        -Method PUT `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Basic $adminCred"
        } `
        -Body $thingUpdate `
        -ErrorAction Stop
    
    Write-Host "[OK] Thing updated with RBAC policy: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[X] Failed to update thing: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Verify policy
Write-Host "[4/5] Verifying RBAC policy..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/policies/demo:sensor-policy" `
        -Headers @{"Authorization" = "Basic $adminCred"} `
        -ErrorAction Stop
    
    Write-Host "[OK] Policy verified: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[X] Failed to verify policy: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Test each role
Write-Host "[5/5] Testing RBAC roles..." -ForegroundColor Yellow
Write-Host "  Run tests 9-13 to verify RBAC is working" -ForegroundColor Gray

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RBAC Policy Applied Successfully" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Add users to nginx.htpasswd (see step 1)" -ForegroundColor Gray
Write-Host "  2. Restart nginx: docker compose restart nginx" -ForegroundColor Gray
Write-Host "  3. Run RBAC tests: cd tests && .\09_rbac_viewer_read.ps1" -ForegroundColor Gray
Write-Host ""

