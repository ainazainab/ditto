# How to Run Security Tests in VS Code

## Quick Start

1. **Open Terminal in VS Code:**
   - Press `` Ctrl + ` `` (backtick) or go to `Terminal` → `New Terminal`

2. **Navigate to tests directory:**
   ```powershell
   cd deployment/docker
   ```

3. **Run all tests:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File run_tests.ps1
   ```

## Run Individual Tests

To run a single test:

```powershell
cd deployment/docker/tests
.\01_unauthorized_write_no_auth.ps1
.\08_replay_attack.ps1
.\17_port_exposure_scan.ps1
```

## Expected Output

You'll see:
```
=== Security Tests ===

01. Unauthorized Write (No Auth) -> [OK] SECURE
02. Unauthorized Write (Wrong Creds) -> [OK] SECURE
...
08. Replay Attack -> [X] VULNERABILITY
...
14. WebSocket Auth -> [X] VULNERABILITY
16. Container Network Isolation -> [X] VULNERABILITY
17. Port Exposure Scan -> [X] VULNERABILITY

=== Summary ===
SECURE: 7
VULNERABILITIES: 4
```

## Prerequisites

- Docker containers must be running: `docker compose up -d`
- Thing must exist (sensor auto-creates it)
- Ditto API accessible at http://localhost:8080

## Troubleshooting

**"Connection refused":**
- Start Docker: `docker compose up -d`

**"Thing not found":**
- Wait for sensor to auto-create it
- Or create manually via UI

**"Execution policy error":**
- Use: `powershell -ExecutionPolicy Bypass -File run_tests.ps1`
