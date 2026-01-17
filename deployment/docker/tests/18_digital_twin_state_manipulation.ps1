# Test 18: Digital Twin State Manipulation Attack
# Try to corrupt the Digital Twin state

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: Digital Twin State Manipulation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))

# Test 1: Try to set invalid state (negative temperature)
Write-Host "[1/4] Attempting to set invalid state (-200°C)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/demo:sensor-1/features/temp/properties/value" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"value": -200}' -ErrorAction Stop
    Write-Host "[WARN] VULNERABILITY: Invalid state accepted! Status: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 400) {
        Write-Host "[OK] SECURE: Invalid state rejected (400 Bad Request)" -ForegroundColor Green
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

# Test 2: Try to delete critical feature
Write-Host "[2/4] Attempting to delete critical feature..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/demo:sensor-1/features/temp" `
        -Method DELETE -Headers @{"Authorization"="Basic $cred"} -ErrorAction Stop
    Write-Host "[WARN] VULNERABILITY: Critical feature deleted! Status: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 403) {
        Write-Host "[OK] SECURE: Feature deletion blocked (403 Forbidden)" -ForegroundColor Green
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

# Test 3: Try to modify thing policy (policy hijacking)
Write-Host "[3/4] Attempting to change thing policy..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/2/things/demo:sensor-1" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"policyId": "hacked:policy"}' -ErrorAction Stop
    Write-Host "[WARN] VULNERABILITY: Policy hijacking possible! Status: $($response.StatusCode)" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 403 -or $code -eq 404) {
        Write-Host "[OK] SECURE: Policy change blocked" -ForegroundColor Green
    } else {
        Write-Host "[?] Status: $code" -ForegroundColor Yellow
    }
}

# Test 4: Try concurrent conflicting updates (race condition)
Write-Host "[4/4] Testing concurrent conflicting updates..." -ForegroundColor Yellow
$jobs = @()
1..5 | ForEach-Object {
    $jobs += Start-Job -ScriptBlock {
        param($url, $auth, $value)
        try {
            $response = Invoke-WebRequest -Uri "$url/api/2/things/demo:sensor-1/features/temp/properties/value" `
                -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $auth"} `
                -Body "{\"value\": $value}" -ErrorAction Stop
            return $response.StatusCode
        } catch {
            return $_.Exception.Response.StatusCode.value__
        }
    } -ArgumentList $baseUrl, $cred, $_
}

$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

$conflicts = ($results | Group-Object | Where-Object { $_.Count -gt 1 }).Count
if ($conflicts -gt 0) {
    Write-Host "[WARN] Possible race condition: Multiple concurrent updates" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Concurrent updates handled" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Digital Twin State Manipulation Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

