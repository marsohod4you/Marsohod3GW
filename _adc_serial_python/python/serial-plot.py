import serial
import time
import sys
import numpy as np
from matplotlib import pyplot as plt

if len(sys.argv)<2 :
	print("Not enough arguments, need serial port name param")
port_name = sys.argv[1]
print(port_name)

port = serial.Serial()
port.baudrate=12000000
port.port=port_name
port.bytesize=8
port.parity='N'
port.stopbits=1
port.open()

plt.rcParams["figure.figsize"] = [7.50, 3.50]
plt.rcParams["figure.autolayout"] = True

adc_data = port.read( 1024 )

def f(x):
	global adc_data
	y=[]
	for i in x :
		y.append(adc_data[i])
	return y

x = np.arange(0, 1024)

plt.ion()
fig,ax = plt.subplots(1,1)
ax.set_xlabel('Idx')
ax.set_ylabel('ADC Data')
ax.set_ylim([0, 280])
line1, = ax.plot(x, f(x), color='red') # Returns a tuple of line objects, thus the comma
while 1 :
	adc_data = port.read( 1024 )
	line1.set_ydata(f(x))
	fig.canvas.draw()
	fig.canvas.flush_events()
	#time.sleep(1)

port.close()
