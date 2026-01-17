# How to Run and Check Security Tests

## Quick Start

### Run All Tests
```powershell
cd deployment/docker
powershell -ExecutionPolicy Bypass -File run_tests.ps1
```

This will run all 15 security tests and display a summary at the end.

## Test Results

### Understanding the Output

- **[OK] SECURE** (Green) = Test passed, vulnerability is fixed
- **[X] VULNERABILITY** (Red) = Test failed, vulnerability exists
- **[?] UNKNOWN** (Yellow) = Test could not determine result

### Expected Results (sec-fixes branch)

All 15 tests should show **[OK] SECURE**:
- Test 1: Unauthorized Write Access (No Authentication)
- Test 2: Unauthorized Write Access (Wrong Credentials)
- Test 3: Input Validation (Extreme Values)
- Test 4: Input Validation (Negative Values)
- Test 5: Input Validation (Wrong Data Type)
- Test 6: Input Validation (Malformed JSON)
- Test 7: Rate Limiting (DoS Attack)
- Test 8: Replay Attack Protection
- Test 9: RBAC Viewer Read Access
- Test 10: RBAC Viewer Write Attempt
- Test 11: HTTPS/TLS Enforcement
- Test 12: RBAC Privilege Escalation
- Test 13: WebSocket Authentication
- Test 14: Container Network Isolation
- Test 15: Port Exposure Scan

## Running Individual Tests

To run a specific test:

```powershell
cd deployment/docker/tests
.\01_unauthorized_write_no_auth.ps1
.\02_unauthorized_write_wrong_creds.ps1
.\03_input_validation_extreme_values.ps1
.\04_input_validation_negative_values.ps1
.\05_input_validation_wrong_type.ps1
.\06_input_validation_malformed_json.ps1
.\07_rate_limiting_dos.ps1
.\08_replay_attack.ps1
.\09_rbac_viewer_read.ps1
.\10_rbac_viewer_write_attempt.ps1
.\11_missing_https_enforcement.ps1
.\12_rbac_privilege_escalation.ps1
.\13_websocket_auth.ps1
.\14_container_network_isolation.ps1
.\15_port_exposure_scan.ps1
```

## Prerequisites

1. **Docker services must be running:**
   ```powershell
   cd deployment/docker
   docker compose up -d
   ```

2. **Wait for services to start:**
   ```powershell
   docker compose ps
   ```
   All services should show "Up" status.

3. **Check nginx is accessible:**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8080/health"
   ```

## Troubleshooting

### Tests show "UNKNOWN" or connection errors

1. **Check Docker services:**
   ```powershell
   docker compose ps
   docker compose logs nginx --tail 20
   ```

2. **Restart services if needed:**
   ```powershell
   docker compose restart
   Start-Sleep -Seconds 10
   ```

3. **Verify thing exists:**
   ```powershell
   $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
   Invoke-WebRequest -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{"Authorization"="Basic $cred"}
   ```

### Tests show vulnerabilities when they should be secure

- Make sure you're on the `sec-fixes` branch
- Check that security fixes are applied in `nginx.conf` and `docker-compose.yml`
- Verify nginx configuration is valid:
  ```powershell
  docker compose exec nginx nginx -t
  ```

## Test Summary Format

At the end of the test run, you'll see:

```
=================================================================
  Test Summary
=================================================================

Total Tests: 15

[OK] SECURE: 15
[X] VULNERABILITIES: 0
```

**In sec-fixes branch:** All tests should show `[OK] SECURE: 15`

## Quick Verification Commands

```powershell
# Run all tests
powershell -ExecutionPolicy Bypass -File run_tests.ps1

# Check specific test
.\tests\08_replay_attack.ps1

# Verify services are running
docker compose ps

# Check nginx logs
docker compose logs nginx --tail 20
```
