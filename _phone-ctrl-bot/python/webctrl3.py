"""HTTP server"""

from http.server import BaseHTTPRequestHandler, HTTPServer
import socket
import urllib.parse as urlparse
from kivy.core.audio import SoundLoader

HOST_NAME   = ''
PORT_NUMBER = 9090

s1000 = SoundLoader.load('s1000.wav')
s1200 = SoundLoader.load('s1200.wav')
s1400 = SoundLoader.load('s1400.wav')
s1600 = SoundLoader.load('s1600.wav')
s1800 = SoundLoader.load('s1800.wav')

PAGE_TEMPLATE = '''
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>DroidBot Remote Control</title>
</head>
<FRAMESET ROWS="50%,50%">
<FRAME SRC="frame_a.html">
<FRAME SRC="frame_b.html">
</FRAMESET>
</html>
'''

PAGE_TEMPLATE_A = '''
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>DroidBot Remote Control</title>
</head>
<body>
<h1>Marsohod Remote Control</h1>
<iframe width="720" height="480" src ="http://%s:8080/video">No iframes?</iframe>
</body>
</html>
'''

PAGE_TEMPLATE_B = '''
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>DroidBot Remote Control</title>
<style type="text/css">
	#action {
		background:yellow;
		border:0px solid #555;
		color:#555;
		width:0px;
		height:0px;
		padding:0px;
	}
</style>
<script>
function AddText(text)
{
 document.myform.action.value=text;
}
</script>
</head>
<body>
<form name="myform" method="get">
		<textarea id="action" name="action">start</textarea>
		<input id="button1" type="submit" value="Start" OnClick='javascript:AddText ("start")' />
		<input id="button2" type="submit" value="Stop"  OnClick='javascript:AddText ("stop")'  />
		<input id="button3" type="submit" value="Back"  OnClick='javascript:AddText ("back")'  />
		<input id="button4" type="submit" value="Left"  OnClick='javascript:AddText ("left")'  />
		<input id="button5" type="submit" value="Right" OnClick='javascript:AddText ("right")' />
	</form>
</body>
</html>
'''

def play( id ):
	if (id=='start'):
		s1000.play()
	elif (id=='back'):
		s1200.play()
	elif (id=='left'):
		s1400.play()
	elif (id=='right'):
		s1600.play()
	elif (id=='stop'):
		s1800.play()
	
class DroidHandler(BaseHTTPRequestHandler):
    
	def do_HEAD(s):
		s.send_response(200)
		s.send_header("Content-type", "text/html; charset=utf-8")
		s.end_headers()

	def do_GET(s):
		s.send_response(200)
		
		my_full_addr = s.headers.get('Host')
		my_addr = my_full_addr.split(":",2)
		my_ip_addr = my_addr[0]
		
		url = urlparse.urlsplit(s.path)
		print( url.path )
		if url.path == '/frame_a.html':
			s.send_header("Content-type", "text/html; charset=utf-8")
			s.end_headers()
			html = PAGE_TEMPLATE_A % my_ip_addr
			s.wfile.write(html.encode())
			return
		elif url.path == '/frame_b.html':
			s.send_header("Content-type", "text/html; charset=utf-8")
			s.end_headers()
			
			query = url.query
			args = urlparse.parse_qsl(query)
		
			action = ''
			for arg in args:
				if arg[0] == 'action':
					action = arg[1].strip().replace('\r', '')
					print(action)
					play(action)
					break

			html = PAGE_TEMPLATE_B
			s.wfile.write(html.encode())
			return

		s.send_header("Content-type", "text/html; charset=utf-8")
		s.end_headers()

		html = PAGE_TEMPLATE
		s.wfile.write(html.encode())

print('web server running on port', PORT_NUMBER)
my_srv = HTTPServer((HOST_NAME, PORT_NUMBER), DroidHandler)
my_srv.serve_forever()
