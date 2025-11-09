from flask import Flask
import redis
import os

app = Flask(__name__)

# Connect to Redis
redis_host = os.getenv('REDIS_HOST', 'redis')
redis_port = int(os.getenv('REDIS_PORT', 6379))
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

@app.route('/')
def home():
    try:
        visits = r.incr('counter')
    except redis.exceptions.ConnectionError:
        visits = "Cannot connect to Redis"
    return f"Hello from Flask! You have visited this page {visits} times."

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
