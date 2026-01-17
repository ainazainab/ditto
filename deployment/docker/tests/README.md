# Security Test Suite

This folder contains individual test scripts for security analysis of the Digital Twin system.

## Quick Start

1. **Ensure Docker is running**:
   ```powershell
   docker ps
   ```

2. **Ensure Ditto is running**:
   ```powershell
   curl http://localhost:8080/health
   ```

3. **Run tests one by one**:
   ```powershell
   cd deployment/docker/tests
   .\01_unauthorized_write_no_auth.ps1
   .\02_unauthorized_write_wrong_creds.ps1
   # ... etc
   ```

## Test List

See `../TEST_LIST.txt` for complete list of all tests.

## Test Files

### Phase 1: Baseline Vulnerabilities (Tests 1-8)
- `01_unauthorized_write_no_auth.ps1` - Test write without authentication
- `02_unauthorized_write_wrong_creds.ps1` - Test write with wrong credentials
- `03_input_validation_extreme_values.ps1` - Test extreme values (1000°C)
- `04_input_validation_negative_values.ps1` - Test negative values (-200°C)
- `05_input_validation_wrong_type.ps1` - Test wrong data type (string)
- `06_input_validation_malformed_json.ps1` - Test malformed JSON
- `07_rate_limiting_dos.ps1` - Test DoS (50 rapid requests)
- `08_replay_attack.ps1` - Test replay attack (resend old messages)

### Phase 2: RBAC Testing (Tests 9-13)
**Note**: Requires RBAC setup first (see `../QUICK_TEST_CHECKLIST.md`)

- `09_rbac_viewer_read.ps1` - Viewer can read
- `10_rbac_viewer_write_attempt.ps1` - Viewer cannot write
- `11_rbac_operator_write_telemetry.ps1` - Operator can write telemetry
- `12_rbac_operator_modify_thing.ps1` - Operator cannot modify thing
- `13_rbac_privilege_escalation.ps1` - Viewer cannot escalate to admin

### Phase 3: WebSocket & Network (Tests 14-17)
- `14_websocket_auth.ps1` - WebSocket authentication (manual browser test)
- `15_websocket_message_injection.ps1` - WebSocket message injection (manual)
- `16_container_network_isolation.ps1` - Container network access
- `17_port_exposure_scan.ps1` - Port exposure scan

## Running All Tests

To run all automated tests (1-8, 16-17):

```powershell
Get-ChildItem *.ps1 | Where-Object { $_.Name -notmatch "websocket|rbac" } | ForEach-Object { Write-Host "`n=== $($_.Name) ===" -ForegroundColor Cyan; & $_.FullName }
```

## Expected Results

- **Green (✓)**: Test passed, system is secure
- **Red (✗)**: Vulnerability found
- **Yellow (⚠)**: Warning or expected behavior
- **Gray (?)**: Unexpected result, needs investigation

## Documentation

After running tests, document results in:
- `../test_results.md` (create this file)
- Take screenshots of vulnerabilities
- Note severity (Low/Medium/High)

