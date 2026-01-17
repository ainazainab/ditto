# Test 15: WebSocket Message Injection
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST: WebSocket Message Injection" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NOTE: This test requires manual browser testing" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open dashboard at http://localhost:5000" -ForegroundColor Yellow
Write-Host "2. Open browser console (F12)" -ForegroundColor Yellow
Write-Host "3. Find the WebSocket connection in Network tab" -ForegroundColor Yellow
Write-Host "4. Try sending malicious messages:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   - Oversized: ws.send('x'.repeat(1000000));" -ForegroundColor Gray
Write-Host "   - Malformed: ws.send('{"invalid": json}');" -ForegroundColor Gray
Write-Host "   - Script: ws.send('{\"msg\": \"<script>alert(1)</script>\"}');" -ForegroundColor Gray
Write-Host ""
Write-Host "Expected: Dashboard should handle gracefully (not crash)" -ForegroundColor Green
Write-Host "If crashes: VULNERABILITY - Message injection possible" -ForegroundColor Red

