import sys
import socket
import time
from tkinter import *

num_args = len(sys.argv)
if num_args<2 :
	print("Need 1 argument: Remote Device FPGA board IP address")
	sys.exit()

device_IP = sys.argv[1]
print("Device IP",device_IP)

L=0.33
one_step_grad = 1.8
num_steps_on_round = 360 / one_step_grad
print("Num Steps on Round",num_steps_on_round)
clk_freq = 100000000.0

sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
#sock.bind((host_IP,0))
#sock.setsockopt(socket.SOL_SOCKET,socket.SO_BROADCAST,1)

packet = bytes([0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58])
sock.sendto(packet,(device_IP,26985))

master = Tk()
master.title("Step Motor UDP Control")
master.geometry("300x300")

label_string = StringVar( value="Step Clocks: 0")
labelS_string = StringVar(value="Meters/min:  0")
def scale_change(param):
	rounds_sec = scale.get()
	led = int(255*rounds_sec/8.0);
	meters_min = rounds_sec * L * 60
	if rounds_sec==0 :
		print("stop")
		packet = bytes([0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00, 0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58])
		sock.sendto(packet,(device_IP,26985))
	else :
		one_step_clocks = int( clk_freq / (rounds_sec * num_steps_on_round ) )
		label_string.set(  "Step Clocks: "+str(one_step_clocks) )
		labelS_string.set( "Meters/min:  "+str(meters_min) )
		val = int(one_step_clocks/2) - 1
		val0= val       & 0xFF
		val1= (val>>8)  & 0xFF
		val2= (val>>16) & 0xFF
		packet = bytes([led,0x00,0x00,0x00,val0,val1,val2,0x00,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58])
		sock.sendto(packet,(device_IP,26985))

scale = Scale(master, from_=8.0, to=0.0, resolution=0.1, length=200, command=scale_change )
scale.place(x=25, y=25)
label = Label(master,textvariable=label_string)
label.place(x=35, y=230)
labelS = Label(master,textvariable=labelS_string)
labelS.place(x=35, y=245)

master.mainloop()
print("Main loop ends!")
