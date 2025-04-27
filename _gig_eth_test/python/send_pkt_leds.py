import sys
import time
import socket

num_args = len(sys.argv)
if num_args<2 :
	print("Need 1 argument: this host IP address")
	sys.exit()

host_IP = sys.argv[1]
print("My Host IP",host_IP)

sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
sock.bind((host_IP,0))
sock.setsockopt(socket.SOL_SOCKET,socket.SO_BROADCAST,1)

packet = bytearray([0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F])
B=1
dir=1
while 1:
	packet[0] = B
	sock.sendto(packet,('255.255.255.255',26985))
	if dir==1 :
		if B!=0xFF :
			B=(B<<1) | 1
		else :
			dir=0
			B=B>>1
	else :
		if B!=1 :
			B=B>>1
		else :
			B=(B>>1) | 1
			dir=1
	time.sleep(0.25)
