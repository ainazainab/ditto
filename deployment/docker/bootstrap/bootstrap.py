#!/usr/bin/env python3
"""
Bootstrap script to create policy and thing on startup.
Runs inside Docker network with direct access to gateway.
"""
import requests
import time
import sys
import json

# URLs (internal Docker network)
# Use nginx for proper authentication routing
NGINX_URL = "http://nginx:80"
GATEWAY_URL = "http://gateway:8080"

# Credentials
DEVOPS_AUTH = ("devops", "foobar")
REGULAR_AUTH = ("ditto", "ditto")

# Policy JSON
POLICY_JSON = {
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

# Thing JSON (NO policyId!)
THING_JSON = {
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

def wait_for_gateway(max_retries=30, delay=2):
    """Wait for nginx and gateway to be ready"""
    print("Waiting for nginx and gateway to be ready...")
    for i in range(max_retries):
        try:
            # Check nginx first
            response = requests.get(f"{NGINX_URL}/health", timeout=5)
            if response.status_code == 200:
                print("✓ Nginx and gateway are ready")
                return True
        except Exception as e:
            if i < max_retries - 1:
                print(f"  Attempt {i+1}/{max_retries}...")
                time.sleep(delay)
            else:
                print(f"✗ Services not ready after {max_retries} attempts")
                return False
    return False

def create_policy():
    """Create policy using DevOps credentials via nginx"""
    print("\nCreating policy: demo:sensor-policy")
    
    # Try through nginx with DevOps basic auth
    import base64
    devops_basic = base64.b64encode(f"{DEVOPS_AUTH[0]}:{DEVOPS_AUTH[1]}".encode()).decode()
    
    url = f"{NGINX_URL}/api/2/policies/demo:sensor-policy"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Basic {devops_basic}"
    }
    
    try:
        response = requests.put(url, json=POLICY_JSON, headers=headers, timeout=10)
        
        if response.status_code in [200, 201]:
            print("✓ Policy created via nginx")
            return True
        elif response.status_code == 409:
            print("✓ Policy already exists")
            return True
        else:
            print(f"  Nginx method failed: {response.status_code}")
            if response.text:
                print(f"    Response: {response.text[:200]}")
    except Exception as e:
        print(f"  Nginx method error: {str(e)}")
    
    print("✗ Could not create policy")
    return False

def create_thing():
    """Create thing using regular credentials via nginx"""
    print("\nCreating thing: demo:sensor-1")
    
    # Wait a moment for policy to propagate
    time.sleep(2)
    
    # Try through nginx with regular basic auth
    import base64
    regular_basic = base64.b64encode(f"{REGULAR_AUTH[0]}:{REGULAR_AUTH[1]}".encode()).decode()
    
    url = f"{NGINX_URL}/api/2/things/demo:sensor-1"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Basic {regular_basic}"
    }
    
    try:
        response = requests.put(url, json=THING_JSON, headers=headers, timeout=10)
        
        if response.status_code in [200, 201]:
            print("✓ Thing created via nginx")
            return True
        elif response.status_code == 409:
            print("✓ Thing already exists")
            return True
        else:
            print(f"  Nginx method failed: {response.status_code}")
            if response.text:
                print(f"    Response: {response.text[:200]}")
    except Exception as e:
        print(f"  Nginx method error: {str(e)}")
    
    print("✗ Could not create thing")
    return False

def verify():
    """Verify policy and thing exist"""
    print("\nVerifying...")
    time.sleep(2)
    
    # Check policy via nginx
    import base64
    regular_basic = base64.b64encode(f"{REGULAR_AUTH[0]}:{REGULAR_AUTH[1]}".encode()).decode()
    headers = {"Authorization": f"Basic {regular_basic}"}
    
    try:
        response = requests.get(
            f"{NGINX_URL}/api/2/policies/demo:sensor-policy",
            headers=headers,
            timeout=5
        )
        if response.status_code == 200:
            print("✓ Policy verified")
        else:
            print(f"✗ Policy verification failed: {response.status_code}")
    except Exception as e:
        print(f"✗ Policy verification error: {str(e)}")
    
    # Check thing via nginx
    try:
        response = requests.get(
            f"{NGINX_URL}/api/2/things/demo:sensor-1",
            headers=headers,
            timeout=5
        )
        if response.status_code == 200:
            data = response.json()
            print("✓ Thing verified")
            if "features" in data and "temp" in data["features"]:
                temp = data["features"]["temp"]["properties"].get("value", "N/A")
                print(f"  Temperature: {temp}°C")
            return True
        else:
            print(f"✗ Thing verification failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Thing verification error: {str(e)}")
        return False

def main():
    print("=" * 60)
    print("Ditto Bootstrap - Creating Policy and Thing")
    print("=" * 60)
    
    # Wait for services
    if not wait_for_gateway():
        print("\n✗ Bootstrap failed: Services not ready")
        sys.exit(1)
    
    # Create policy
    policy_ok = create_policy()
    
    # Create thing
    thing_ok = create_thing()
    
    # Verify
    verify()
    
    if policy_ok and thing_ok:
        print("\n" + "=" * 60)
        print("✓ Bootstrap completed successfully!")
        print("=" * 60)
        sys.exit(0)
    else:
        print("\n" + "=" * 60)
        print("✗ Bootstrap completed with errors")
        print("=" * 60)
        sys.exit(1)

if __name__ == "__main__":
    main()

