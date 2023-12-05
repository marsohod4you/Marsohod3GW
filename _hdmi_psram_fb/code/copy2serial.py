import serial
import time
import numpy as np
import sys
from PIL import Image

if len(sys.argv)<2 :
	print("Need 2 arguments: COM-port name, bitmap filename")
	sys.exit()

port_name = sys.argv[1]
img_name = sys.argv[2]

im = Image.open(img_name)
iwidth, iheight = im.size
print(iwidth,iheight)

# Convert Pillow image to NumPy array
img_array = np.array(im, dtype=np.uint8)

#convert image into array of draw commands
rgb_arr=bytearray([0xFF]*iwidth*iheight*3)
	
y=0
while y<iheight :
	x=0
	yr=iheight-y-1
	while x<iwidth :
		pixel = img_array[y][x]
		r = pixel[0]
		g = pixel[1]
		b = pixel[2]
		rgb_arr[yr*iwidth*3+x*3+0] = r
		rgb_arr[yr*iwidth*3+x*3+1] = g
		rgb_arr[yr*iwidth*3+x*3+2] = b
		x=x+1
	y=y+1

port = serial.Serial()
port.baudrate=1000000
port.port=port_name
port.bytesize=8
port.parity='N'
port.stopbits=1
port.open()
print(port.name)
	
port.write( rgb_arr )
port.close()
