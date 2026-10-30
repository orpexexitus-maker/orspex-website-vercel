from http.server import BaseHTTPRequestHandler
import json
from datetime import datetime
import sqlite3
import os

# Vercel only allows writes to the /tmp directory
DB_PATH = '/tmp/blog.db'

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    # Create the table if it doesn't exist
    c.execute('''CREATE TABLE IF NOT EXISTS posts
                 (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                  title TEXT, 
                  content TEXT, 
                  author_email TEXT, 
                  created_at TEXT)''')
    conn.commit()
    conn.close()

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            init_db() # Ensure DB exists
            conn = sqlite3.connect(DB_PATH)
            c = conn.cursor()
            c.execute("SELECT id, title, content, author_email, created_at FROM posts ORDER BY id DESC")
            rows = c.fetchall()
            conn.close()

            # Convert rows to a list of dictionaries
            posts = []
            for row in rows:
                posts.append({
                    "id": row[0],
                    "title": row[1],
                    "content": row[2],
                    "author_email": row[3],
                    "created_at": row[4]
                })

            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(posts).encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))

    def do_POST(self):
        try:
            init_db()
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            conn = sqlite3.connect(DB_PATH)
            c = conn.cursor()
            c.execute("INSERT INTO posts (title, content, author_email, created_at) VALUES (?, ?, ?, ?)",
                      (data.get("title"), data.get("content"), data.get("author_email"), datetime.now().isoformat()))
            conn.commit()
            conn.close()
            
            self.send_response(201)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({"status": "success"}).encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()