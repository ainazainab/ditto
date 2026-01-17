# How to Run Security Tests

## Quick Start

1. **Navigate to tests folder**:
   ```powershell
   cd deployment/docker/tests
   ```

2. **Run individual tests**:
   ```powershell
   .\01_unauthorized_write_no_auth.ps1
   .\02_unauthorized_write_wrong_creds.ps1
   .\03_input_validation_extreme_values.ps1
   # ... etc
   ```

3. **Run all Phase 1 tests (1-8)**:
   ```powershell
   1..8 | ForEach-Object { 
       $num = $_.ToString("00")
       Write-Host "`n=== Test $num ===" -ForegroundColor Cyan
       & ".\${num}_*.ps1"
   }
   ```

## Test Files Created

### Phase 1: Baseline Vulnerabilities (Ready to Run)
- `01_unauthorized_write_no_auth.ps1` 
- `02_unauthorized_write_wrong_creds.ps1` 
- `03_input_validation_extreme_values.ps1` 
- `04_input_validation_negative_values.ps1` 
- `05_input_validation_wrong_type.ps1` 
- `06_input_validation_malformed_json.ps1` 
- `07_rate_limiting_dos.ps1` 
- `08_replay_attack.ps1` 

### Phase 2: RBAC Tests (Requires Setup First)
- `09_rbac_viewer_read.ps1` (needs viewer user)
- `10_rbac_viewer_write_attempt.ps1` (needs viewer user)
- `11_rbac_operator_write_telemetry.ps1` (needs operator user)
- `12_rbac_operator_modify_thing.ps1` (needs operator user)
- `13_rbac_privilege_escalation.ps1` (needs viewer user)

### Phase 3: WebSocket & Network
- `14_websocket_auth.ps1` (manual browser test)
- `15_websocket_message_injection.ps1` (manual browser test)
- `16_container_network_isolation.ps1` 
- `17_port_exposure_scan.ps1` 

## Expected Output

Each test shows:
- **[OK]**: Test passed, system is secure
- **[X]**: Vulnerability found
- **[WARN]**: Warning or expected behavior
- **[?]**: Unexpected result

## Example Output

```
========================================
TEST: Unauthorized Write (No Auth)
========================================

[OK] SECURE: Blocked (401 Unauthorized)
```

## Next Steps

1. Run tests 1-8 (Phase 1) - these work immediately
2. Document results in `../test_results.md`
3. Set up RBAC for tests 9-13 (see `../QUICK_TEST_CHECKLIST.md`)
4. Run manual tests 14-15 in browser
5. Run network tests 16-17

## Troubleshooting

**"Connection refused"**:
- Docker Desktop not running
- Ditto not started: `cd .. && docker compose up -d`

**"401 Unauthorized"** (when using valid creds):
- Check username/password: `ditto:ditto`
- Check nginx.htpasswd file

**"404 Not Found"**:
- Thing doesn't exist: Create it first
- Wrong URL: Check `/api/2/things/demo:sensor-1`

