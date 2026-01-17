#!/usr/bin/env python3
"""
Professional Digital Twin Dashboard
Real-time monitoring of temperature sensor and Digital Twin status
"""

from flask import Flask, render_template, jsonify, request
from flask_socketio import SocketIO, emit
import requests
import json
import time
import threading
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config['SECRET_KEY'] = 'ditto-dashboard-secret'
socketio = SocketIO(app, cors_allowed_origins="*")

# Configuration
DITTO_API_URL = "http://nginx:80"
DITTO_CREDENTIALS = ("ditto", "ditto")
THING_ID = "demo:sensor-1"

class DigitalTwinMonitor:
    def __init__(self):
        self.current_data = {}
        self.historical_data = []
        self.system_status = {}
        self.running = True
        
    def ensure_thing_exists(self):
        """Auto-create thing if it doesn't exist"""
        try:
            url = f"{DITTO_API_URL}/api/2/things/{THING_ID}"
            response = requests.get(url, auth=DITTO_CREDENTIALS, timeout=5)
            
            if response.status_code == 200:
                return True  # Thing exists
            elif response.status_code == 404:
                # Thing doesn't exist - create it
                logger.info(f"Thing {THING_ID} not found, auto-creating...")
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
                                "timestamp": datetime.now().isoformat() + "Z",
                                "status": "active"
                            }
                        }
                    }
                }
                
                # Try to create without policyId first (auto-creates policy)
                create_response = requests.put(
                    url,
                    json=thing_json,
                    auth=DITTO_CREDENTIALS,
                    headers={'Content-Type': 'application/json'},
                    timeout=10
                )
                
                if create_response.status_code in [200, 201, 204]:
                    logger.info(f"✅ Thing {THING_ID} auto-created successfully")
                    return True
                else:
                    logger.warning(f"Could not auto-create thing: {create_response.status_code}")
                    return False
            else:
                return False
        except Exception as e:
            logger.error(f"Error checking/creating thing: {e}")
            return False
    
    def get_thing_data(self):
        """Get current Digital Twin data"""
        try:
            # Ensure thing exists first
            self.ensure_thing_exists()
            
            url = f"{DITTO_API_URL}/api/2/things/{THING_ID}"
            response = requests.get(url, auth=DITTO_CREDENTIALS, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'thingId': data.get('thingId', ''),
                    'policyId': data.get('policyId', ''),
                    'attributes': data.get('attributes', {}),
                    'features': data.get('features', {}),
                    'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                }
            else:
                logger.error(f"Failed to get thing data: {response.status_code}")
                return None
        except Exception as e:
            logger.error(f"Error getting thing data: {e}")
            return None
    
    def get_temperature_data(self):
        """Get current temperature data"""
        try:
            url = f"{DITTO_API_URL}/api/2/things/{THING_ID}/features/temp/properties"
            response = requests.get(url, auth=DITTO_CREDENTIALS, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'value': data.get('value', 0),
                    'unit': data.get('unit', 'celsius'),
                    'timestamp': data.get('timestamp', ''),
                    'status': data.get('status', 'unknown')
                }
            else:
                logger.error(f"Failed to get temperature data: {response.status_code}")
                return None
        except Exception as e:
            logger.error(f"Error getting temperature data: {e}")
            return None
    
    def get_system_health(self):
        """Get system health status"""
        try:
            # Check Ditto health
            health_url = f"{DITTO_API_URL}/health"
            health_response = requests.get(health_url, timeout=5)
            ditto_status = "UP" if health_response.status_code == 200 else "DOWN"
            
            # Check sensor container (simulated)
            sensor_status = "RUNNING"  # In real scenario, check container status
            
            return {
                'ditto': ditto_status,
                'sensor': sensor_status,
                'api': "UP" if ditto_status == "UP" else "DOWN",
                'database': "UP",  # MongoDB status
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
        except Exception as e:
            logger.error(f"Error getting system health: {e}")
            return {
                'ditto': "DOWN",
                'sensor': "DOWN", 
                'api': "DOWN",
                'database': "DOWN",
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
    
    def update_data(self):
        """Update all data and emit to clients"""
        try:
            # Get current data
            thing_data = self.get_thing_data()
            temp_data = self.get_temperature_data()
            health_data = self.get_system_health()
            
            # Store current data
            self.current_data = {
                'thing': thing_data or {},
                'temperature': temp_data or {},
                'health': health_data or {}
            }
            
            # Add to historical data (keep last 100 points)
            if temp_data and 'value' in temp_data:
                self.historical_data.append({
                    'value': temp_data['value'],
                    'timestamp': temp_data.get('timestamp', datetime.now().isoformat()),
                    'time': datetime.now().strftime('%H:%M:%S')
                })
                
                if len(self.historical_data) > 100:
                    self.historical_data.pop(0)
            
            # Always emit data, even if some parts are missing
            emit_data = {
                'thingId': thing_data.get('thingId', '') if thing_data else '',
                'policyId': thing_data.get('policyId', '') if thing_data else '',
                'features': {
                    'temp': {
                        'properties': temp_data or {}
                    }
                },
                'attributes': thing_data.get('attributes', {}) if thing_data else {},
                'health': health_data or {},
                'historical': self.historical_data[-20:]  # Last 20 points
            }
            
            # Emit to all connected clients (broadcast is automatic from background thread)
            socketio.emit('data_update', emit_data)
            logger.debug(f"Emitted data update: {emit_data.get('features', {}).get('temp', {}).get('properties', {})}")
            
        except Exception as e:
            logger.error(f"Error updating data: {e}", exc_info=True)
            # Emit error to clients
            socketio.emit('data_update', {
                'error': True,
                'message': str(e)
            })
    
    def start_monitoring(self):
        """Start the monitoring thread"""
        def monitor_loop():
            while self.running:
                self.update_data()
                time.sleep(1)  # Update every 1 second for real-time updates
        
        monitor_thread = threading.Thread(target=monitor_loop, daemon=True)
        monitor_thread.start()
        logger.info("Digital Twin monitoring started")

# Initialize monitor
monitor = DigitalTwinMonitor()

@app.route('/')
def index():
    """Main dashboard page"""
    return render_template('dashboard.html', thing_id=THING_ID)

@app.route('/api/thing')
def api_thing():
    """API endpoint for thing data"""
    return jsonify(monitor.current_data.get('thing', {}))

@app.route('/api/temperature')
def api_temperature():
    """API endpoint for temperature data"""
    return jsonify(monitor.current_data.get('temperature', {}))

@app.route('/api/health')
def api_health():
    """API endpoint for system health"""
    return jsonify(monitor.current_data.get('health', {}))

@app.route('/api/historical')
def api_historical():
    """API endpoint for historical data"""
    return jsonify(monitor.historical_data)

@socketio.on('connect')
def handle_connect():
    """Handle client connection"""
    logger.info('Client connected')
    emit('connected', {'message': 'Connected to Digital Twin Dashboard'})

@socketio.on('disconnect')
def handle_disconnect():
    """Handle client disconnection"""
    logger.info('Client disconnected')

@socketio.on('request_data')
def handle_request_data():
    """Handle data request from client"""
    try:
        thing_data = monitor.current_data.get('thing', {})
        temp_data = monitor.current_data.get('temperature', {})
        health_data = monitor.current_data.get('health', {})
        
        emit_data = {
            'thingId': thing_data.get('thingId', '') if thing_data else '',
            'policyId': thing_data.get('policyId', '') if thing_data else '',
            'features': {
                'temp': {
                    'properties': temp_data if temp_data else {}
                }
            },
            'attributes': thing_data.get('attributes', {}) if thing_data else {},
            'health': health_data if health_data else {},
            'historical': monitor.historical_data[-20:] if monitor.historical_data else []
        }
        
        emit('data_update', emit_data)
        logger.debug(f"Sent data to client: {emit_data.get('features', {}).get('temp', {}).get('properties', {})}")
    except Exception as e:
        logger.error(f"Error handling request_data: {e}", exc_info=True)
        emit('data_update', {'error': True, 'message': str(e)})

if __name__ == '__main__':
    # Start monitoring
    monitor.start_monitoring()
    
    # Start Flask app
    logger.info("Starting Digital Twin Dashboard...")
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)
