# Test 14: WebSocket Authentication - VULNERABILITY TEST
# Tests if WebSocket requires authentication (manual test required)
Write-Host "[SKIP] Manual test required" -ForegroundColor Gray
Write-Host "To test: Open browser console and run:" -ForegroundColor Yellow
Write-Host '  const ws = new WebSocket("ws://localhost:8080/ws");' -ForegroundColor Gray
Write-Host '  ws.onopen = () => console.log("[X] VULNERABILITY: Connected without auth!");' -ForegroundColor Gray
