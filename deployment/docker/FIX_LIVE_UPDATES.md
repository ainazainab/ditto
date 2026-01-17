# Fix Live Updates Not Working

## Common Issues & Solutions

### Issue 1: Thing Doesn't Exist
**Symptom:** Dashboard shows "connected" but no data

**Check:**
```powershell
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth}
```

**Fix:** Create thing using UI (see CREATE_POLICY_THING_UI.md)

---

### Issue 2: Sensor Not Sending Data
**Symptom:** Temperature doesn't change, sensor logs show errors

**Check:**
```powershell
docker compose logs sensor --tail 20
```

**Look for:**
- `403 Forbidden` → Policy/thing issue
- `404 Not Found` → Thing doesn't exist
- `sent successfully` → Sensor is working

**Fix:**
- If 403: Check policy exists and grants permissions
- If 404: Create thing
- If no errors but not sending: Restart sensor

---

### Issue 3: Dashboard Can't Connect to Ditto
**Symptom:** Dashboard shows connection errors

**Check:**
1. Open dashboard: http://localhost:5000
2. Press F12 (Developer Tools)
3. Check Console tab for errors
4. Check Network tab for failed requests

**Common errors:**
- `WebSocket connection failed` → Check nginx WebSocket config
- `401 Unauthorized` → Authentication issue
- `CORS error` → Check nginx-cors.conf

**Fix:**
- Restart nginx: `docker compose restart nginx`
- Restart dashboard: `docker compose restart dashboard`
- Check nginx.conf has WebSocket support

---

### Issue 4: Rate Limiting Blocking Updates
**Symptom:** Updates work sometimes but stop frequently

**Check:**
```powershell
Get-Content nginx.conf | Select-String -Pattern "limit_req"
```

**Fix:**
- Remove rate limiting from nginx.conf
- Restart nginx: `docker compose restart nginx`

---

### Issue 5: Dashboard Not Polling/Updating
**Symptom:** Dashboard loads but temperature never changes

**Check:**
1. Is temperature actually changing in Ditto?
   ```powershell
   # Check multiple times
   $auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
   Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties" -Headers @{Authorization=$auth}
   Start-Sleep -Seconds 6
   Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties" -Headers @{Authorization=$auth}
   ```

2. Check dashboard WebSocket connection in browser console

**Fix:**
- If temperature not changing: Fix sensor
- If temperature changing but dashboard not: Check WebSocket connection

---

## Quick Diagnostic Script

```powershell
cd C:\Users\lenovo\ditto\ditto\deployment\docker

# 1. Check thing
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
try {
    $thing = Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth}
    Write-Host "✅ Thing exists"
} catch {
    Write-Host "❌ Thing missing - CREATE IT"
}

# 2. Check sensor
$logs = docker compose logs sensor --tail 5
if ($logs -match "sent successfully") {
    Write-Host "✅ Sensor sending"
} else {
    Write-Host "❌ Sensor not sending"
}

# 3. Check temperature changing
$temp1 = (Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties" -Headers @{Authorization=$auth}).value
Start-Sleep -Seconds 6
$temp2 = (Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1/features/temp/properties" -Headers @{Authorization=$auth}).value
if ($temp1 -ne $temp2) {
    Write-Host "✅ Temperature changing"
} else {
    Write-Host "❌ Temperature not changing"
}

# 4. Check dashboard
try {
    Invoke-WebRequest -Uri "http://localhost:5000" -UseBasicParsing | Out-Null
    Write-Host "✅ Dashboard accessible"
} catch {
    Write-Host "❌ Dashboard not accessible"
}
```

---

## Most Common Fix

**If everything was working before and stopped:**

1. **Thing was deleted** → Recreate it
2. **Policy was deleted** → Recreate it  
3. **Services restarted** → Thing/policy lost → Recreate them

**Solution:** Recreate policy and thing using UI method (CREATE_POLICY_THING_UI.md)

---

## Step-by-Step Recovery

1. **Check thing exists** (see above)
2. **If missing, create it:**
   - Open http://localhost:8080
   - Login: ditto/ditto
   - Create thing: demo:sensor-1
   - Policy: demo:sensor-policy (use dropdown)
   - JSON: From GET_ADMIN_ACCESS.md (no policyId in JSON)
3. **Verify sensor sending:**
   ```powershell
   docker compose logs -f sensor
   ```
4. **Check dashboard:**
   - Open http://localhost:5000
   - Check browser console (F12)
   - Look for WebSocket connection

---

## Expected Behavior

✅ **Thing exists** → Can query via API  
✅ **Sensor sending** → Logs show success every 5 seconds  
✅ **Temperature changing** → API shows different values  
✅ **Dashboard connected** → Browser console shows WebSocket connected  
✅ **Dashboard updating** → Temperature value changes every 1 second  

**If all true, live updates should work!**

