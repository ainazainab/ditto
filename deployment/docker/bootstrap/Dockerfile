FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir requests

COPY bootstrap.py .

CMD ["python", "bootstrap.py"]

