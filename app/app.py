from flask import Flask, jsonify
import redis
import os


app = Flask(__name__)
redis_host = os.environ.get('REDIS_HOST', 'localhost')
redis_port = int(os.environ.get('REDIS_PORT', 6379))


r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)


@app.route('/')
def index():
visits = 0
try:
visits = r.incr('visits')
except Exception:
visits = 'redis-unavailable'
return f"Hello from sample app! visits: {visits}\n"


@app.route('/health')
def health():
try:
if r.ping():
return jsonify(status='ok', redis='connected')
except Exception:
pass
return jsonify(status='fail', redis='unavailable'), 500


if __name__ == '__main__':
app.run(host='0.0.0.0', port=5000)
