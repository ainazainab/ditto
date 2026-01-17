# Test 13: RBAC Privilege Escalation (Unauthorized Policy Modification)
# Tests if unauthorized user can modify policies (should be blocked)
try {
    # Try to modify policy with unauthorized credentials
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("unauthorized:user"))
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/2/policies/demo:sensor-1" `
        -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Basic $cred"} `
        -Body '{"entries": {}}' -ErrorAction Stop
    Write-Host "[X] VULNERABILITY" -ForegroundColor Red
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401 -or $code -eq 403) {
        Write-Host "[OK] SECURE" -ForegroundColor Green
    } else {
        Write-Host "[?] UNKNOWN" -ForegroundColor Yellow
    }
}
