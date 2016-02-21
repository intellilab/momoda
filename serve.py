#!/usr/bin/env python
# coding=utf-8
from http.server import SimpleHTTPRequestHandler, test, HTTPStatus
import urllib.parse
import base64

key = 0
gallery = {}

class HTTPRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        path, _, qs = self.path.partition('?')
        if path != '/echo':
            return super().do_GET()
        try:
            q = urllib.parse.parse_qs(qs)
            key = q['key'][0]
            echo = gallery[key]
        except:
            self.send_error(HTTPStatus.NOT_FOUND)
            return
        self.send_response(HTTPStatus.OK)
        self.send_header('Content-Type', 'application/octet-stream')
        self.send_header('Content-Disposition', 'attachment; filename=awesome.gif')
        self.send_header('Content-Length', str(len(echo)))
        self.end_headers()
        self.wfile.write(echo)
        #gallery.pop(key, None)

    def do_POST(self):
        if self.path != '/echo':
            self.send_error(HTTPStatus.NOT_FOUND, "File not found")
            return
        length = self.headers.get('content-length')
        try:
            nbytes = int(length)
        except (TypeError, ValueError):
            nbytes = 0
        body = self.rfile.read(nbytes)
        try:
            data = urllib.parse.parse_qs(body)
            echo = base64.b64decode(data[b'data'][0])
        except:
            self.send_error(HTTPStatus.BAD_REQUEST)
            return
        global key
        key += 1
        skey = str(key)
        gallery[skey] = echo
        self.send_response(HTTPStatus.FOUND)
        self.send_header('Location', '/echo?key=' + skey)
        self.send_header('Content-Length', '0')
        self.end_headers()

test(HandlerClass=HTTPRequestHandler, port=8000, bind='0.0.0.0')
