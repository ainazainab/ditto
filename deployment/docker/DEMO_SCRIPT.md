# Demo Script: Security Fixes Demonstration

## Overview
This guide shows how to demonstrate the security fixes in a recording. Show the before (vulnerability branch) vs after (sec-fixes branch) comparison.

---

## Part 1: Show Vulnerabilities (Vulnerability Branch)

### 1. Run Tests on Vulnerability Branch
```powershell
cd deployment/docker
git checkout vulnerability
powershell -ExecutionPolicy Bypass -File run_tests.ps1
```

**Show:** Tests showing `[X] VULNERABILITY` for:
- Test 8: Replay Attack
- Test 11: HTTPS/TLS Enforcement  
- Test 14: Container Network Isolation
- Test 15: Port Exposure

**Say:** "These tests identify security vulnerabilities in our digital twin system."

---

## Part 2: Show Fixes (Sec-Fixes Branch)

### 2. Switch to Sec-Fixes Branch
```powershell
git checkout sec-fixes
```

**Say:** "Now let's see how we fixed these vulnerabilities."

### 3. Show Key Files with Fixes

#### File 1: `nginx.conf` - Replay Attack Protection
**Location:** `deployment/docker/nginx.conf`
**Lines to show:** 13-15, 104-108

**What to show:**
```nginx
# SECURITY FIX: Replay Attack Protection - Rate limiting zone
limit_req_zone $binary_remote_addr$request_method$request_uri$http_authorization zone=replay_limit:10m rate=6r/m;

# Inside location /api:
limit_req zone=replay_limit burst=1 nodelay;
limit_req_status 409;  # Return 409 Conflict for replay attempts
```

**Say:** "We implemented rate limiting to detect and block replay attacks. Identical requests within a short time window are rejected."

---

#### File 2: `docker-compose.yml` - Port Exposure Fix
**Location:** `deployment/docker/docker-compose.yml`
**Lines to show:** MongoDB and Gateway service sections

**What to show:**
```yaml
mongodb:
  # SECURITY FIX: MongoDB port not exposed externally
  # ports:
  #   - 27017:27017

gateway:
  # SECURITY FIX: Gateway port not exposed externally
  # ports:
  #   - "8081:8080"
```

**Say:** "We removed external port mappings for sensitive services. MongoDB and Gateway are now only accessible through nginx, which enforces authentication."

---

#### File 3: `nginx.conf` - HTTPS/TLS Configuration
**Location:** `deployment/docker/nginx.conf`
**Lines to show:** 41-48 (HTTP redirect), 50-72 (HTTPS server block)

**What to show:**
```nginx
# HTTP to HTTPS redirect
server {
  listen 80;
  return 301 https://$server_name:8443$request_uri;
}

# HTTPS server with TLS
server {
  listen 443 ssl http2;
  ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
  ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
  ssl_protocols TLSv1.2 TLSv1.3;
  # ... security headers
}
```

**Say:** "We configured HTTPS/TLS encryption. All HTTP traffic is redirected to HTTPS, and we use strong TLS protocols and ciphers."

---

#### File 4: Test Files - Show Fixed Tests
**Location:** `deployment/docker/tests/`

**Files to show:**
- `08_replay_attack.ps1` - Shows `[OK] SECURE` for replay protection
- `11_missing_https_enforcement.ps1` - Shows `[OK] SECURE` for HTTPS
- `14_container_network_isolation.ps1` - Shows `[OK] SECURE` for isolation
- `15_port_exposure_scan.ps1` - Shows `[OK] SECURE` for port security

**Say:** "Our test suite verifies that all vulnerabilities have been fixed."

---

### 4. Run Tests on Sec-Fixes Branch
```powershell
powershell -ExecutionPolicy Bypass -File run_tests.ps1
```

**Show:** Final summary showing:
```
Total Tests: 15
[OK] SECURE: 15
[X] VULNERABILITIES: 0
```

**Say:** "All 15 security tests now pass. The system is secure."

---

## Part 3: Key Files Summary

### Files to Show in Demo (in order):

1. **`run_tests.ps1`** - Run tests on vulnerability branch (show failures)
2. **`nginx.conf`** (lines 13-15, 104-108) - Replay attack fix
3. **`docker-compose.yml`** (MongoDB/Gateway sections) - Port exposure fix
4. **`nginx.conf`** (lines 41-72) - HTTPS/TLS configuration
5. **`tests/08_replay_attack.ps1`** - Fixed test showing secure result
6. **`tests/11_missing_https_enforcement.ps1`** - Fixed test showing secure result
7. **`tests/14_container_network_isolation.ps1`** - Fixed test showing secure result
8. **`run_tests.ps1`** - Run tests on sec-fixes branch (show all passing)

---

## Quick Demo Flow (5 minutes)

1. **Switch to vulnerability branch** → Run tests → Show 3-4 vulnerabilities
2. **Switch to sec-fixes branch** → Show key code changes in:
   - `nginx.conf` (replay protection, HTTPS)
   - `docker-compose.yml` (port fixes)
3. **Run tests again** → Show all 15 tests passing
4. **Summary:** "We identified vulnerabilities, implemented fixes, and verified with automated tests."

---

## Talking Points

### For Each Fix:

**Replay Attack:**
- "Digital twin systems are vulnerable to replay attacks where old valid requests are re-submitted"
- "We implemented rate limiting to detect duplicate requests within a time window"
- "The system now returns 409 Conflict for replay attempts"

**Port Exposure:**
- "Exposing database and gateway ports directly allows attackers to bypass security controls"
- "We removed external port mappings, forcing all access through nginx"
- "This minimizes the attack surface and enforces authentication"

**HTTPS/TLS:**
- "Unencrypted HTTP allows man-in-the-middle attacks"
- "We configured HTTPS with strong TLS protocols and redirect all HTTP to HTTPS"
- "This ensures all sensitive data is encrypted in transit"

**Container Isolation:**
- "Containers accessing each other directly bypasses network security"
- "We documented this limitation and implemented authentication requirements"
- "For production, Kubernetes Network Policies would provide full isolation"

---

## Files Reference

| Fix | File | Key Lines |
|-----|------|-----------|
| Replay Attack | `nginx.conf` | 13-15, 104-108 |
| Port Exposure | `docker-compose.yml` | MongoDB/Gateway sections |
| HTTPS/TLS | `nginx.conf` | 41-72 |
| Test Results | `run_tests.ps1` | Run and show summary |
| Documentation | `SECURITY_FIXES.md` | Complete fix documentation |
