from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello():
    # שליפת שם השרת (בתוך קונטיינר זה יהיה ה-Pod Name)
    hostname = socket.gethostname()
    return f"""
    <h1>🚀 DevOps Lab - Mission Accomplished!</h1>
    <p><b>Pod Name:</b> {hostname}</p>
    <p><b>Version:</b> 1.0.0</p>
    """

if __name__ == "__main__":
    # האפליקציה תרוץ על פורט 5000
    app.run(host='0.0.0.0', port=5000)