# Fix: Thing Using Wrong Policy ID

## The Problem
Your thing `demo:sensor-1` is trying to use policy `hacked:policy` instead of `demo:sensor-policy`.

**Error:** "Policy with ID 'hacked:policy' is not or no longer existing"

## Why This Happens
The policy ID is stored in the thing's JSON definition. If you paste JSON that has `"policyId": "hacked:policy"` in it, that's what gets used.

---

## Solution: Fix the JSON

When creating the thing in the UI, make sure your JSON does NOT include a `policyId` field, OR it has the correct one.

### Correct JSON (NO policyId in JSON):

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

**IMPORTANT:** Don't include `"policyId"` in the JSON! Let the UI field handle it.

---

## Step-by-Step Fix

### Option 1: Delete and Recreate Thing

1. **Delete the thing first:**
   - In Ditto UI, go to Things
   - Find `demo:sensor-1`
   - Delete it

2. **Create new thing:**
   - Click "Create Thing"
   - **Thing ID:** `demo:sensor-1`
   - **Policy ID field (dropdown):** Select `demo:sensor-policy`
   - **Edit JSON tab:** Paste the JSON above (WITHOUT policyId)
   - Click "Save"

### Option 2: Update Existing Thing

1. **In Ditto UI:**
   - Go to Things → Find `demo:sensor-1`
   - Click on it to edit
   - Go to "Edit JSON" tab
   - **Remove any `"policyId"` field from the JSON**
   - Make sure the Policy ID dropdown shows `demo:sensor-policy`
   - Click "Save"

---

## What NOT to Do

❌ **Don't paste JSON with policyId in it:**
```json
{
  "thingId": "demo:sensor-1",
  "policyId": "hacked:policy",  // ❌ WRONG!
  ...
}
```

✅ **Do use the Policy ID dropdown field instead:**
- Use the UI's "Policy ID" dropdown/field
- Select `demo:sensor-policy` from the dropdown
- Don't put policyId in the JSON

---

## Quick Fix Script

If you want to delete and recreate via API:

```powershell
cd C:\Users\lenovo\ditto\ditto\deployment\docker

# Delete the thing (if it exists)
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
try {
    Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Method DELETE -Headers @{Authorization=$auth}
    Write-Host "Thing deleted" -ForegroundColor Green
} catch {
    Write-Host "Thing doesn't exist or can't delete" -ForegroundColor Yellow
}

# Then create it fresh in UI with correct policy
```

---

## The Correct Way

1. **Thing ID field:** `demo:sensor-1`
2. **Policy ID dropdown:** Select `demo:sensor-policy` (use the UI field, not JSON)
3. **JSON (Edit JSON tab):** Only the thing definition, NO policyId:
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

**The policy ID comes from the UI dropdown, NOT from the JSON!**

---

## Verify After Fix

```powershell
$auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("ditto:ditto"))
$thing = Invoke-RestMethod -Uri "http://localhost:8080/api/2/things/demo:sensor-1" -Headers @{Authorization=$auth}
Write-Host "Policy: $($thing.policyId)"  # Should be: demo:sensor-policy
```

---

**The key:** Use the Policy ID **dropdown field** in the UI, not a `policyId` in the JSON!

