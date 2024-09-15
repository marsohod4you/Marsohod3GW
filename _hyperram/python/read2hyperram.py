import serial
import time
import numpy as np
import sys
from PIL import Image

if len(sys.argv)<4 :
	print("Need 3 arguments: COM-port name, filename, filesize")
	sys.exit()

def print_ba(s,ba):
	rs = "".join("{:02x}".format(x) for x in ba)
	print(s,rs)
	
port_name = sys.argv[1]
fname = sys.argv[2]
fsize = int(sys.argv[3])

port = serial.Serial()
port.baudrate=12000000
port.port=port_name
port.bytesize=8
port.parity='N'
port.stopbits=1
#port.write_timeout=0;
port.open()
print(port.name)

with open(fname, "ab") as hfile:
    #hfile.write(binary_data)
	L=0
	while L<fsize :
		a0 = (L>> 0)&0xFF;
		a1 = (L>> 8)&0xFF;
		a2 = (L>>16)&0xFF;
		a3 = 0x80;
		arr = bytearray( [ a3,a2,a1,a0, 0x00,0x00, 0x00,0x00, 0x00,0x00, 0x00,0x00 ] )
		port.write( arr )
		r = port.read( 8 )
		if fsize-L >= 8 :
			hfile.write(r)
		else :
			hfile.write(r[0:fsize-L])
		#print_ba( "Read: ",r )
		L=L+8

port.close()
