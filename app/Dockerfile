FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Install debugging tools
RUN apt-get update && apt-get install -y curl iputils-ping net-tools procps && rm -rf /var/lib/apt/lists/*

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
