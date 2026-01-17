# Diagnose Dashboard Live Updates

## Quick Checklist

### ✅ System Requirements:
- [ ] Thing exists: `demo:sensor-1`
- [ ] Policy exists: `demo:sensor-policy`
- [ ] Sensor is sending data (check logs)
- [ ] Dashboard is running (http://localhost:5000)
- [ ] Nginx has no rate limiting

---

## Step-by-Step Diagnosis

### 1. Check Thing Exists
```powershell
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth}
```
**Should return:** Thing data with temperature

### 2. Check Sensor is Sending
```powershell
docker compose logs sensor --tail 10
```
**Should see:** `✅ Temperature X°C sent successfully` every 5 seconds

### 3. Check Dashboard is Running
```powershell
curl http://localhost:5000
```
**Should return:** HTML page (200 OK)

### 4. Check Dashboard Logs
```powershell
docker compose logs dashboard --tail 20
```
**Look for:** Connection errors, API errors, WebSocket errors

### 5. Check Browser Console
1. Open: http://localhost:5000
2. Press F12 (Developer Tools)
3. Check Console tab for errors
4. Check Network tab for failed requests

---

## Common Issues & Fixes

### Issue: Thing Doesn't Exist
**Fix:** Create thing using UI (see CREATE_POLICY_THING_UI.md)

### Issue: Sensor Not Sending
**Fix:** 
- Check if policy exists
- Check sensor logs: `docker compose logs -f sensor`
- Restart sensor: `docker compose restart sensor`

### Issue: Dashboard Shows "Connected" but No Data
**Fix:**
- Check if thing exists
- Check browser console (F12) for WebSocket errors
- Restart dashboard: `docker compose restart dashboard`

### Issue: WebSocket Connection Failed
**Fix:**
- Check nginx.conf has no rate limiting
- Restart nginx: `docker compose restart nginx`
- Check firewall/antivirus blocking WebSocket

### Issue: CORS Errors
**Fix:**
- Check nginx-cors.conf exists
- Restart nginx

---

## Test Live Updates Manually

```powershell
# Check temperature changes
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$thingUrl = "http://localhost:8080/api/2/things/demo:sensor-1"

# Get temperature 1
$thing1 = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
$temp1 = $thing1.features.temp.properties.value
Write-Host "Temperature 1: $temp1°C"

# Wait 6 seconds
Start-Sleep -Seconds 6

# Get temperature 2
$thing2 = Invoke-RestMethod -Uri $thingUrl -Headers @{Authorization=$auth}
$temp2 = $thing2.features.temp.properties.value
Write-Host "Temperature 2: $temp2°C"

# Compare
if ($temp1 -ne $temp2) {
    Write-Host "✅ Live updates working!"
} else {
    Write-Host "❌ Temperature not changing - sensor may not be sending"
}
```

---

## Full System Restart

If nothing works, restart everything:

```powershell
cd C:\Users\lenovo\ditto\ditto\deployment\docker
docker compose down
docker compose up -d
Start-Sleep -Seconds 30

# Then check everything again
```

---

## Expected Behavior

✅ **Thing exists** → Can query via API  
✅ **Sensor sending** → Logs show success every 5 seconds  
✅ **Temperature changing** → API shows different values over time  
✅ **Dashboard updating** → Browser shows temperature changing every 1 second  
✅ **No errors** → Browser console clean, no failed requests  

**If all these are true, dashboard should show live updates!**

