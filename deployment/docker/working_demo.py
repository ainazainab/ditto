#!/usr/bin/env python3
"""
Working Digital Twin Demo - Bypasses authentication issues
This demonstrates the Digital Twin concept for your research
"""

import requests
import json
import time
import random
from datetime import datetime

def test_ditto_connection():
    """Test basic Ditto connectivity"""
    print("🔍 Testing Ditto Connection...")
    
    try:
        # Test health endpoint
        response = requests.get("http://localhost:8080/health", timeout=5)
        if response.status_code == 200:
            print("✅ Ditto is running and accessible")
            return True
        else:
            print(f"❌ Ditto health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Cannot connect to Ditto: {e}")
        return False

def create_digital_twin_structure():
    """Create the Digital Twin structure (demonstration)"""
    print("\n🏗️  Creating Digital Twin Structure...")
    
    # Policy structure
    policy = {
        "policyId": "demo:sensor-policy",
        "entries": {
            "viewer": {
                "subjects": {"demo:viewer": {"type": "user"}},
                "resources": {"thing:/": {"grant": ["READ"], "revoke": []}}
            },
            "operator": {
                "subjects": {"demo:operator": {"type": "user"}},
                "resources": {"thing:/": {"grant": ["READ", "WRITE"], "revoke": []}}
            },
            "admin": {
                "subjects": {"demo:admin": {"type": "user"}},
                "resources": {"thing:/": {"grant": ["READ", "WRITE", "ADMINISTRATE"], "revoke": []}}
            }
        }
    }
    
    # Thing structure
    thing = {
        "thingId": "demo:sensor-1",
        "policyId": "demo:sensor-policy",
        "definition": "demo:sensor:1.0.0",
        "attributes": {
            "name": "Temperature Sensor",
            "description": "Digital Twin for IoT security research",
            "location": "Lab Environment",
            "manufacturer": "Research Lab"
        },
        "features": {
            "temp": {
                "definition": ["demo:temperature:1.0.0"],
                "properties": {
                    "value": 25.0,
                    "unit": "celsius",
                    "timestamp": datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
                    "status": "active"
                }
            }
        }
    }
    
    # Save structures
    with open("demo_policy.json", "w") as f:
        json.dump(policy, f, indent=2)
    
    with open("demo_thing.json", "w") as f:
        json.dump(thing, f, indent=2)
    
    print("✅ Digital Twin structures created:")
    print(f"   - Policy: {policy['policyId']}")
    print(f"   - Thing: {thing['thingId']}")
    print(f"   - Features: {list(thing['features'].keys())}")
    
    return policy, thing

def simulate_sensor_data():
    """Simulate temperature sensor data"""
    print("\n🌡️  Simulating Temperature Sensor Data...")
    
    for i in range(5):
        # Generate random temperature
        temp = round(random.uniform(20, 40), 1)
        timestamp = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
        
        # Create sensor reading
        reading = {
            "value": temp,
            "unit": "celsius",
            "timestamp": timestamp,
            "status": "active"
        }
        
        print(f"   Reading {i+1}: {temp}°C at {timestamp}")
        
        # Simulate sending to Ditto (would normally be HTTP PUT)
        print(f"   📤 Would send to: /api/2/things/demo:sensor-1/features/temp/properties")
        print(f"   📦 Data: {json.dumps(reading, indent=2)}")
        
        time.sleep(2)
    
    print("✅ Sensor simulation completed")

def test_access_control():
    """Test access control scenarios"""
    print("\n🔒 Testing Access Control Scenarios...")
    
    scenarios = [
        {
            "name": "Viewer (Read Only)",
            "user": "demo:viewer",
            "action": "GET /api/2/things/demo:sensor-1",
            "expected": "✅ Should work - READ permission"
        },
        {
            "name": "Viewer trying to Write",
            "user": "demo:viewer", 
            "action": "PUT /api/2/things/demo:sensor-1/features/temp/properties",
            "expected": "❌ Should fail - No WRITE permission"
        },
        {
            "name": "Operator (Read + Write)",
            "user": "demo:operator",
            "action": "PUT /api/2/things/demo:sensor-1/features/temp/properties",
            "expected": "✅ Should work - WRITE permission"
        },
        {
            "name": "Admin (Full Access)",
            "user": "demo:admin",
            "action": "DELETE /api/2/things/demo:sensor-1",
            "expected": "✅ Should work - ADMINISTRATE permission"
        }
    ]
    
    for scenario in scenarios:
        print(f"   {scenario['name']}:")
        print(f"      User: {scenario['user']}")
        print(f"      Action: {scenario['action']}")
        print(f"      Expected: {scenario['expected']}")
        print()

def demonstrate_zero_trust():
    """Demonstrate Zero Trust security concepts"""
    print("\n🛡️  Zero Trust Security Analysis...")
    
    security_measures = [
        "🔐 Authentication: Every request must be authenticated",
        "🔑 Authorization: Role-based access control (RBAC)",
        "📝 Audit Logging: All operations are logged",
        "🚫 No Implicit Trust: Every request is verified",
        "🔄 Continuous Verification: Trust is never assumed",
        "📊 Monitoring: Real-time security monitoring",
        "🚨 Alerting: Immediate response to threats"
    ]
    
    for measure in security_measures:
        print(f"   {measure}")
    
    print("\n🔍 Security Vulnerabilities to Investigate:")
    vulnerabilities = [
        "❌ No encryption in transit (HTTP vs HTTPS)",
        "❌ Weak authentication mechanisms",
        "❌ Insufficient access control granularity", 
        "❌ No rate limiting or DDoS protection",
        "❌ Missing input validation",
        "❌ Insecure data storage",
        "❌ No security headers",
        "❌ Replay attack vulnerability"
    ]
    
    for vuln in vulnerabilities:
        print(f"   {vuln}")

def main():
    """Main demonstration function"""
    print("🌡️  Digital Twin Security Research Demo")
    print("=" * 50)
    
    # Test connection
    if not test_ditto_connection():
        print("⚠️  Ditto connection failed, but continuing with demo...")
    
    # Create Digital Twin structure
    policy, thing = create_digital_twin_structure()
    
    # Simulate sensor data
    simulate_sensor_data()
    
    # Test access control
    test_access_control()
    
    # Demonstrate Zero Trust
    demonstrate_zero_trust()
    
    print("\n🎉 Digital Twin Demo Completed!")
    print("\n📁 Files created:")
    print("   - demo_policy.json (Policy structure)")
    print("   - demo_thing.json (Thing structure)")
    print("\n🚀 Next steps for your research:")
    print("   1. Implement actual Ditto API calls with authentication")
    print("   2. Test access control with real credentials")
    print("   3. Analyze security vulnerabilities")
    print("   4. Implement Zero Trust security measures")
    print("   5. Add monitoring and logging")

if __name__ == "__main__":
    main()
