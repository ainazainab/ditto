#!/usr/bin/env python3
"""
Temperature Sensor Service for Digital Twin Research
This script simulates an IoT temperature sensor and sends data to Eclipse Ditto.
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
        
        # Set up authentication if provided
        self.auth = None
        if 'username' in self.config and 'password' in self.config:
            self.auth = (self.config['username'], self.config['password'])
        
        logger.info(f"Initialized sensor for thing: {self.thing_id}")
        logger.info(f"Update interval: {self.update_interval} seconds")
        logger.info(f"Temperature range: {self.temp_range['min']}-{self.temp_range['max']}°C")
    
    def load_config(self, config_file):
        """Load configuration from JSON file."""
        default_config = {
            "thing_id": "demo:sensor-1",
            "update_interval": 5,
            "temp_range": {
                "min": 20,
                "max": 40
            },
            "ditto_api_url": "http://localhost:8080",
            "username": None,
            "password": None
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
    
    def send_temperature_reading(self, temperature):
        """Send temperature reading to Ditto."""
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
            
            if response.status_code == 200:
                logger.info(f"Temperature {temperature}°C sent successfully")
                return True
            elif response.status_code == 401:
                logger.error("Authentication failed - check credentials")
                return False
            elif response.status_code == 403:
                logger.error("Access forbidden - insufficient permissions")
                return False
            elif response.status_code == 404:
                logger.error("Thing or feature not found - check if Digital Twin exists")
                return False
            else:
                logger.error(f"Failed to send temperature: {response.status_code} - {response.text}")
                return False
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Network error: {e}")
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
                logger.info(f"Current temperature: {data.get('value', 'N/A')}°C")
                return data
            else:
                logger.error(f"Failed to get temperature: {response.status_code}")
                return None
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Network error: {e}")
            return None
    
    def test_access_control(self):
        """Test access control with different user roles."""
        logger.info("Testing access control...")
        
        # Test 1: Try to read without authentication
        logger.info("Test 1: Reading without authentication")
        url = f"{self.base_url}/api/2/things/{self.thing_id}/features/temp/properties"
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 401:
                logger.info("✓ Authentication required (expected)")
            else:
                logger.warning(f"Unexpected response: {response.status_code}")
        except Exception as e:
            logger.error(f"Error in test 1: {e}")
        
        # Test 2: Try to write with wrong credentials
        logger.info("Test 2: Writing with wrong credentials")
        wrong_auth = ('wronguser', 'wrongpass')
        try:
            response = requests.put(
                url,
                json={"value": 25.0, "unit": "celsius"},
                auth=wrong_auth,
                timeout=5
            )
            if response.status_code == 401:
                logger.info("✓ Wrong credentials rejected (expected)")
            else:
                logger.warning(f"Unexpected response: {response.status_code}")
        except Exception as e:
            logger.error(f"Error in test 2: {e}")
    
    def run_simulation(self):
        """Run the temperature sensor simulation."""
        logger.info("Starting temperature sensor simulation...")
        logger.info("Press Ctrl+C to stop")
        
        try:
            while True:
                # Generate new temperature reading
                temperature = self.generate_temperature()
                logger.info(f"Generated temperature: {temperature}°C")
                
                # Send to Ditto
                success = self.send_temperature_reading(temperature)
                
                if success:
                    # Verify the update
                    time.sleep(1)  # Wait a moment
                    self.get_current_temperature()
                
                # Wait for next reading
                time.sleep(self.update_interval)
                
        except KeyboardInterrupt:
            logger.info("Simulation stopped by user")
        except Exception as e:
            logger.error(f"Simulation error: {e}")

def main():
    """Main function to run the sensor service."""
    print("🌡️  Temperature Sensor Service for Digital Twin Research")
    print("=" * 60)
    
    # Initialize sensor
    sensor = TemperatureSensor()
    
    # Test access control first
    sensor.test_access_control()
    
    # Run simulation
    sensor.run_simulation()

if __name__ == "__main__":
    main()
