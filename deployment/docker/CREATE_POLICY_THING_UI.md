# How to Create Policy and Thing (Working Method)

This is the method that worked in our chat. Follow these exact steps:

---

## Step 1: Create Policy (Using DevOps Authentication)

1. **Open Ditto UI:**
   ```
   http://localhost:8080
   ```

2. **Click "Authorize" button** (top right corner)

3. **In the modal, fill in DevOps authentication:**
   - **DevOps Username:** `devops`
   - **DevOps Password:** `foobar`
   - **IMPORTANT:** Click the **"Authorize"** button at the bottom (don't just close the modal)

4. **Create Policy:**
   - Click **"Policies"** in left sidebar
   - Click **"Create Policy"** button
   - **Policy ID:** `demo:sensor-policy`
   - Click **"Edit JSON"** tab
   - **Delete everything** and paste this JSON:
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
   - Click **"Save"**

---

## Step 2: Create Thing (Using Regular Authentication)

1. **Still in Ditto UI** (http://localhost:8080)

2. **Make sure you're logged in as regular user:**
   - If needed, click "Authorize" again
   - **Main authentication:** `ditto` / `ditto`
   - Click "Authorize"

3. **Create Thing:**
   - Click **"Things"** in left sidebar
   - Click **"Create Thing"** button
   - **Thing ID:** `demo:sensor-1`
   - **Policy ID:** Select `demo:sensor-policy` from dropdown
   - Click **"Edit JSON"** tab
   - **Delete everything** and paste this JSON:
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
   - Click **"Save"**

---

## Step 3: Verify It Worked

Run this in PowerShell:

```powershell
cd C:\Users\lenovo\ditto\ditto\deployment\docker

# Check policy exists
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
Invoke-RestMethod -Uri "http://localhost:8080/api/2/policies/demo:sensor-policy" -Headers @{Authorization=$auth}

# Check thing exists
Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth}

# Check sensor logs
docker compose logs sensor --tail 5
```

Should see: `✅ Temperature X°C sent successfully`

---

## Quick Reference

**Policy JSON (for copy-paste):**
```json
{"entries":{"ditto":{"subjects":{"nginx:ditto":{"type":"user"}},"resources":{"thing:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]},"policy:/":{"grant":["READ","WRITE","ADMINISTRATE"],"revoke":[]}}}}}
```

**Thing JSON (for copy-paste):**
```json
{"definition":"demo:sensor:1.0.0","attributes":{"name":"Temperature Sensor"},"features":{"temp":{"properties":{"value":25.0,"unit":"celsius","timestamp":"2024-01-01T00:00:00Z","status":"active"}}}}
```

---

## Why This Works

- **DevOps auth** (`devops:foobar`) gives admin access to create policies
- **Regular auth** (`ditto:ditto`) can create things once policy exists
- The policy grants `nginx:ditto` full permissions to manage things

---

## After Creation

✅ **Policy created** → Sensor has permissions  
✅ **Thing created** → Digital Twin exists  
✅ **Sensor sending** → Check logs: `docker compose logs -f sensor`  
✅ **Dashboard working** → http://localhost:5000 shows live data

**That's it! This is the method that worked before.**

