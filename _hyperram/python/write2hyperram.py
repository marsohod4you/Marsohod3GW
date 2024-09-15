import serial
import time
import numpy as np
import sys
from PIL import Image

if len(sys.argv)<3 :
	print("Need 2 arguments: COM-port name, filename")
	sys.exit()

def print_ba(s,ba):
	rs = "".join("{:02x}".format(x) for x in ba)
	print(s,rs)
	
port_name = sys.argv[1]
fname = sys.argv[2]

with open(fname, mode="rb") as hfile:
	fdata = hfile.read()

flen = len(fdata)
print( "File length: ",flen )

port = serial.Serial()
port.baudrate=12000000
port.port=port_name
port.bytesize=8
port.parity='N'
port.stopbits=1
#port.write_timeout=0;
port.open()
print(port.name)

L=0;
while L<flen :
	a0 = (L>> 0)&0xFF;
	a1 = (L>> 8)&0xFF;
	a2 = (L>>16)&0xFF;
	a3 = (L>>24)&0xFF;
	ba=bytearray( [ a3,a2,a1,a0, 0,0,0,0,0,0,0,0 ] )
	i=0
	while i<8 :
		if (i+L) == flen :
			break
		ba[4+i]=fdata[L+i]
		i=i+1
	port.write( ba )
	L=L+8
	#print(L)

port.close()
