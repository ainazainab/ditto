# Quick Start - Live Demo

## 🚀 Start Demo in 3 Steps

### Step 1: Start Your System
```powershell
cd deployment/docker
docker compose up -d
```

**Wait 30 seconds** for services to start.

### Step 2: Start Demo Server
```powershell
cd demo
.\start_demo.ps1
```

**OR** just double-click `live_demo.html` in the `demo` folder.

### Step 3: Open in Browser
- If using server: `http://localhost:8082/live_demo.html`
- If opened directly: File opens in your default browser

---

## 🎯 What to Show

### Most Important Demo (5 minutes):
1. **Input Validation Attack**
   - Click "Attack: Send 1000°C"
   - Show: "403 Blocked - mitigation working"
   - Click "Test: Verify Mitigation"
   - Show: "Valid data accepted"

2. **Replay Attack**
   - Click "Attack: Replay Same Request"
   - Show: "Replay blocked"

3. **Unauthorized Access**
   - Click "Attack: No Authentication"
   - Show: "401 Unauthorized"

---

## 📝 Presentation Script

**Opening:**
"Today I'll demonstrate real security attacks on my Digital Twin system and show how Zero Trust mitigations protect against them."

**Demo 1 - Input Validation:**
"This is the most critical vulnerability - invalid data can corrupt the Digital Twin state. Watch as I try to inject impossible values..."

[Click attack button]

"As you can see, the system blocks this with 403 Forbidden. This demonstrates Zero Trust 'assume breach' principle - we validate all inputs as if they're malicious."

**Demo 2 - Replay Attack:**
"Replay attacks allow old data to be re-injected, corrupting temporal accuracy. Let me demonstrate..."

[Click replay button]

"The system blocks replay attempts, ensuring only fresh, valid data is accepted."

**Closing:**
"These demonstrations show how Zero Trust principles protect Digital Twin systems from real-world attacks, addressing the gap identified in current literature."

---

## ✅ Checklist Before Demo

- [ ] Docker services running (`docker compose ps`)
- [ ] Nginx accessible (`http://localhost:8080`)
- [ ] Demo file opens in browser
- [ ] Test one attack button to verify it works
- [ ] Have backup screenshots ready

---

**You're ready! 🎯**




