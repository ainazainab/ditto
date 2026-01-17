# Add RBAC Users to nginx.htpasswd
# This enables RBAC tests (9-13)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Adding RBAC Users to nginx.htpasswd" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if htpasswd command is available (from Apache or nginx)
$htpasswdCmd = Get-Command htpasswd -ErrorAction SilentlyContinue

if (-not $htpasswdCmd) {
    Write-Host "[WARN] htpasswd command not found" -ForegroundColor Yellow
    Write-Host "Installing htpasswd via Docker..." -ForegroundColor Yellow
    
    # Use Docker to run htpasswd
    $htpasswdDocker = "docker run --rm -v ${PWD}:/work -w /work httpd:alpine htpasswd"
    
    Write-Host ""
    Write-Host "Adding users (password = username123):" -ForegroundColor Yellow
    
    # Add viewer user
    docker run --rm -v "${PWD}:/work" -w /work httpd:alpine htpasswd -b nginx.htpasswd viewer viewer123 2>&1 | Out-Null
    Write-Host "[OK] Added viewer:viewer123" -ForegroundColor Green
    
    # Add operator user
    docker run --rm -v "${PWD}:/work" -w /work httpd:alpine htpasswd -b nginx.htpasswd operator operator123 2>&1 | Out-Null
    Write-Host "[OK] Added operator:operator123" -ForegroundColor Green
    
    # Add engineer user
    docker run --rm -v "${PWD}:/work" -w /work httpd:alpine htpasswd -b nginx.htpasswd engineer engineer123 2>&1 | Out-Null
    Write-Host "[OK] Added engineer:engineer123" -ForegroundColor Green
    
    # Add admin user (already have ditto, but add admin too)
    docker run --rm -v "${PWD}:/work" -w /work httpd:alpine htpasswd -b nginx.htpasswd admin admin123 2>&1 | Out-Null
    Write-Host "[OK] Added admin:admin123" -ForegroundColor Green
    
} else {
    Write-Host "Using local htpasswd command..." -ForegroundColor Yellow
    htpasswd -b nginx.htpasswd viewer viewer123
    htpasswd -b nginx.htpasswd operator operator123
    htpasswd -b nginx.htpasswd engineer engineer123
    htpasswd -b nginx.htpasswd admin admin123
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RBAC Users Added!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Users added:" -ForegroundColor Yellow
Write-Host "  - viewer:viewer123" -ForegroundColor Gray
Write-Host "  - operator:operator123" -ForegroundColor Gray
Write-Host "  - engineer:engineer123" -ForegroundColor Gray
Write-Host "  - admin:admin123" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart nginx: docker compose restart nginx" -ForegroundColor Gray
Write-Host "  2. Run RBAC tests: .\tests\09_rbac_viewer_read.ps1" -ForegroundColor Gray
Write-Host ""

