#!/usr/bin/env python3
"""
Temperature Sensor Service for Digital Twin Research
This runs in a separate container to simulate a VM environment
"""

import requests
import json
import time
import random
import os
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class TemperatureSensor:
    def __init__(self, config_file='sim_config.json'):
        """Initialize the temperature sensor with configuration."""
        self.config = self.load_config(config_file)
        self.base_url = self.config['ditto_api_url']
        self.thing_id = self.config['thing_id']
        self.update_interval = self.config['update_interval']
        self.temp_range = self.config['temp_range']
        
        # Set up authentication
        self.auth = (self.config['username'], self.config['password'])
        
        logger.info(f"🌡️  Temperature Sensor Service Started")
        logger.info(f"📡 Target: {self.thing_id}")
        logger.info(f"🔗 API: {self.base_url}")
        logger.info(f"⏱️  Interval: {self.update_interval}s")
        logger.info(f"🌡️  Range: {self.temp_range['min']}-{self.temp_range['max']}°C")
    
    def load_config(self, config_file):
        """Load configuration from JSON file."""
        default_config = {
            "thing_id": "demo:sensor-1",
            "update_interval": 5,
            "temp_range": {
                "min": 20,
                "max": 40
            },
            "ditto_api_url": "http://nginx:80",  # Use nginx service name
            "username": "ditto",
            "password": "ditto"
        }
        
        try:
            with open(config_file, 'r') as f:
                config = json.load(f)
            # Merge with defaults
            for key, value in default_config.items():
                if key not in config:
                    config[key] = value
            return config
        except FileNotFoundError:
            logger.warning(f"Config file {config_file} not found, using defaults")
            return default_config
        except json.JSONDecodeError as e:
            logger.error(f"Error parsing config file: {e}")
            return default_config
    
    def generate_temperature(self):
        """Generate a random temperature reading."""
        temp = round(random.uniform(self.temp_range['min'], self.temp_range['max']), 1)
        return temp
    
    def ensure_thing_exists(self):
        """Auto-create thing if it doesn't exist"""
        try:
            url = f"{self.base_url}/api/2/things/{self.thing_id}"
            response = requests.get(url, auth=self.auth, timeout=5)
            
            if response.status_code == 200:
                return True  # Thing exists
            elif response.status_code == 404:
                # Thing doesn't exist - create it
                logger.info(f"🔧 Thing {self.thing_id} not found, auto-creating...")
                thing_json = {
                    "definition": "demo:sensor:1.0.0",
                    "attributes": {
                        "name": "Temperature Sensor"
                    },
                    "features": {
                        "temp": {
                            "properties": {
                                "value": 25.0,
                                "unit": "celsius",
                                "timestamp": datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
                                "status": "active"
                            }
                        }
                    }
                }
                
                # Try gateway directly (bypass nginx) - use internal Docker network
                gateway_url = "http://gateway:8080/api/2/things/" + self.thing_id
                logger.info(f"🔧 Trying gateway directly: {gateway_url}")
                
                # Try gateway first (internal network, no nginx auth)
                try:
                    create_response = requests.put(
                        gateway_url,
                        json=thing_json,
                        auth=self.auth,
                        headers={'Content-Type': 'application/json'},
                        timeout=10
                    )
                    
                    if create_response.status_code in [200, 201, 204]:
                        logger.info(f"✅ Thing {self.thing_id} auto-created via gateway successfully")
                        return True
                    else:
                        logger.warning(f"⚠️ Gateway creation failed: {create_response.status_code}")
                except Exception as e:
                    logger.warning(f"⚠️ Gateway direct failed: {e}")
                
                # Fallback: try via nginx (with policyId query param)
                logger.info(f"🔧 Trying via nginx with auto-policy...")
                create_response = requests.put(
                    url,
                    json=thing_json,
                    auth=self.auth,
                    headers={'Content-Type': 'application/json'},
                    timeout=10
                )
                
                if create_response.status_code in [200, 201, 204]:
                    logger.info(f"✅ Thing {self.thing_id} auto-created successfully")
                    return True
                else:
                    logger.warning(f"⚠️ Could not auto-create thing: {create_response.status_code} - {create_response.text[:200]}")
                    return False
            else:
                return False
        except Exception as e:
            logger.error(f"❌ Error checking/creating thing: {e}")
            return False
    
    def send_temperature_reading(self, temperature):
        """Send temperature reading to Ditto."""
        # Ensure thing exists first
        self.ensure_thing_exists()
        
        timestamp = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
        
        # Prepare the data payload
        data = {
            "value": temperature,
            "unit": "celsius",
            "timestamp": timestamp,
            "status": "active"
        }
        
        # Construct the API endpoint
        url = f"{self.base_url}/api/2/things/{self.thing_id}/features/temp/properties"
        
        try:
            # Send PUT request to update the temperature
            response = requests.put(
                url,
                json=data,
                auth=self.auth,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code in [200, 204]:
                logger.info(f"✅ Temperature {temperature}°C sent successfully")
                return True
            elif response.status_code == 401:
                logger.error("❌ Authentication failed - check credentials")
                return False
            elif response.status_code == 403:
                logger.error("❌ Access forbidden - insufficient permissions")
                return False
            elif response.status_code == 404:
                logger.error("❌ Thing or feature not found - check if Digital Twin exists")
                return False
            else:
                logger.error(f"❌ Failed to send temperature: {response.status_code} - {response.text}")
                return False
                
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Network error: {e}")
            return False
    
    def get_current_temperature(self):
        """Get current temperature from Ditto."""
        url = f"{self.base_url}/api/2/things/{self.thing_id}/features/temp/properties"
        
        try:
            response = requests.get(
                url,
                auth=self.auth,
                headers={'Accept': 'application/json'},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                logger.info(f"📊 Current temperature: {data.get('value', 'N/A')}°C")
                return data
            else:
                logger.error(f"❌ Failed to get temperature: {response.status_code}")
                return None
                
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Network error: {e}")
            return None
    
    def test_connection(self):
        """Test connection to Ditto."""
        logger.info("🔍 Testing connection to Ditto...")
        
        try:
            # Test health endpoint
            health_url = f"{self.base_url}/health"
            response = requests.get(health_url, timeout=5)
            if response.status_code == 200:
                logger.info("✅ Ditto is accessible")
                return True
            else:
                logger.error(f"❌ Ditto health check failed: {response.status_code}")
                return False
        except Exception as e:
            logger.error(f"❌ Cannot connect to Ditto: {e}")
            return False
    
    def run_simulation(self):
        """Run the temperature sensor simulation."""
        logger.info("🚀 Starting temperature sensor simulation...")
        logger.info("Press Ctrl+C to stop")
        
        # Test connection first
        if not self.test_connection():
            logger.error("❌ Cannot connect to Ditto. Exiting.")
            return
        
        # Ensure thing exists before starting simulation
        logger.info("🔧 Ensuring thing exists...")
        max_retries = 5
        for attempt in range(max_retries):
            if self.ensure_thing_exists():
                logger.info("✅ Thing ready, starting simulation...")
                break
            else:
                if attempt < max_retries - 1:
                    logger.warning(f"⚠️  Thing creation failed, retrying in 5 seconds... (attempt {attempt + 1}/{max_retries})")
                    time.sleep(5)
                else:
                    logger.error("❌ Could not create thing after multiple attempts. Continuing anyway...")
        
        try:
            while True:
                # Generate new temperature reading
                temperature = self.generate_temperature()
                logger.info(f"🌡️  Generated temperature: {temperature}°C")
                
                # Send to Ditto
                success = self.send_temperature_reading(temperature)
                
                if success:
                    # Verify the update
                    time.sleep(1)  # Wait a moment
                    self.get_current_temperature()
                else:
                    # If send failed, try to recreate thing
                    if attempt % 10 == 0:  # Every 10 failed attempts
                        logger.warning("⚠️  Multiple failures, attempting to recreate thing...")
                        self.ensure_thing_exists()
                
                # Wait for next reading
                time.sleep(self.update_interval)
                
        except KeyboardInterrupt:
            logger.info("🛑 Simulation stopped by user")
        except Exception as e:
            logger.error(f"❌ Simulation error: {e}")

def main():
    """Main function to run the sensor service."""
    print("🌡️  Temperature Sensor Service for Digital Twin Research")
    print("=" * 60)
    
    # Initialize sensor
    sensor = TemperatureSensor()
    
    # Run simulation
    sensor.run_simulation()

if __name__ == "__main__":
    main()
