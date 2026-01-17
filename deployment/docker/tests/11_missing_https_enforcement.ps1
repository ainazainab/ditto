# Test 11: Missing HTTPS/TLS Enforcement
# Purpose: Verify that system enforces encrypted connections for sensitive operations
# Expected: System should redirect HTTP to HTTPS or reject unencrypted connections
# Vulnerability: If system accepts unencrypted HTTP, data can be intercepted in transit

Write-Host "Test 11: Missing HTTPS/TLS Enforcement" -ForegroundColor Cyan
Write-Host "Testing: Attempting to access sensitive endpoints over unencrypted HTTP" -ForegroundColor Gray
Write-Host "Expected: System should enforce HTTPS/TLS for secure communications" -ForegroundColor Gray
Write-Host "Vulnerability: Unencrypted HTTP allows man-in-the-middle attacks and data interception" -ForegroundColor Gray
Write-Host ""

$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$vulnerable = $false
$issues = @()

# Test 1: Check if API accepts HTTP connections
Write-Host "Testing API endpoint over HTTP..." -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/things" `
        -Headers @{"Authorization"="Basic $cred"} -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        $vulnerable = $true
        $issues += "API accepts unencrypted HTTP connections"
        Write-Host "  Result: API accessible over HTTP (unencrypted)" -ForegroundColor Red
    } elseif ($response.StatusCode -eq 301 -or $response.StatusCode -eq 302) {
        # Redirect to HTTPS - secure
        $location = $response.Headers.Location
        if ($location -match "https://") {
            Write-Host "  Result: HTTP redirects to HTTPS (secure)" -ForegroundColor Green
        } else {
            $vulnerable = $true
            $issues += "HTTP redirects but not to HTTPS"
            Write-Host "  Result: HTTP redirects but not to HTTPS" -ForegroundColor Red
        }
    }
} catch {
    # Connection failed or rejected - could be secure
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 426) {
        Write-Host "  Result: HTTP rejected - upgrade to HTTPS required (secure)" -ForegroundColor Green
    } elseif ($code -eq 403 -or $code -eq 401) {
        # Still accessible over HTTP, just needs auth
        $vulnerable = $true
        $issues += "API accepts HTTP connections (requires authentication but unencrypted)"
        Write-Host "  Result: API accessible over HTTP (unencrypted, requires auth)" -ForegroundColor Red
    } else {
        Write-Host "  Result: Connection failed or rejected" -ForegroundColor Gray
    }
}

# Test 2: Check if WebSocket accepts unencrypted connections
Write-Host "Testing WebSocket endpoint over unencrypted connection..." -ForegroundColor Gray
try {
    $headers = @{
        "Upgrade" = "websocket"
        "Connection" = "Upgrade"
        "Sec-WebSocket-Key" = "dGhlIHNhbXBsZSBub25jZQ=="
        "Sec-WebSocket-Version" = "13"
    }
    
    $wsResponse = Invoke-WebRequest -Uri "http://localhost:8080/ws/2" `
        -Method GET -Headers $headers -ErrorAction Stop
    
    # If WebSocket upgrade succeeds over HTTP, it's vulnerable
    if ($wsResponse.StatusCode -eq 101) {
        $vulnerable = $true
        $issues += "WebSocket accepts unencrypted connections"
        Write-Host "  Result: WebSocket accessible over unencrypted connection" -ForegroundColor Red
    }
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 426) {
        Write-Host "  Result: WebSocket requires secure connection (secure)" -ForegroundColor Green
    } elseif ($code -eq 401 -or $code -eq 403) {
        # Still accessible over unencrypted, just needs auth
        $vulnerable = $true
        $issues += "WebSocket accepts unencrypted connections (requires authentication but unencrypted)"
        Write-Host "  Result: WebSocket accessible over unencrypted connection" -ForegroundColor Red
    } else {
        Write-Host "  Result: WebSocket connection requires secure transport" -ForegroundColor Green
    }
}

# Test 3: Check if dashboard accepts HTTP
Write-Host "Testing dashboard over HTTP..." -ForegroundColor Gray
try {
    $dashboardResponse = Invoke-WebRequest -Uri "http://localhost:5000" -ErrorAction Stop
    if ($dashboardResponse.StatusCode -eq 200) {
        $vulnerable = $true
        $issues += "Dashboard accessible over unencrypted HTTP"
        Write-Host "  Result: Dashboard accessible over HTTP (unencrypted)" -ForegroundColor Red
    }
} catch {
    Write-Host "  Result: Dashboard connection failed" -ForegroundColor Gray
}

Write-Host ""
if ($vulnerable) {
    Write-Host "Result: System accepts unencrypted connections" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  - $issue" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Impact: Sensitive data (credentials, sensor data) can be intercepted" -ForegroundColor Yellow
    Write-Host "        Man-in-the-middle attacks are possible" -ForegroundColor Yellow
    Write-Host "[X] VULNERABILITY: System lacks HTTPS/TLS enforcement - unencrypted connections accepted" -ForegroundColor Red
} else {
    Write-Host "Result: System enforces secure connections" -ForegroundColor Green
    Write-Host "[OK] SECURE: System properly enforces HTTPS/TLS" -ForegroundColor Green
}
