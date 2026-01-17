# Apply Rate Limiting to Nginx
# This prevents DoS attacks by limiting request rate

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Applying Rate Limiting to Nginx" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Backup current nginx.conf
Write-Host "[1/3] Backing up nginx.conf..." -ForegroundColor Yellow
Copy-Item "nginx.conf" "nginx.conf.backup" -ErrorAction SilentlyContinue
Write-Host "[OK] Backup created: nginx.conf.backup" -ForegroundColor Green

# Read current nginx.conf
$nginxConf = Get-Content "nginx.conf" -Raw

# Add rate limiting configuration
$rateLimitConfig = @'

  # Rate limiting zones
  limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
  limit_req_zone $binary_remote_addr zone=ws_limit:10m rate=5r/s;

'@

# Insert rate limiting config after http { line
if ($nginxConf -notmatch "limit_req_zone") {
    $nginxConf = $nginxConf -replace "(http \{)", "`$1`n$rateLimitConfig"
    Write-Host "[OK] Rate limiting zones added" -ForegroundColor Green
} else {
    Write-Host "[WARN] Rate limiting already configured" -ForegroundColor Yellow
}

# Add rate limiting to /api location
if ($nginxConf -match 'location /api \{' -and $nginxConf -notmatch 'limit_req zone=api_limit') {
    $nginxConf = $nginxConf -replace '(location /api \{[^}]+)', "`$1`n      limit_req zone=api_limit burst=20 nodelay;"
    Write-Host "[OK] Rate limiting added to /api endpoint" -ForegroundColor Green
}

# Add rate limiting to /ws location
if ($nginxConf -match 'location /ws \{' -and $nginxConf -notmatch 'limit_req zone=ws_limit') {
    $nginxConf = $nginxConf -replace '(location /ws \{[^}]+)', "`$1`n      limit_req zone=ws_limit burst=10 nodelay;"
    Write-Host "[OK] Rate limiting added to /ws endpoint" -ForegroundColor Green
}

# Write updated config
Set-Content -Path "nginx.conf" -Value $nginxConf -NoNewline
Write-Host "[2/3] nginx.conf updated with rate limiting" -ForegroundColor Yellow

# Restart nginx
Write-Host "[3/3] Restarting nginx..." -ForegroundColor Yellow
Write-Host "  Run: docker compose restart nginx" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Rate Limiting Configuration Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  - API: 10 requests/second (burst: 20)" -ForegroundColor Gray
Write-Host "  - WebSocket: 5 requests/second (burst: 10)" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Restart nginx: docker compose restart nginx" -ForegroundColor Gray
Write-Host "  2. Re-test rate limiting: .\tests\07_rate_limiting_dos.ps1" -ForegroundColor Gray
Write-Host ""

