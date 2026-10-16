import http.server
import socketserver

class UTF8Handler(http.server.SimpleHTTPRequestHandler):
    def guess_type(self, path):
        t = super().guess_type(path)
        if t == 'text/html':
            return 'text/html; charset=utf-8'
        if t == 'text/css':
            return 'text/css; charset=utf-8'
        if t in ('application/javascript', 'text/javascript'):
            return 'application/javascript; charset=utf-8'
        return t

PORT = 9000
with socketserver.TCPServer(("", PORT), UTF8Handler) as httpd:
    print(f"Serving on http://localhost:{PORT} with UTF-8 charset")
    httpd.serve_forever()