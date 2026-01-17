FROM python:3.11-slim

# Install required packages
RUN pip install requests

# Set working directory
WORKDIR /app

# Copy sensor service
COPY sensor_service.py .
COPY sim_config.json .

# Run the sensor service
CMD ["python", "sensor_service.py"]
