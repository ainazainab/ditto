# Live Demo Guide - Presentation Ready

## Overview

This live demo shows **real attacks** on your Digital Twin system and demonstrates how **mitigations protect** against them.

**Perfect for:**
- Supervisor demo
- Final presentation
- Showing real-world security testing

---

## How to Run the Demo

### Step 1: Start Your System
```powershell
cd deployment/docker
docker compose up -d
```

**Wait 30 seconds** for services to start.

### Step 2: Open Demo Interface
Open `demo/live_demo.html` in your browser:
- Double-click the file, OR
- Right-click → Open with → Browser

**Or serve it:**
```powershell
# Simple Python server (if you have Python)
cd demo
python -m http.server 8082
# Then open: http://localhost:8082/live_demo.html
```

### Step 3: Run the Demo
Click the attack buttons to see live attacks and mitigations!

---

## Demo Scenarios

### Demo 1: Input Validation Attack ⭐ **MOST IMPORTANT**

**What it shows:**
- Attack: Try to inject invalid data (1000°C, -200°C, strings)
- Mitigation: System blocks with 403 Forbidden
- Result: Valid data accepted, invalid data rejected

**Why it's important:**
- Core vulnerability in your project
- Directly relates to Kulik et al. (2022) - "attacks on the twin's model"
- Shows Zero Trust "assume breach" principle

**Presentation script:**
1. "I'll demonstrate an input validation attack"
2. Click "Attack: Send 1000°C"
3. Show: "System blocks with 403 - mitigation working"
4. Click "Test: Verify Mitigation"
5. Show: "Valid data (25°C) is accepted"

---

### Demo 2: Replay Attack ⭐ **IMPORTANT**

**What it shows:**
- Attack: Replay the same request
- Mitigation: Rate limiting + policy blocks replay
- Result: Old messages cannot be re-injected

**Why it's important:**
- Kulik et al. (2022) identifies replay as major concern
- Shows temporal accuracy protection
- Demonstrates continuous verification

**Presentation script:**
1. "Now I'll show a replay attack"
2. Click "Attack: Replay Same Request"
3. Show: "First request succeeds, replay is blocked"
4. Explain: "This prevents old data from corrupting the Digital Twin"

---

### Demo 3: Unauthorized Access ⭐ **SHOWS SECURITY**

**What it shows:**
- Attack: Try to access without credentials
- Mitigation: Nginx Basic Auth blocks
- Result: All unauthorized requests rejected

**Why it's important:**
- Shows Zero Trust "never trust, always verify"
- El-Hajj et al. (2024) emphasizes this
- Demonstrates authentication working

**Presentation script:**
1. "Let me show authentication protection"
2. Click "Attack: No Authentication"
3. Show: "401 Unauthorized - system requires credentials"
4. Explain: "This is Zero Trust in action"

---

## Presentation Flow (10-15 minutes)

### Introduction (2 min)
- "I've built a Digital Twin security testbed using Eclipse Ditto"
- "I'll demonstrate real attacks and show how mitigations protect the system"

### Demo 1: Input Validation (4 min)
1. Explain the vulnerability
2. Show attack attempt
3. Show mitigation blocking it
4. Show valid data being accepted
5. Connect to literature (Kulik 2022)

### Demo 2: Replay Attack (3 min)
1. Explain replay attack concept
2. Show attack attempt
3. Show mitigation
4. Connect to literature (Kulik 2022)

### Demo 3: Unauthorized Access (2 min)
1. Show authentication requirement
2. Connect to Zero Trust principles
3. Connect to literature (El-Hajj 2024)

### Summary (2 min)
- Show summary table
- Highlight improvements
- Connect to research contribution

---

## Key Talking Points

### For Input Validation:
- "This is a critical vulnerability identified by Kulik et al. (2022)"
- "Invalid data can corrupt the Digital Twin state"
- "Our mitigation uses rate limiting and policy enforcement"
- "This demonstrates Zero Trust 'assume breach' principle"

### For Replay Attack:
- "Kulik et al. (2022) identifies replay manipulation as a major concern"
- "Replay attacks can corrupt temporal accuracy"
- "Our mitigation prevents old messages from being re-injected"
- "This shows continuous verification in action"

### For Unauthorized Access:
- "El-Hajj et al. (2024) emphasize unauthorized writes as critical weakness"
- "Our system requires authentication for all requests"
- "This is Zero Trust 'never trust, always verify'"
- "Every request is authenticated and authorized"

---

## Troubleshooting

### "Network Error" or "CORS Error"
- Make sure Ditto is running: `docker compose ps`
- Check nginx is accessible: `http://localhost:8080`
- Browser may block CORS - try Chrome or Firefox

### "401 Unauthorized" on all requests
- Check credentials: `ditto:ditto`
- Verify nginx.htpasswd file exists
- Check nginx logs: `docker compose logs nginx`

### Attacks show "403" immediately
- This means mitigation is working!
- Explain: "The system is already protected"
- Show the "Test: Verify Mitigation" to demonstrate valid data works

---

## What Makes This Demo Great

1. **Real Attacks:** Not simulated - actual HTTP requests to your system
2. **Live Results:** See real status codes and responses
3. **Visual Feedback:** Color-coded results (red = vulnerable, green = secure)
4. **Before/After:** Shows improvement after mitigations
5. **Literature Connected:** Each demo references research papers

---

## Additional Tips

1. **Practice First:** Run through the demo once before presentation
2. **Have Backup:** Screenshots ready in case of network issues
3. **Explain Results:** Don't just click buttons - explain what's happening
4. **Connect to Research:** Always link back to your literature review
5. **Show Impact:** Explain why each vulnerability matters

---

## Files

- `live_demo.html` - Main demo interface
- `DEMO_GUIDE.md` - This guide

**You're ready to impress your supervisor! 🎯**




