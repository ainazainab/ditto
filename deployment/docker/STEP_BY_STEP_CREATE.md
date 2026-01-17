# Step-by-Step: Create Policy and Thing (Foolproof Guide)

## Why Live Updates Don't Work

**Root Cause:** When MongoDB restarts, all data is lost:
- ❌ Policy `demo:sensor-policy` → DELETED
- ❌ Thing `demo:sensor-1` → DELETED
- ❌ Sensor can't send → No thing to send to
- ❌ Dashboard shows 404 → No thing to display

**Solution:** Recreate both policy and thing.

---

## STEP 1: Create Policy (5 minutes)

### 1.1 Open Ditto UI
- Go to: **http://localhost:8080**
- You should see the Ditto Explorer interface

### 1.2 Authorize with DevOps
1. Click the **"Authorize"** button (top right corner)
2. A modal window opens
3. In the **"DevOps authentication"** section:
   - **DevOps Username:** Type `devops`
   - **DevOps Password:** Type `foobar`
   - **IMPORTANT:** Click the **"Authorize"** button at the bottom of the modal (not just close it with X)
4. Wait for modal to close

### 1.3 Create Policy
1. Click **"Policies"** in the left sidebar
2. Click the **"Create Policy"** button (usually top right)
3. **Policy ID field:** Type `demo:sensor-policy`
4. Click the **"Edit JSON"** tab
5. **Delete everything** in the JSON editor
6. **Paste this exact JSON:**
```json
{
  "entries": {
    "ditto": {
      "subjects": {
        "nginx:ditto": {
          "type": "user"
        }
      },
      "resources": {
        "thing:/": {
          "grant": ["READ", "WRITE", "ADMINISTRATE"],
          "revoke": []
        },
        "policy:/": {
          "grant": ["READ", "WRITE", "ADMINISTRATE"],
          "revoke": []
        }
      }
    }
  }
}
```
7. Click **"Save"** button
8. You should see the policy created successfully

---

## STEP 2: Create Thing (5 minutes)

### 2.1 Make Sure You're Logged In
1. Still in Ditto UI (http://localhost:8080)
2. Click **"Authorize"** again if needed
3. **Main authentication** section:
   - **Username:** `ditto`
   - **Password:** `ditto`
   - Click **"Authorize"** button

### 2.2 Create Thing
1. Click **"Things"** in the left sidebar
2. Click the **"Create Thing"** button
3. **Thing ID field:** Type `demo:sensor-1`
4. **Policy ID field:** 
   - **IMPORTANT:** Use the **DROPDOWN/FIELD** (not JSON!)
   - Select or type: `demo:sensor-policy`
   - Make sure it shows `demo:sensor-policy` (not `hacked:policy` or anything else)
5. Click the **"Edit JSON"** tab
6. **Delete everything** in the JSON editor
7. **Paste this exact JSON (NO policyId!):**
```json
{
  "definition": "demo:sensor:1.0.0",
  "attributes": {
    "name": "Temperature Sensor"
  },
  "features": {
    "temp": {
      "properties": {
        "value": 25.0,
        "unit": "celsius",
        "timestamp": "2024-01-01T00:00:00Z",
        "status": "active"
      }
    }
  }
}
```
8. **VERIFY:** Make sure there is NO `"policyId"` in the JSON!
9. Click **"Save"** button
10. You should see the thing created successfully

---

## STEP 3: Verify Everything Works

### 3.1 Check Thing Exists
```powershell
cd C:\Users\lenovo\ditto\ditto\deployment\docker
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth}
```
Should return thing data.

### 3.2 Check Sensor
```powershell
docker compose logs sensor --tail 10
```
Should see: `✅ Temperature X°C sent successfully`

### 3.3 Check Dashboard
1. Open: **http://localhost:5000**
2. Should see:
   - Temperature value (not empty)
   - Temperature updating every 1 second
   - Chart showing data

---

## Common Mistakes to Avoid

❌ **Putting policyId in JSON** → Causes wrong policy to be used  
✅ **Use Policy ID dropdown field instead**

❌ **Not clicking "Authorize" button** → Credentials not saved  
✅ **Click the "Authorize" button at bottom of modal**

❌ **Using wrong policy ID** → Thing can't access resources  
✅ **Use exactly: `demo:sensor-policy`**

❌ **Creating thing before policy** → Thing creation fails  
✅ **Create policy first, then thing**

---

## If You Still Can't Create Thing

### Error: "Policy not found"
- Make sure policy `demo:sensor-policy` exists
- Check Policies list in UI

### Error: "Insufficient permissions"
- Make sure you clicked "Authorize" after entering credentials
- Try refreshing page (F5) and authorizing again

### Error: "Thing already exists"
- Delete the existing thing first
- Then create it again

### Thing shows wrong policy (like `hacked:policy`)
- Delete the thing
- Create it again, making sure Policy ID field shows `demo:sensor-policy`
- Don't put policyId in JSON

---

## After Creating Both

✅ **Policy created** → Check Policies list  
✅ **Thing created** → Check Things list  
✅ **Sensor sending** → Check logs  
✅ **Dashboard updating** → Open http://localhost:5000  

**Live updates should work now!**

---

## Quick Copy-Paste JSON

**Policy JSON:**
```json
{"entries":{"ditto":{"subjects":{"nginx:ditto":{"type":"user"}},"resources":{"thing:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]},"policy:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]}}}}}
```

**Thing JSON (NO policyId!):**
```json
{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}
```

---

**Follow these steps exactly and live updates will work!**

